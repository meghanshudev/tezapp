import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Cart/cart_page.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/product_detail_loading.dart';
import 'package:tezchal/ui_elements/product_item_network.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/network.dart';
import '../../provider/cart_provider.dart';
import '../../ui_elements/add_to_cart_button_item.dart';

// ignore: must_be_immutable
class ProductDetailPage extends StatefulWidget {
  ProductDetailPage({Key? key, required this.data}) : super(key: key);
  final data;

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  var groupProduct;
  List products = [];
  int productId = 0;
  bool isLoading = false;
  bool isAddingCart = false;
  List recommendedProducts = [];

  var zipCode = '';
  var deliverTo = '';

  bool isInPage = true;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initPage();

    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code']
            : "";
    initailize();
    initMixpanel();
  }

  initailize() {
    eventBus.on().listen((event) async {
      if (!isInPage) {
        List temp = products;
        setState(() {
          products = [];
        });
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          products = temp;
        });
      }
    });
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(
      MIX_PANEL,
      optOutTrackingDefault: false,
      trackAutomaticEvents: true,
    );
  }

  initPage() async {
    productId = widget.data["product"]["id"];
    await loadProductDetail(productId);
    await fetchRecommendedProduct();
  }

  loadProductDetail(int _productId) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    var response = await netGet(
      isUserToken: true,
      endPoint: "product/$_productId",
    );
    if (response['resp_code'] == "200") {
      groupProduct = response['resp_data']['data'];
      products = groupProduct["products"];
    } else {
      print(response);
    }
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  addProductToCart(int _productId) async {
    if (isAddingCart) return;
    setState(() {
      isAddingCart = true;
    });
    var response = await netPatch(
      isUserToken: true,
      endPoint: "me/cart/product",
      params: {"product_id": _productId, "qty": 1},
    );
    if (response['resp_code'] == "200") {
      showToast("Added", context);
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        var cart = temp;
        List cartItems = cart['lines'];
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context.read<CartProvider>().refreshCartGrandTotal(
          double.parse(cart['total'].toString()),
        );
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted)
      setState(() {
        isAddingCart = false;
      });
  }

  fetchRecommendedProduct() async {
    setState(() {
      isLoading = true;
    });
    var params = {
      "page": "1",
      "limit": "10",
      "order": "random",
      "sort": "asc",
      "sub_category_id": groupProduct['category']['id'].toString(),
      "exclude_id": productId.toString(),
    };

    var response = await netGet(
      isUserToken: true,
      endPoint: "product",
      params: params,
    );

    if (response['resp_code'] == "200") {
      if (mounted) {
        setState(() {
          isLoading = false;
          recommendedProducts = response['resp_data']['data']['list'];
        });
      }
    } else {
      setState(() {
        isLoading = false;
        recommendedProducts = [];
      });
    }
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
            subtitle: "$zipCode - $deliverTo ",
            subtitleIcon: Entypo.location_pin,
            onOpenSearch: () {
              setState(() {
                isInPage = false;
              });
            },
            onCloseSearch: () {
              setState(() {
                isInPage = true;
              });
            },
          ),
        ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  shareOrderonWhatsapp() async {
    String text =
        "Hi! I have just ordered my Kirana from Tez app! It has offers and discounts on more than 5,000 products. Download now: $PLAY_STORE_LINK";
    if (Platform.isIOS) {
      if (await canLaunch(WHATSAPP_IOS_URL)) {
        await launch(WHATSAPP_IOS_URL + "&text=${Uri.encodeFull(text)}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("whatsapp_not_installed".tr())),
        );
      }
    } else {
      if (await canLaunch(WHATSAPP_ANDROID_URL)) {
        await launch(WHATSAPP_ANDROID_URL + "&text=" + Uri.encodeFull(text));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("whatsapp_not_installed".tr())),
        );
      }
    }
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "share_order_whatsapp": "share_order_whatsapp",
    };

    mixpanel.track(CLICK_SHARE_ORDER_WHATSAPP, properties: dataPanel);
  }

  Widget getBody() {
    return isLoading
        // ? Center(child: CustomCircularProgress())
        ? ProductDetailLoading()
        : products.isEmpty
        ? Container()
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: displayImage(products.first["image"]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        LineIcons.whatSApp,
                        color: Color.fromRGBO(68, 192, 82, 1),
                      ),
                      onPressed: () => shareOrderonWhatsapp(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(products.first["name"], style: normalBlackText),
                    SizedBox(height: 5),
                    Text(
                      products.first["attributes"][0]["value"],
                      style: smallBlackText,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            checkIsNullValue(products.first["percent_off"])
                                ? Text(
                                  CURRENCY + "${products.first["unit_price"]}",
                                  style: normalBoldBlackTitle,
                                )
                                : Row(
                                  children: [
                                    Text(
                                      CURRENCY +
                                          "${products.first["sale_price"]}",
                                      style: normalBoldBlackTitle,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      CURRENCY +
                                          "${products.first["unit_price"]}",
                                      style: smallStrikeBoldBlackText,
                                    ),
                                  ],
                                ),
                            SizedBox(width: 10),
                            (!checkIsNullValue(products.first["percent_off"]) &&
                                    products.first["percent_off"] > 0)
                                ? Container(
                                  width: 80,
                                  height: 25,
                                  margin: EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${products.first['percent_off']}% " +
                                          "off".tr(),
                                      style: smallBoldWhiteText,
                                    ),
                                  ),
                                )
                                : Container(
                                  width: 72,
                                  height: 25,
                                  margin: EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "popular".tr(),
                                      style: smallBoldWhiteText,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                        AddToCardButtonItem(product: products.first),
                      ],
                    ),
                  ],
                ),
              ),
              getProductAttributes(),
              Divider(thickness: 0.8),
              SizedBox(height: 20),
              getRelatedProducts(),
            ],
          ),
        );
  }

  getProductAttributes() {
    if (checkIsNullValue(products) || products.length <= 1)
      return SizedBox(height: 25);

    List<Widget> tempProducts = [];
    for (int i = 1; i < products.length; i++) {
      tempProducts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20, right: 10),
          child: getAttributeItme(products[i]),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 30, bottom: 25),
        child: Row(children: tempProducts),
      ),
    );
  }

  Widget getAttributeItme(_product) {
    var _attribute = _product["attributes"];
    return Container(
      margin: EdgeInsets.only(right: 20),
      width: 200,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
          top: 10,
          bottom: 10,
          left: 15,
          right: 15,
        ),
        child: Row(
          children: [
            Flexible(
              flex: 4,
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _attribute.isNotEmpty ? _attribute[0]["value"] : "N/A",
                      style: meduimBlackText,
                    ),
                    checkIsNullValue(_product['percent_off'])
                        ? Text(
                          CURRENCY + "${_product['unit_price']}",
                          style: smallMediumBoldBlackText,
                        )
                        : Row(
                          children: [
                            Text(
                              CURRENCY + "${_product['sale_price']}",
                              style: smallMediumBoldBlackText,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                CURRENCY + "${_product['unit_price']}",
                                style: smallStrikeBoldBlackText,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
            Flexible(flex: 3, child: AddToCardButtonItem(product: _product)),
          ],
        ),
      ),
    );
  }

  getRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        recommendedProducts.length != 0
            ? Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child:
                  Text("you_might_also_like", style: normalBoldBlackTitle).tr(),
            )
            : Container(),
        SingleChildScrollView(
          padding: EdgeInsets.only(left: 20),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(recommendedProducts.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20, top: 25, bottom: 40),
                child: GestureDetector(
                  onTap: () async {
                    dynamic dataPanel = {
                      "phone": userSession['phone_number'],
                      "product": recommendedProducts[index]['product']['name'],
                    };

                    mixpanel.track(CLICK_PRODUCT, properties: dataPanel);
                    setState(() {
                      isInPage = false;
                    });
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductDetailPage(
                              data: {"product": recommendedProducts[index]},
                            ),
                      ),
                    );
                    setState(() {
                      isInPage = true;
                    });
                  },
                  child: ProductItemNetwork(
                    product: recommendedProducts[index]['product'],
                    discountLabel:
                        convertDouble(
                          recommendedProducts[index]['percent_off'],
                        ).toInt(),
                    kgLabel:
                        recommendedProducts[index]['product']["attributes"]
                                    .length ==
                                0
                            ? ""
                            : recommendedProducts[index]['product']["attributes"][0]["value"],
                    image: recommendedProducts[index]['image'],
                    name: recommendedProducts[index]['product']['name'],
                    priceStrike:
                        CURRENCY +
                        "${recommendedProducts[index]["unit_price"]}",
                    price:
                        CURRENCY +
                        "${recommendedProducts[index]["sale_price"]}",
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget getFooter() {
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
          ),
        ],
      ),
      child: Column(
        children: [
          // Padding(
          //   padding:
          //       const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
          //   child: Container(
          //     width: double.infinity,
          //     height: 50,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(10),
          //       color: white,
          //       boxShadow: [
          //         BoxShadow(
          //           color: black.withOpacity(0.06),
          //           spreadRadius: 5,
          //           blurRadius: 10,
          //         )
          //       ],
          //     ),
          //     child: Row(
          //       children: [
          //         Container(
          //           width: 60,
          //           child: Center(
          //               child: Icon(
          //             Icons.search,
          //             size: 30,
          //             color: greyLight,
          //           )),
          //         ),
          //         Flexible(
          //           child: TextField(
          //             onTap: () =>
          //                 Navigator.pushNamed(context, "/product_search_page"),
          //             cursorColor: black,
          //             decoration: InputDecoration(
          //               border: InputBorder.none,
          //               hintText: "Search for dal, atta, oil, bread...",
          //             ),
          //           ),
          //         ),
          //         SizedBox(
          //           width: 15,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 8, bottom: 8),
          //           child: Container(
          //             width: 60,
          //             decoration: BoxDecoration(
          //               border: Border(
          //                 left: BorderSide(width: 1, color: placeHolderColor),
          //               ),
          //             ),
          //             child: Center(
          //               child: Icon(
          //                 MaterialIcons.menu,
          //                 size: 30,
          //                 color: greyLight,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // cart section
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: 20,
            ),
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
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(Icons.arrow_back_ios, color: black, size: 18),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                context.watch<CartProvider>().isHasCart
                    ? Flexible(
                      child: InkWell(
                        onTap: () async {
                          dynamic dataPanel = {
                            "phone": userSession['phone_number'],
                            "cart_screen": "cart_screen",
                          };

                          mixpanel.track(CART_SCREEN, properties: dataPanel);
                          setState(() {
                            isInPage = false;
                          });
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartPage()),
                          );
                          setState(() {
                            isInPage = true;
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
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getCartInfo(context),
                                  style: normalWhiteText,
                                ),
                                Row(
                                  children: [
                                    Text("Cart", style: normalWhiteText),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
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
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {},
                          child: Center(
                            child: Text(
                              "Cart Empty  •  Start Shopping",
                              style: normalGreyText,
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
    );
  }

  // String getCartInfo() {
  //   String res = "";
  //   List _cartItems = cart["lines"];
  //   var _total = cart["total"];
  //   res = "${_cartItems.length} " +
  //       ((_cartItems.isNotEmpty && _cartItems.length > 1) ? "items" : "item");
  //   res = res + "  •  " + "$CURRENCY $_total";
  //   return res;
  // }
}
