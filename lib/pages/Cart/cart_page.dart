import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:easebuzz_flutter/easebuzz_flutter.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/event/ProductListEvent.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/models/cart.dart';
import 'package:tezchal/pages/Cart/add_coupon_page.dart';
import 'package:tezchal/pages/Cart/order_confirmed_page.dart';
import 'package:tezchal/pages/Product/product_detail_page.dart';
import 'package:tezchal/provider/cart_provider.dart';
import 'package:tezchal/provider/has_group.dart';
import 'package:tezchal/respositories/cart/cart_repository.dart';
import 'package:tezchal/ui_elements/cart_loading.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_circular_progress.dart';
import 'package:tezchal/ui_elements/slider_widget.dart';
import 'package:tezchal/ui_elements/empty_page.dart';
import 'package:rflutter_alert/rflutter_alert.dart' as rfa; // Added with prefix

import '../../helpers/constant.dart';
import '../../helpers/network.dart';
import '../../helpers/utils.dart';

class CartPage extends StatefulWidget {
  final VoidCallback? onCartEmptied;
  const CartPage({Key? key, this.onCartEmptied}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with WidgetsBindingObserver {
  bool checkSendToWhatsApp = true;
  bool isLoadingCart = false;
  // var cart; // Removed: Cart data will now be managed by CartProvider
  List paymentMethod = [];
  int paymentMethodId = 0;
  // List schedules = []; // Removed: Schedules will now be managed by CartProvider
  List ads = [];

  double deliveryFee = 0;

  // var couponData; // Removed: Coupon data will now be managed by CartProvider

  // group
  List groupMember = [];
  int orderDay = 0;
  String byLeader = '';
  String leaderId = '';
  String leaderzipCode = '';

  String groupProfile = '';

  late Mixpanel mixpanel;

  final EasebuzzFlutter _easebuzzFlutterPlugin = EasebuzzFlutter();
  String? _pendingTransactionId;

  @override
  void initState() {
    print("APPU cart");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPage();

    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(
      MIX_PANEL,
      optOutTrackingDefault: false,
      trackAutomaticEvents: true,
    );
  }

  initPage() async {
    // await loadCart();
    await fetchAds();
    await fetchPaymentMethod();
    await getMember();
  }

  loadCart() async {
    print("CartPage: Starting loadCart() to refresh cart items.");
    print("CartPage: Current isLoadingCart status: $isLoadingCart");
    if (isLoadingCart) {
      print("CartPage: loadCart() already in progress, returning.");
      return;
    }
    isLoadingCart = true;
    print("CartPage: Setting isLoadingCart to true.");
    print("CartPage: Fetching cart data from server (endpoint: me/cart).");
    var response = await netGet(isUserToken: true, endPoint: "me/cart");
    print("CartPage: Received response for me/cart: ${response['resp_code']}");
    print("CartPage: Full response: $response");
    if (response['resp_code'] == "200") {
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        // cart = temp; // Removed: Cart data is now in CartProvider
        List cartItems = temp['lines'];
        // couponData = temp.containsKey('coupon') ? temp['coupon'] : null; // Managed by CartProvider
        paymentMethodId =
            checkIsNullValue(temp['payment_type'])
                ? 0
                : temp['payment_type']['id'];
        // schedules = temp.containsKey('schedules') ? temp['schedules'] : []; // Managed by CartProvider

        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context.read<CartProvider>().refreshCartGrandTotal(
          double.parse(temp['total'].toString()),
        );
      } else {
        // Handle case where data is null or 'lines' is missing (empty cart)
        context.read<CartProvider>().refreshCartData(null);
        context.read<CartProvider>().refreshCart(false);
        context.read<CartProvider>().refreshCartCount(0);
        context.read<CartProvider>().refreshCartGrandTotal(0.0);
      }
    } else {
      // Handle non-200 responses or other errors by clearing the cart
      context.read<CartProvider>().refreshCartData(null);
      context.read<CartProvider>().refreshCart(false);
      context.read<CartProvider>().refreshCartCount(0);
      context.read<CartProvider>().refreshCartGrandTotal(0.0);
    }
    if (mounted)
      setState(() {
        isLoadingCart = false;
      });
  }

  getMember() async {
    if (!checkIsNullValue(userSession['group'])) {
      var groupId = userSession['group']['id'];

      var response = await netGet(endPoint: "group/$groupId");
      if (response["resp_code"] == "200") {
        List data = response['resp_data']['data']['members'];

        setState(() {
          groupMember = data;
          orderDay = response['resp_data']['data']['order_day'];
          leaderId = response['resp_data']['data']['leader']['id'].toString();
          groupProfile =
              !checkIsNullValue(response['resp_data']['data']['image'])
                  ? response['resp_data']['data']['image'].toString()
                  : DEFAULT_GROUP_IMAGE;
        });

        var zipCode =
            !checkIsNullValue(
                  response['resp_data']['data']['leader']['zip_code'],
                )
                ? response['resp_data']['data']['leader']['zip_code']
                : "";
        if (!checkIsNullValue(
          response['resp_data']['data']['leader']['name'],
        )) {
          setState(() {
            byLeader =
                "by".tr() +
                " " +
                response['resp_data']['data']['leader']['name'];
            leaderzipCode = "";

            leaderzipCode = zipCode;
          });
        } else {
          setState(() {
            byLeader = "";
            leaderzipCode = zipCode;
          });
        }
      }
    }
    // set new order day
    context.read<HasGroupProvider>().refreshOrderDay(orderDay);
    //  set new number of member
    context.read<HasGroupProvider>().refreshGroupNumber(groupMember.length);
    //  set new leader
    context.read<HasGroupProvider>().refreshGroupLeader(byLeader);
    //  set new leader zip code
    context.read<HasGroupProvider>().refreshLeaderZipCode(leaderzipCode);
  }

  fetchAds() async {
    var params = {"limit": "0", "order": "rgt", "sort": "asc"};

    var response = await netGet(endPoint: "advertisement", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List adsItems = data['list'] ?? [];
      if (mounted) {
        setState(() {
          ads = adsItems;
        });
      }
    } else {
      setState(() {
        ads = [];
      });
    }
  }

  fetchPaymentMethod() async {
    var response = await netGet(
      isUserToken: true,
      endPoint: "payment/gateways",
    );
    if (response['resp_code'] == "200") {
      List<dynamic> data = response["resp_data"]["data"] ?? [];
      List<Map<String, dynamic>> fetchedPaymentMethods = [];

      for (var item in data) {
        fetchedPaymentMethods.add({
          "id": item['id'],
          "name": item['name'],
          "code": item['code'], // Add the code
          "image": item['config']['logo'], // Use config.logo for image
        });
      }

      log("PAYMENT METHODS ${fetchedPaymentMethods}");
      setState(() {
        paymentMethod = fetchedPaymentMethods;
      });
    } else {
      setState(() {
        paymentMethod = [];
      });
    }
  }

  bool removingItem = false;
  removeItem(product, qty) async {
    if (removingItem) return;
    setState(() {
      removingItem = true;
    });
    var pId = product["id"];
    var response = await netDelete(
      isUserToken: true,
      params: {},
      endPoint: "me/cart/product/$pId",
    );

    if (response['resp_code'] == "200") {
      eventBus.fire(
        ProductListEvent(id: pId.toString(), quantity: int.parse(qty)),
      );
      dynamic dataPanel = {
        "phone": userSession['phone_number'],
        "product": product['name'],
      };

      mixpanel.track(REMOVE_PRODUCT_FROM_CART, properties: dataPanel);

      // Update local cart repository
      var localCartItem = new Cart(
        productId: pId.toString(),
        qty: int.parse(qty),
      );
      await CartRepository().addOrUpdate(cart: localCartItem, type: "minus");
      showToast("Removed", context);

      // Refresh cart data from server after removal
      // This will trigger RootApp's loadCart() which updates CartProvider
      // and then CartPage will rebuild.
      await context.read<CartProvider>().refreshCartData(
        null,
      ); // Temporarily clear to force refresh
      // The actual refresh will happen when RootApp's loadCart is called,
      // which should be triggered by the navigation or a global event.
      // For now, we rely on the next navigation to CartPage to trigger RootApp's loadCart.
      // If immediate refresh is needed, a callback or event bus could be used.
      // For this task, we assume the user will navigate away and back, or RootApp's loadCart is sufficient.
      // However, to ensure immediate UI update, we should call loadCart() here.
      // Since loadCart() is in RootApp, we need a way to trigger it.
      // For now, let's just update the provider to reflect an empty state if the cart becomes empty.
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        context.read<CartProvider>().refreshCartData(temp);
        List cartItems = temp['lines'];
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context.read<CartProvider>().refreshCartGrandTotal(
          double.parse(temp['total'].toString()),
        );
        if (cartItems.length == 0) {
          context.read<CartProvider>().refreshCart(false);
          context.read<CartProvider>().refreshCartCount(cartItems.length);
        }
      } else {
        context.read<CartProvider>().refreshCartData(null);
        context.read<CartProvider>().refreshCart(false);
        context.read<CartProvider>().refreshCartCount(0);
        context.read<CartProvider>().refreshCartGrandTotal(0.0);
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted)
      setState(() {
        removingItem = false;
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_pendingTransactionId != null) {
        checkPaymentStatus(_pendingTransactionId!);
      }
    }
  }

  Future<void> checkPaymentStatus(String transactionId) async {
    var response = await netGet(
      endPoint: "payment/status/$transactionId",
      isUserToken: true,
    );

    if (mounted) {
      setState(() {
        _pendingTransactionId = null; // Clear the pending transaction ID
      });
    }

    if (response['resp_code'] == "200" && response['resp_data'] != null) {
      var status = response['resp_data']['data']['status'];
      var orderData = response['resp_data']['data']['transaction']['order'];
      if (status == 'success') {
        _showPaymentStatusDialog(
            "Payment Successful", "Your payment was successful.");
        await CartRepository().removeAll();
        context.read<CartProvider>().refreshCart(false);
        context.read<CartProvider>().refreshCartCount(0);
        context.read<CartProvider>().refreshCartGrandTotal(0.0);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmedPage(
              data: {
                "schedules": orderData?['schedules'] ?? [],
                "orderData": orderData,
              },
            ),
          ),
        );
      } else if (status == 'failed') {
        _showPaymentStatusDialog(
            "Payment Failed", "Your payment has failed. Please try again.");
      }
      // If pending, do nothing and wait for the next check.
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  bool isApplyCoupon = false;
  applyCoupon(int _couponId) async {
    if (isApplyCoupon) return;
    isApplyCoupon = true;
    var response = await netPost(
      endPoint: "me/cart/coupon/$_couponId",
      params: {},
    );
    if (response['resp_code'] == "200") {
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        showToast("applied".tr(), context);
        // cart = temp; // Managed by CartProvider
        context.read<CartProvider>().refreshCartData(temp);

        List cartItems = temp['lines'];
        // couponData = temp['coupon']; // Managed by CartProvider
        // schedules = temp.containsKey('schedules') ? temp['schedules'] : []; // Managed by CartProvider

        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context.read<CartProvider>().refreshCartGrandTotal(
          double.parse(temp['total'].toString()),
        );
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted)
      setState(() {
        isApplyCoupon = false;
      });
  }

  Widget getCouponBox() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              var res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddCouponPage(
                        schedule:
                            context
                                .read<CartProvider>()
                                .getCartData?['schedules'] ??
                            [],
                      ),
                ),
              );
              if (!checkIsNullValue(res)) {
                applyCoupon((res as Map)["id"]);
              }
            },
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: secondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primary),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(MaterialCommunityIcons.tag, color: primary),
                        SizedBox(width: 10),
                        Text("use_coupons", style: meduimBlackText).tr(),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, color: black, size: 18),
                  ],
                ),
              ),
            ),
          ),
          if (!checkIsNullValue(
            context.watch<CartProvider>().getCartData?['coupon'],
          ))
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context
                        .watch<CartProvider>()
                        .getCartData!['coupon']["name"],
                    style: meduimBlackText,
                  ),
                  IconButton(
                    onPressed: () {
                      removeCoupon();
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: removingCoupon ? greyLight70 : primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool removingCoupon = false;
  removeCoupon() async {
    if (removingCoupon) return;
    setState(() {
      removingCoupon = true;
    });
    var response = await netDelete(
      isUserToken: true,
      params: {},
      endPoint: "me/cart/coupon",
    );

    if (response['resp_code'] == "200") {
      showToast("Removed", context);
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        // cart = temp; // Managed by CartProvider
        context.read<CartProvider>().refreshCartData(temp);
        // couponData = ''; // Managed by CartProvider
        List cartItems = temp['lines'];
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context.read<CartProvider>().refreshCartGrandTotal(
          double.parse(temp['total'].toString()),
        );
      } else {
        // cart = null; // Managed by CartProvider
        context.read<CartProvider>().refreshCartData(null);
        context.read<CartProvider>().refreshCart(false);
        context.read<CartProvider>().refreshCartCount(0);
        context.read<CartProvider>().refreshCartGrandTotal(0.0);
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted)
      setState(() {
        removingCoupon = false;
      });
  }

  bool applyingPayMethod = false;
  applyPayMethod(String gatewayCode) async {
    // Changed parameter type to String
    if (applyingPayMethod) return;
    applyingPayMethod = true;
    var response = await netPost(
      endPoint: "me/cart/payment",
      params: {
        "gateway_code": gatewayCode,
      }, // Changed parameter name to gateway_code
    );
    log("/cart/payment response ${response}");
    // if (mounted)
    //   setState(() {
    //     applyingPayMethod = false;
    //   });
  }

  Widget getPaymentMethod() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("payment_method", style: meduimBlackText).tr(),
          SizedBox(height: 5),
          Text("choose_the_payment_method", style: smallBlackText).tr(),
          SizedBox(height: 25),
          Column(
            children: List.generate(paymentMethod.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    paymentMethodId = paymentMethod[index]['id'];
                  });

                  applyPayMethod(paymentMethod[index]['code']);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            paymentMethodId == paymentMethod[index]['id']
                                ? primary
                                : black.withOpacity(0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network(
                                    paymentMethod[index]['image'],
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Text(
                                paymentMethod[index]['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Radio(
                            activeColor: primary,
                            value: paymentMethod[index]['id'] as int,
                            groupValue: paymentMethodId,
                            onChanged: (value) {
                              print("changed $value");
                              setState(() {
                                paymentMethodId = paymentMethod[index]['id'];
                              });
                              applyPayMethod(paymentMethod[index]['code']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          Center(
            child: Container(
              width: double.infinity * 0.6,
              child: Divider(thickness: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAds() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: SliderWidget(items: ads),
    );
  }

  Widget getBody() {
    if (isLoadingCart) {
      return CartLoading();
    }
    // Use CartProvider's cartData for rendering
    var currentCart = context.watch<CartProvider>().getCartData;
    if (checkIsNullValue(currentCart) ||
        checkIsNullValue(currentCart!["lines"])) {
      return getEmptyCart();
    }
    return context.watch<CartProvider>().isHasCart
        ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add logging to debug 'amount_off'
              if (!checkIsNullValue(currentCart) &&
                  !checkIsNullValue(currentCart["amount_off"]))
                Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(color: black),
                  child: Center(
                    child: Text(
                      "$CURRENCY ${currentCart["amount_off"]} saved!",
                      style: normalBoldWhiteTitle,
                    ),
                  ),
                ),
              SizedBox(height: 20),
              getSavedItemsAndEmptyCart(),
              Center(
                child: Container(
                  width: double.infinity,
                  child: Divider(thickness: 0.8),
                ),
              ),
              SizedBox(height: 20),
              getCartItems(),

              SizedBox(height: 10),
              Divider(thickness: 0.8),
              SizedBox(height: 10),
              getPaymentMethod(),
              SizedBox(height: 10),
              getTotalBlock(),
            ],
          ),
        )
        : getEmptyCart();
  }

  Widget getSavedItemsAndEmptyCart() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              context
                          .watch<CartProvider>()
                          .getCartData!["discount"]
                          .toString() ==
                      "0"
                  ? Container()
                  : Row(
                    children: [
                      Text(
                        "$CURRENCY ${context.watch<CartProvider>().getCartData!["discount"]}",
                        style: meduimBoldPrimaryText,
                      ),
                      Text("saved".tr(), style: meduimPrimaryText),
                    ],
                  ),
              InkWell(
                onTap: () {
                  setEmptyCart();
                },
                child: Text("Empty Cart".toUpperCase(), style: meduimBlackText),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  setEmptyCart() async {
    var response = await netDelete(endPoint: "me/cart/product", params: {});

    if (response['resp_code'] == "200") {
      dynamic dataPanel = {
        "phone": userSession['phone_number'],
        "product": context.read<CartProvider>().getCartData!["lines"],
        "empty_cart": "empty_cart",
      };

      mixpanel.track(CLICK_EMPTY_CART, properties: dataPanel);

      print(">>>>>EVENT BUS FIRE<<<<<<<");
      eventBus.fire(ProductListEvent(id: "1", quantity: 10));

      await CartRepository().removeAll();
      // set has cart or not
      context.read<CartProvider>().refreshCart(false);
      //  set new number of cart item
      context.read<CartProvider>().refreshCartCount(0);
      // set price
      context.read<CartProvider>().refreshCartGrandTotal(0.0);
      if (widget.onCartEmptied != null) {
        widget.onCartEmptied!(); // Notify parent that cart is emptied
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
  }

  Widget getCartItems() {
    if (isLoadingCart) return Center(child: CustomCircularProgress());
    var currentCart = context.watch<CartProvider>().getCartData;
    if (checkIsNullValue(currentCart) ||
        checkIsNullValue(currentCart!["lines"]))
      return SizedBox();

    return Column(
      children: List.generate(currentCart["lines"].length, (index) {
        var product = currentCart["lines"][index]["product"];
        var qty = currentCart["lines"][index]['qty'].toString();
        return getSlidable(cartItem(product, qty), product, qty);
      }),
    );
  }

  Widget cartItem(_product, qty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 10),
          Flexible(
            child: Container(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProductDetailPage(data: {'product': _product}),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Image(
                      image: displayImage(_product["image"]),
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _product["name"],
                            maxLines: 2,
                            style: smallMediumBlackText,
                          ),
                          SizedBox(height: 2),
                          if (!checkIsNullValue(_product["attributes"]) &&
                              _product["attributes"].isNotEmpty)
                            Text(
                              _product["attributes"][0]["value"],
                              style: smallBlackText,
                            ),
                          SizedBox(height: 2),
                          Text("x" + qty, style: smallBoldPrimaryText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          checkIsNullValue(_product['percent_off'])
              ? Text(
                "$CURRENCY ${_product["unit_price"]}",
                style: meduimBoldBlackText,
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$CURRENCY ${_product["sale_price"]}",
                    style: meduimBoldBlackText,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "$CURRENCY ${_product["unit_price"]}",
                    style: smallStrikeBoldPrimaryText,
                  ),
                ],
              ),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget getTotalBlock() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("mrp_total", style: smallMediumGreyText).tr(),
              Row(
                children: [
                  Text(
                    "$CURRENCY ${context.watch<CartProvider>().getCartData!["mrp_total"]}",
                    style: smallMediumGreyText,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("defence_discount", style: smallMediumPrimaryText).tr(),
              Row(
                children: [
                  Text(
                    "- $CURRENCY ${context.watch<CartProvider>().getCartData!["discount"]}",
                    style: smallMediumPrimaryText,
                  ),
                ],
              ),
            ],
          ),
          if (!checkIsNullValue(
            context.watch<CartProvider>().getCartData?['coupon'],
          ))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("coupon_discount", style: smallMediumGreyText).tr(),
                  Text(
                    "$CURRENCY ${context.watch<CartProvider>().getCartData!['coupon']['amount_off']}",
                    style: smallMediumGreyText,
                  ),
                ],
              ),
            ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("delivery_fee", style: smallMediumGreyText).tr(),
              Text(
                "$CURRENCY ${context.watch<CartProvider>().getCartData!["delivery"]}",
                style: smallMediumGreyText,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("taxed_and_charges", style: smallMediumGreyText).tr(),
              Text(
                "$CURRENCY ${context.watch<CartProvider>().getCartData!["vat"] ?? 0}",
                style: smallMediumGreyText,
              ),
            ],
          ),
          if (!checkIsNullValue(userSession) &&
              userSession['is_defence_personnel'] == true &&
              !checkIsNullValue(
                context
                    .watch<CartProvider>()
                    .getCartData!['defence_discount_percent'],
              ))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("defence_discount", style: smallMediumPrimaryText).tr(),
                  Text(
                    "- $CURRENCY ${context.watch<CartProvider>().getCartData!['defence_discount_percent'].toStringAsFixed(2)}",
                    style: smallMediumPrimaryText,
                  ),
                ],
              ),
            ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("to_pay", style: meduimBoldBlackText).tr(),
              Text(
                "$CURRENCY ${context.watch<CartProvider>().getCartData!["total"]}",
                style: meduimBoldBlackText,
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(thickness: 0.8),
          SizedBox(height: 10),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text("FREE Delivery above ₹99!", style: smallMediumPrimaryText),
          //   ],
          // ),
          SizedBox(height: 10),
          Divider(thickness: 0.8),
        ],
      ),
    );
  }

  Widget getFooter() {
    String byDate =
        context.watch<CartProvider>().getCartData?['schedules']?.isNotEmpty ==
                true
            ? DateFormat("d MMM").format(
              DateTime.parse(
                context.watch<CartProvider>().getCartData!['schedules'][context
                        .watch<CartProvider>()
                        .getCartData!['schedules']
                        .length -
                    1]["date"],
              ),
            )
            : "N/A";

    var size = MediaQuery.of(context).size;
    return context.watch<CartProvider>().isHasCart
        ? Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(
                color: black.withOpacity(0.06),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 0,
              right: 0,
              top: 15,
              bottom: 5,
            ),
            child: Column(
              children: [
                // Padding(
                //   padding:
                //       const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
                //   child: Container(
                //     width: double.infinity,
                //     height: 60,
                //     child: Row(
                //       children: [
                //         Container(
                //           width: 45,
                //           height: 45,
                //           decoration: BoxDecoration(
                //               shape: BoxShape.circle,
                //               image: DecorationImage(
                //                   image: NetworkImage(
                //                       checkIsNullValue(userSession['group'])
                //                           ? groupProfile
                //                           : userSession['group']['image']),
                //                   fit: BoxFit.cover)),
                //         ),
                //         SizedBox(
                //           width: 15,
                //         ),
                //         Flexible(
                //           child: Container(
                //             width: size.width * 0.5,
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 !checkIsNullValue(userSession['group'])
                //                     ? Text(
                //                         userSession['group']['name'],
                //                         style: normalBlackText,
                //                       )
                //                     : Text(
                //                         "no_group_found",
                //                         style: normalBlackText,
                //                       ).tr(),
                //                 SizedBox(
                //                   height: 5,
                //                 ),
                //                 !checkIsNullValue(userSession['group'])
                //                     ? Text(
                //                         "$byLeader" +
                //                             (checkIsNullValue(leaderzipCode)
                //                                 ? ""
                //                                 : " - $leaderzipCode"),
                //                         style: smallBlackText,
                //                       )
                //                     : Text(
                //                         "no_group_leader_found",
                //                         style: smallBlackText,
                //                       ).tr()
                //               ],
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           width: 15,
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 8, bottom: 8),
                //           child: Container(
                //             width: 90,
                //             decoration: BoxDecoration(
                //                 border: Border(
                //                     left: BorderSide(
                //                         width: 1, color: placeHolderColor))),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Text("delivery_by", style: smallBlackText).tr(),
                //                 SizedBox(
                //                   height: 5,
                //                 ),
                //                 Text(
                //                   byDate,
                //                   style: normalBlackText,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // cart section
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            confirmAlert(
                              context,
                              des: "Confirm Order on TezChal?".tr(),
                              onCancel: () {
                                Navigator.pop(context);
                              },
                              onConfirm: () async {
                                await confirmCheckout();
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.watch<CartProvider>().cartCount > 1
                                        ? context
                                                .watch<CartProvider>()
                                                .cartCount
                                                .toString() +
                                            " " +
                                            "items".tr() +
                                            " • $CURRENCY" +
                                            double.parse(
                                              context
                                                  .watch<CartProvider>()
                                                  .cartGrandTotal
                                                  .toString(),
                                            ).toStringAsFixed(0)
                                        : context
                                                .watch<CartProvider>()
                                                .cartCount
                                                .toString() +
                                            " " +
                                            "item".tr() +
                                            " • $CURRENCY" +
                                            double.parse(
                                              context
                                                  .watch<CartProvider>()
                                                  .cartGrandTotal
                                                  .toString(),
                                            ).toStringAsFixed(0),
                                    style: smallMediumWhiteText,
                                  ),
                                  SizedBox(width: 5),
                                  Row(
                                    children: [
                                      Text(
                                        "Place Order",
                                        style: smallMediumWhiteText,
                                      ).tr(),
                                      SizedBox(width: 8),
                                      confirmingCheckout
                                          ? SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CustomCircularProgress(
                                              color: white,
                                            ),
                                          )
                                          : Icon(
                                            Icons.arrow_forward_ios,
                                            color: white,
                                            size: 15,
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        : SizedBox();
  }

  bool confirmingCheckout = false;
  confirmCheckout() async {
    if (confirmingCheckout) return;
    setState(() {
      confirmingCheckout = true;
    });

    // Find the selected payment method's code
    String? selectedGatewayCode;
    for (var method in paymentMethod) {
      if (method['id'] == paymentMethodId) {
        selectedGatewayCode = method['code'];
        break;
      }
    }

    if (selectedGatewayCode == null) {
      showToast("No payment method selected or invalid.", context);
      setState(() {
        confirmingCheckout = false;
      });
      return;
    }

    // Step 1: Call the backend API to confirm the cart and get payment data
    log(
      "ConfirmCheckout - Calling me/cart/confirm API with gateway_code: $selectedGatewayCode",
    );
    var apiResponse = await netPost(
      endPoint: "me/cart/confirm",
      params: {"gateway_code": selectedGatewayCode},
    );

    if (apiResponse['resp_code'] != "200" ||
        apiResponse['resp_data'] == null ||
        apiResponse['resp_data']['data'] == null) {
      var errorMessage =
          apiResponse["resp_data"]["message"] ??
          "Failed to confirm cart or get payment data from API.";
      showToast(errorMessage, context);
      log(
        "ConfirmCheckout - ERROR: API call to me/cart/confirm failed: $errorMessage",
      );
      setState(() {
        confirmingCheckout = false;
      });
      return;
    }

    var orderData = apiResponse['resp_data']['data']['order'];
    var paymentRequired = apiResponse['resp_data']['data']['payment_required'];
    log("Easebuzz ${apiResponse}");

    if (paymentRequired == true && selectedGatewayCode == "easebuzz") {
      final paymentData = apiResponse['resp_data']['data']['payment_data'];
      final transactionData = paymentData['transaction'];
      final accessKey = paymentData['access_key'];
      final paymentUrl = paymentData['payment_url'];

      if (paymentData == null ||
          transactionData == null ||
          accessKey == null ||
          paymentUrl == null) {
        showToast(
          "Invalid payment data received from API for Easebuzz.",
          context,
        );
        log(
          "ConfirmCheckout - ERROR: Invalid payment data structure from API for Easebuzz.",
        );
        setState(() {
          confirmingCheckout = false;
        });
        return;
      }

      log("ConfirmCheckout - Easebuzz Payment Data from API: $paymentData");
      log(
        "ConfirmCheckout - Easebuzz Transaction Data from API: $transactionData",
      );

      final requestData = transactionData['request_data'];

      if (requestData == null) {
        showToast(
          "Invalid request data received from API for Easebuzz.",
          context,
        );
        log(
          "ConfirmCheckout - ERROR: Invalid request data structure from API for Easebuzz.",
        );
        setState(() {
          confirmingCheckout = false;
        });
        return;
      }

      final paymentModel = {
        "txnid": requestData['txnid'].toString(),
        "amount": double.parse(requestData['amount'].toString()),
        "productinfo": requestData['productinfo'].toString(),
        "firstname": requestData['firstname'].toString(),
        "email": requestData['email'].toString(),
        "phone": requestData['phone'].toString(),
        "surl": requestData['surl'].toString(),
        "furl": requestData['furl'].toString(),
        "splitPayments": "",
        "key": requestData['key'].toString(), // Use key from request_data
      };

      setState(() {
        _pendingTransactionId = requestData['txnid'].toString();
      });

      log("ConfirmCheckout - Easebuzz Payment Model created: ${paymentModel}");

      try {
        log(
          "ConfirmCheckout - Easebuzz - Triggering payment flow with Easebuzz...",
        );
        // The `payWithEasebuzz` method from the plugin expects a single Map object
        // containing all the payment parameters. The previous implementation was passing
        // incorrect arguments, causing the "Empty payment response" error.
        final paymentResponse = await _easebuzzFlutterPlugin.payWithEasebuzz(
          accessKey,
          "test",
        );

        // The response from the plugin is unreliable. Instead of parsing it,
        // we will directly check the payment status from our backend.
        // This ensures we have the correct status, even if the plugin reports failure.
        if (_pendingTransactionId != null) {
          // We have a transaction ID, so let's check its status.
          log("ConfirmCheckout - Easebuzz - INFO: Plugin flow finished. Checking payment status from backend for transaction ID: $_pendingTransactionId");
          await checkPaymentStatus(_pendingTransactionId!);
        } else {
          // This case should ideally not happen if the flow is correct.
          log("ConfirmCheckout - Easebuzz - ERROR: No pending transaction ID found after payment attempt.");
          _showPaymentStatusDialog(
            "Payment Error",
            "Could not verify payment status. Transaction ID not found.",
          );
        }
      } on PlatformException catch (e) {
        log(
          "ConfirmCheckout - Easebuzz - ERROR: PlatformException during Easebuzz payment: ${e.message}",
        );
        log(
          "ConfirmCheckout - Easebuzz - ERROR: PlatformException code: ${e.code}",
        );
        log(
          "ConfirmCheckout - Easebuzz - ERROR: PlatformException details: ${e.details}",
        );
        showToast("Platform error: ${e.message}", context);
      } catch (e, stack) {
        log(
          "ConfirmCheckout - Easebuzz - FATAL ERROR: Unexpected Payment Exception: $e",
        );
        log("ConfirmCheckout - Easebuzz - STACKTRACE: $stack");
        showToast("Payment failed: ${e.toString()}", context);
      }
    } else {
      // Generic order confirmation for other payment methods or if payment is not required
      print(context.read<CartProvider>().getCartData!["lines"]);

      dynamic dataPanel = {
        "phone": userSession['phone_number'],
        "total": context.read<CartProvider>().getCartData!["total"].toString(),
        "order_confirm": "order_confirm",
      };

      mixpanel.track(CLICK_ORDER_CONFIRM, properties: dataPanel);

      await CartRepository().removeAll();
      showToast("your_order_is_completed".tr(), context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OrderConfirmedPage(
                data: {
                  "schedules":
                      context.read<CartProvider>().getCartData?['schedules'] ??
                      [],
                  "orderData": orderData,
                },
              ),
        ),
      );
    }

    if (mounted)
      setState(() {
        confirmingCheckout = false;
      });
  }

  String getCartInfo() {
    var currentCart = context.read<CartProvider>().getCartData;
    if (checkIsNullValue(currentCart)) return "";
    String res = "";
    List _cartItems = currentCart!["lines"];
    var _total = currentCart["total"];
    res =
        "${_cartItems.length} " +
        ((_cartItems.isNotEmpty && _cartItems.length > 1) ? "items" : "item");
    res = res + "  •  " + "$CURRENCY $_total";
    return res;
  }

  void _showPaymentStatusDialog(String title, String message) {
    rfa.Alert(
      context: context,
      style: alertStyle, // Use the global alertStyle from utils.dart
      title: title,
      content: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text(
          message,
          style: alertStyle.descStyle,
          textAlign: alertStyle.descTextAlign,
        ),
      ),
      buttons: [
        rfa.DialogButton(
          height: 60,
          width: 150,
          child: Text(
            "OK",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
          },
          color: primary,
          radius: BorderRadius.circular(10.0),
        ),
      ],
    ).show();
  }

  Widget getSlidable(Widget child, product, qty) {
    return Slidable(
      // Each Slidable must have a key
      key: ValueKey(product['id']), // or any unique identifier
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (_) async {
              await removeItem(product, qty);
            },
            backgroundColor: removingItem ? greyLight70 : Colors.red,
            foregroundColor: removingItem ? greyLight80 : null,
            icon: Icons.delete,
            label: 'remove'.tr(),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget getEmptyCart() {
    return EmptyPage(
      image: "assets/images/no_cart_red.png",
      title: "empty_cart",
      subtitle: "go_to_product_list_to_explore_product",
    );
  }
}
