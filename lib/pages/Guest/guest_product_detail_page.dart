import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/pages/Authentication/login_page.dart';
import 'package:tezapp/pages/guest/guest_custom_appbar.dart';
import 'package:tezapp/ui_elements/product_detail_loading.dart';
import 'package:tezapp/pages/Guest/guest_product_item_network.dart';

import '../../helpers/network.dart';
import '../../pages/Guest/guest_add_to_cart_button_item.dart';

// ignore: must_be_immutable
class GuestProductDetailPage extends StatefulWidget {
  GuestProductDetailPage({Key? key, required this.data}) : super(key: key);
  final data;

  @override
  _GuestProductDetailPageState createState() => _GuestProductDetailPageState();
}

class _GuestProductDetailPageState extends State<GuestProductDetailPage> {
  var groupProduct;
  List products = [];
  int productId = 0;
  bool isLoading = false;
  bool isAddingCart = false;
  List recommendedProducts = [];

  var zipCode = '';
  var deliverTo = '';

  bool isInPage = true;

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

  initPage() async {
    print("WIDGET ${widget.data}");
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
    print("products $products");
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: GuestCustomAppBar(
            subtitle: "Guest Login",
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

  Widget getBody() {
    print("isLoading : $isLoading");
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
                        GuestAddToCardButtonItem(product: products[0]),
                      ],
                    ),
                  ],
                ),
              ),
              getProductAttributes(),
              Divider(thickness: 0.8),
              SizedBox(height: 20),
              // getRelatedProducts(),
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
                      _attribute.isNotEmpty ? _attribute.first["value"] : "N/A",
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
            Flexible(
              flex: 3,
              child: GuestAddToCardButtonItem(product: _product),
            ),
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
                    setState(() {
                      isInPage = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GuestProductDetailPage(
                              data: {"product": recommendedProducts[index]},
                            ),
                      ),
                    );
                    setState(() {
                      isInPage = true;
                    });
                  },
                  child: GuestProductItemNetwork(
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
                      child: Icon(Icons.arrow_back_ios, color: black, size: 20),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primary,
                      boxShadow: [
                        BoxShadow(
                          color: black.withOpacity(0.06),
                          spreadRadius: 5,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Login to Start Shopping",
                                style: meduimWhiteText,
                              ),
                              SizedBox(width: 10),
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
