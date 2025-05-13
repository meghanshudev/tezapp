import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tez_mobile/event/ProductListEvent.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/models/cart.dart';
import 'package:tez_mobile/provider/cart_provider.dart';
import 'package:tez_mobile/provider/has_group.dart';
import 'package:tez_mobile/respositories/cart/cart_repository.dart';
import 'package:tez_mobile/ui_elements/cart_loading.dart';
import 'package:tez_mobile/ui_elements/custom_appbar.dart';
import 'package:tez_mobile/ui_elements/custom_circular_progress.dart';
import 'package:tez_mobile/ui_elements/slider_widget.dart';

import '../../helpers/constant.dart';
import '../../helpers/network.dart';
import '../../helpers/utils.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool checkSendToWhatsApp = true;
  bool isLoadingCart = false;
  var cart;
  List paymentMethod = [];
  int paymentMethodId = 0;
  List schedules = [];
  List ads = [];

  double deliveryFee = 0;

  var couponData;

  // group
  List groupMember = [];
  int orderDay = 0;
  String byLeader = '';
  String leaderId = '';
  String leaderzipCode = '';

  String groupProfile = '';

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initPage();

    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false);
  }

  initPage() async {
    await loadCart();
    await fetchAds();
    await fetchPaymentMethod();
    await getMember();
  }

  loadCart() async {
    if (isLoadingCart) return;
    isLoadingCart = true;
    var response = await netGet(isUserToken: true, endPoint: "me/cart");
    print(response);
    if (response['resp_code'] == "200") {
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        cart = temp;

        List cartItems = cart['lines'];
        couponData = cart.containsKey('coupon') ? cart['coupon'] : null;
        paymentMethodId = checkIsNullValue(cart['payment_type'])
            ? 0
            : cart['payment_type']['id'];
        schedules = cart.containsKey('schedules') ? cart['schedules'] : [];

        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context
            .read<CartProvider>()
            .refreshCartGrandTotal(double.parse(cart['total'].toString()));
      }
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

        var zipCode = !checkIsNullValue(
                response['resp_data']['data']['leader']['zip_code'])
            ? response['resp_data']['data']['leader']['zip_code']
            : "";
        if (!checkIsNullValue(
            response['resp_data']['data']['leader']['name'])) {
          setState(() {
            byLeader = "by".tr() +
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
    var response = await netGet(isUserToken: true, endPoint: "payment/type");
    if (response['resp_code'] == "200") {
      var data = response["resp_data"]["data"];
      List paymentMethodItem = data['list'] ?? [];
      setState(() {
        paymentMethod = paymentMethodItem;
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
        isUserToken: true, params: {}, endPoint: "me/cart/product/$pId");

    if (response['resp_code'] == "200") {
      eventBus
          .fire(ProductListEvent(id: pId.toString(), quantity: int.parse(qty)));
      dynamic dataPanel = {
        "phone": userSession['phone_number'],
        "product": product['name']
      };

      mixpanel.track(REMOVE_PRODUCT_FROM_CART, properties: dataPanel);

      cart = new Cart(productId: pId.toString(), qty: int.parse(qty));
      await CartRepository().addOrUpdate(cart: cart, type: "minus");
      showToast("Removed", context);
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        cart = temp;

        List cartItems = cart['lines'];
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context
            .read<CartProvider>()
            .refreshCartGrandTotal(double.parse(cart['total'].toString()));
        if (cartItems.length == 0) {
          context.read<CartProvider>().refreshCart(false);
          //  set new number of cart item
          context.read<CartProvider>().refreshCartCount(cartItems.length);
        }
      } else {
        cart = null;

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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomAppBar(
            subtitle: "your_cart".tr(),
          ),
        ),
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
        cart = temp;

        List cartItems = cart['lines'];
        couponData = cart['coupon'];
        schedules = cart.containsKey('schedules') ? cart['schedules'] : [];

        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context
            .read<CartProvider>()
            .refreshCartGrandTotal(double.parse(cart['total'].toString()));
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
              var res = await Navigator.pushNamed(context, "/add_coupon_page",
                  arguments: {
                    "schedule": schedules,
                  });
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
                        Icon(
                          MaterialCommunityIcons.tag,
                          color: primary,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "use_coupons",
                          style: meduimBlackText,
                        ).tr()
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: black,
                      size: 18,
                    )
                  ],
                ),
              ),
            ),
          ),
          if (!checkIsNullValue(couponData))
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    couponData["name"],
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
                  )
                ],
              ),
            )
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
        isUserToken: true, params: {}, endPoint: "me/cart/coupon");

    if (response['resp_code'] == "200") {
      showToast("Removed", context);
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        cart = temp;
        couponData = '';
        List cartItems = cart['lines'];
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context
            .read<CartProvider>()
            .refreshCartGrandTotal(double.parse(cart['total'].toString()));
      } else {
        cart = null;

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
  applyPayMethod(int _paymentId) async {
    if (applyingPayMethod) return;
    applyingPayMethod = true;
    var response = await netPost(
      endPoint: "me/cart/payment",
      params: {"payment_type_id": _paymentId},
    );
    print(response);
    if (mounted)
      setState(() {
        applyingPayMethod = false;
      });
  }

  Widget getPaymentMethod() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "payment_method",
            style: meduimBlackText,
          ).tr(),
          SizedBox(
            height: 5,
          ),
          Text(
            "choose_the_payment_method",
            style: smallBlackText,
          ).tr(),
          SizedBox(
            height: 25,
          ),
          Column(
            children: List.generate(paymentMethod.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    paymentMethodId = paymentMethod[index]['id'];
                  });

                  applyPayMethod(paymentMethodId);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: paymentMethodId == paymentMethod[index]['id']
                                ? primary
                                : black.withOpacity(0.5))),
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
                                decoration:
                                    BoxDecoration(shape: BoxShape.circle),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network(
                                      paymentMethod[index]['image']),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                paymentMethod[index]['name'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                              applyPayMethod(paymentMethodId);
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
              child: Divider(
                thickness: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAds() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: SliderWidget(
        items: ads,
      ),
    );
  }

  Widget getBody() {
    if (isLoadingCart)
      // return Center(
      //   child: CustomCircularProgress(),
      // );
      return CartLoading();
    // if (checkIsNullValue(cart) || checkIsNullValue(cart["lines"]))
    //   return getEmptyCart();
    return context.watch<CartProvider>().isHasCart
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // checkIsNullValue(userSession['group'])
                //     ? Column(
                //         children: [
                //           SizedBox(
                //             height: 15,
                //           ),
                //           getAds(),
                //         ],
                //       )
                //     : Container(),
                if (!checkIsNullValue(cart["amount_off"]))
                  Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(color: black),
                    child: Center(
                      child: Text("$CURRENCY ${cart["amount_off"]} saved!",
                          style: normalBoldWhiteTitle),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                getSavedItemsAndEmptyCart(),
                Center(
                  child: Container(
                    width: double.infinity,
                    child: Divider(
                      thickness: 0.8,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                getCartItems(),

                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 0.8,
                ),
                SizedBox(
                  height: 10,
                ),
                getPaymentMethod(),
                SizedBox(
                  height: 10,
                ),
                // getDeliveryParter(),
                // SizedBox(
                //   height: 15,
                // ),
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
          SizedBox(
            height: 0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              cart["discount"].toString() == "0"
                  ? Container()
                  : Row(
                      children: [
                        Text(
                          "$CURRENCY ${cart["discount"]}",
                          style: meduimBoldPrimaryText,
                        ),
                        Text("saved".tr(), style: meduimPrimaryText)
                      ],
                    ),
              InkWell(
                  onTap: () {
                    setEmptyCart();
                  },
                  child: Text(
                    "Empty Cart".toUpperCase(),
                    style: meduimBlackText,
                  ))
            ],
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  setEmptyCart() async {
    var response = await netDelete(
      endPoint: "me/cart/product",
      params: {},
    );

    if (response['resp_code'] == "200") {
      dynamic dataPanel = {
        "phone": userSession['phone_number'],
        "product": cart["lines"],
        "empty_cart": "empty_cart"
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
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
  }

  Widget getCartItems() {
    if (isLoadingCart)
      return Center(
        child: CustomCircularProgress(),
      );
    if (checkIsNullValue(cart) || checkIsNullValue(cart["lines"]))
      return SizedBox();

    return Column(
      children: List.generate(cart["lines"].length, (index) {
        var product = cart["lines"][index]["product"];
        var qty = cart["lines"][index]['qty'].toString();
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
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: Container(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, "/product_detail_page",
                      arguments: {"product": _product});
                },
                child: Row(
                  children: [
                    Image(
                      image: displayImage(_product["image"]),
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      width: 5,
                    ),
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
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            _product["attributes"][0]["value"],
                            style: smallBlackText,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            "x" + qty,
                            style: smallBoldPrimaryText,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
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
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      "$CURRENCY ${_product["unit_price"]}",
                      style: smallStrikeBoldPrimaryText,
                    )
                  ],
                ),
          SizedBox(
            width: 10,
          ),
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
              Text(
                "mrp_total",
                style: smallMediumGreyText,
              ).tr(),
              Row(
                children: [
                  Text(
                    "$CURRENCY ${cart["mrp_total"]}",
                    style: smallMediumGreyText,
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "discount",
                style: smallMediumPrimaryText,
              ).tr(),
              Row(
                children: [
                  Text(
                    "- $CURRENCY ${cart["discount"]}",
                    style: smallMediumPrimaryText,
                  ),
                ],
              )
            ],
          ),
          if (!checkIsNullValue(couponData))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "coupon_discount",
                    style: smallMediumGreyText,
                  ).tr(),
                  Text(
                    "$CURRENCY ${couponData['amount_off']}",
                    style: smallMediumGreyText,
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "delivery_fee",
                style: smallMediumGreyText,
              ).tr(),
              Text(
                "$CURRENCY ${cart["delivery"]}",
                style: smallMediumGreyText,
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "taxed_and_charges",
                style: smallMediumGreyText,
              ).tr(),
              Text(
                "$CURRENCY ${cart["vat"]}",
                style: smallMediumGreyText,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "to_pay",
                style: meduimBoldBlackText,
              ).tr(),
              Text(
                "$CURRENCY ${cart["total"]}",
                style: meduimBoldBlackText,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 0.8,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "FREE Delivery above ₹500!",
                style: smallMediumPrimaryText,
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 0.8,
          ),
        ],
      ),
    );
  }

  Widget getFooter() {
    String byDate = !checkIsNullValue(schedules.length)
        ? DateFormat("d MMM")
            .format(DateTime.parse(schedules[schedules.length - 1]["date"]))
        : "N/A";

    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.06),
            spreadRadius: 5,
            blurRadius: 10,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 15, bottom: 5),
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
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: black.withOpacity(0.06),
                            spreadRadius: 5,
                            blurRadius: 10)
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(cart);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  context.watch<CartProvider>().isHasCart
                      ? Flexible(
                          child: InkWell(
                          onTap: () {
                            confirmAlert(context,
                                des: "Confirm Order on Tez?".tr(),
                                onCancel: () {
                              Navigator.pop(context);
                            }, onConfirm: () async {
                              await confirmCheckout();
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primary,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
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
                                            double.parse(context
                                                    .watch<CartProvider>()
                                                    .cartGrandTotal
                                                    .toString())
                                                .toStringAsFixed(0)
                                        : context
                                                .watch<CartProvider>()
                                                .cartCount
                                                .toString() +
                                            " " +
                                            "item".tr() +
                                            " • $CURRENCY" +
                                            double.parse(context
                                                    .watch<CartProvider>()
                                                    .cartGrandTotal
                                                    .toString())
                                                .toStringAsFixed(0),
                                    style: smallMediumWhiteText,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Place Order",
                                        style: smallMediumWhiteText,
                                      ).tr(),
                                      SizedBox(
                                        width: 8,
                                      ),
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
                                            )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ))
                      : Flexible(
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: white,
                                boxShadow: [
                                  BoxShadow(
                                      color: black.withOpacity(0.06),
                                      spreadRadius: 5,
                                      blurRadius: 10)
                                ]),
                            child: Center(
                              child: Text(
                                "cart_empty_start_shopping",
                                style: normalGreyText,
                              ).tr(),
                            ),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool confirmingCheckout = false;
  confirmCheckout() async {
    if (confirmingCheckout) return;
    setState(() {
      confirmingCheckout = true;
    });
    var response = await netPost(
      endPoint: "me/cart/confirm",
      params: {},
    );

    if (response['resp_code'] == "200") {
      print(cart["lines"]);

      dynamic dataPanel = {
        "phone": userSession['phone_number'],
        "total": cart["total"].toString(),
        "order_confirm": "order_confirm"
      };

      mixpanel.track(CLICK_ORDER_CONFIRM, properties: dataPanel);

      await CartRepository().removeAll();
      var temp = response["resp_data"]["data"];
      showToast("your_order_is_completed".tr(), context);
      Navigator.pushNamed(context, "/order_confirmed_page",
          arguments: {"schedules": schedules, "orderData": temp});
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted)
      setState(() {
        confirmingCheckout = false;
      });
  }

  String getCartInfo() {
    if (checkIsNullValue(cart)) return "";
    String res = "";
    List _cartItems = cart["lines"];
    var _total = cart["total"];
    res = "${_cartItems.length} " +
        ((_cartItems.isNotEmpty && _cartItems.length > 1) ? "items" : "item");
    res = res + "  •  " + "$CURRENCY $_total";
    return res;
  }

  final SlidableController slidableController = SlidableController();
  Widget getSlidable(Widget child, product, qty) {
    return Slidable(
      controller: slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.2,
      child: child,
      secondaryActions: <Widget>[
        IconSlideAction(
          color: removingItem ? greyLight70 : Colors.red,
          foregroundColor: removingItem ? greyLight80 : null,
          caption: 'remove'.tr(),
          icon: Icons.delete,
          onTap: () async {
            await removeItem(product, qty);
          },
        ),
      ],
    );
  }

  Widget getEmptyCart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200 / 2)),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(color: white, shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  child: Image.asset("assets/images/no_cart_red.png"),
                ),
              ),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            Text(
              "empty_cart",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: black.withOpacity(0.5)),
            ).tr(),
            SizedBox(
              height: 10,
            ),
            Text(
              "go_to_product_list_to_explore_product",
              style: TextStyle(
                color: black.withOpacity(0.5),
              ),
            ).tr(),
            SizedBox(
              height: 10,
            ),
          ],
        )
      ],
    );
  }
}
