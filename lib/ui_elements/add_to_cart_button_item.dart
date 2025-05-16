import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/event/ProductListEvent.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/network.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/models/cart.dart';
import 'package:tezapp/provider/cart_provider.dart';
import 'package:tezapp/respositories/cart/cart_repository.dart';

class AddToCardButtonItem extends StatefulWidget {
  final product;
  final GestureTapCallback? onTap;
  const AddToCardButtonItem(
      {Key? key, this.product = const {"quantity": 0}, this.onTap})
      : super(key: key);

  @override
  _AddToCardButtonItemState createState() => _AddToCardButtonItemState();
}

class _AddToCardButtonItemState extends State<AddToCardButtonItem> {
  int productQty = 0;


  late Mixpanel mixpanel;

  @override
  void initState() {
    // TODO: implement initState
    initialize();
    super.initState();
     initMixpanel();
  }
  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  initialize() async {

   
    List<Cart> carts = await CartRepository().list();
    for (Cart item in carts) {
      if (item.productId == widget.product["id"].toString()) {
        setState(() {
          productQty = item.qty;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          height: 40,
          width: 100,
        ),
        AnimatedContainer(
          decoration: BoxDecoration(
              color: (productQty >= 1) ? primary : Colors.white,
              borderRadius: BorderRadius.circular(10)),
          duration: Duration(milliseconds: 200),
          width: 100,
          height: 40,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    addProductToCart(widget.product["id"], type: "minus");
                    // mix panel

                     dynamic dataPanel = {
                      "phone" : userSession['phone_number'],
                       "type" : "decrease",
                      "product":widget.product['name']
                     
                    };

                    mixpanel.track(CLICK_INCREASE_OR_DECREASE_PRODUCT_QTY,properties: dataPanel);

                  },
                  child: Container(
                      width: 30,
                      child: Center(
                          child: Text(
                        "-",
                        style: TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ))),
                ),
              ),
              Center(
                  child: Text(
                productQty.toString(),
                style: TextStyle(
                    color: white, fontSize: 18, fontWeight: FontWeight.bold),
              )),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    addProductToCart(widget.product["id"], type: "add");
                     // mix panel

                     dynamic dataPanel = {
                      "phone" : userSession['phone_number'],
                       "type" : "increase",
                      "product":widget.product['name']
                     
                    };

                    mixpanel.track(CLICK_INCREASE_OR_DECREASE_PRODUCT_QTY,properties: dataPanel);
                  },
                  child: Container(
                      width: 30,
                      child: Center(
                          child: Text(
                        "+",
                        style: TextStyle(
                            color: white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ))),
                ),
              ),
            ],
          ),
        ),
        (productQty >= 1)
            ? SizedBox()
            : GestureDetector(
                onTap: () {
                  addProductToCart(widget.product["id"]);

                   // mix panel

                     dynamic dataPanel = {
                      "phone" : userSession['phone_number'],
                      "product":widget.product['name']
                     
                    };

                    mixpanel.track(CLICK_ADD_TO_CART,properties: dataPanel);

                },
                child: AnimatedContainer(
                  width: (productQty >= 1) ? 0 : 80,
                  height: (productQty >= 1) ? 0 : 35,
                  decoration: BoxDecoration(
                      border: Border.all(color: greyLight),
                      borderRadius: BorderRadius.circular(10)),
                  duration: Duration(milliseconds: 200),
                  child: Center(
                    child: Text(
                      "add",
                      style: meduimPrimaryText,
                    ).tr(),
                  ),
                ),
              )
      ],
    );
  }

  bool isAddingCart = false;

  addProductToCart(int _productId, {String type = "add"}) async {

    if (isAddingCart) return;
    isAddingCart = true;

   

    Cart cart = new Cart();
    int cnt = 0;
    var response;
    if (type == "minus" && productQty <= 1) {
      cart = new Cart(productId: _productId.toString(), qty: 1);
      cnt = await CartRepository().addOrUpdate(cart: cart, type: type);
      response = await netDelete(
        endPoint: "me/cart/product/${_productId.toString()}",
        params: {
          "qty": cnt,
        },
      );
       context.read<CartProvider>().refreshCart(false);
        //  set new number of cart item
        context.read<CartProvider>().refreshCartCount(cnt);

    } else {
      cart = new Cart(productId: _productId.toString(), qty: 1);
      print(">>>>>>>>");
      print(cart.qty);
      cnt = await CartRepository().addOrUpdate(cart: cart, type: type);
      print(">>>>>>>>");
      print(cnt);
      response = await netPatch(
        endPoint: "me/cart/product",
        params: {
          "product_id": _productId,
          "qty": cnt,
        },
      );
    }

    setState(() {
      productQty = cnt;
    });

    eventBus.fire(ProductListEvent(
      id: _productId.toString(),
      quantity: productQty
    ));
    if (response['resp_code'] == "200") {
      
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        var cart = temp;

        List cartItems = cart['lines'];
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context
            .read<CartProvider>()
            .refreshCartGrandTotal(double.parse(cart['total'].toString()));

        if (type == "add") showToast("Added", context);
      }
    } else {
      int cnt = await CartRepository()
          .addOrUpdate(cart: cart, type: (type == "add") ? "minus" : "add");
      setState(() {
        productQty = cnt;
      });
      var msg = reponseErrorMessageDy(response,
          requestedParams: ["product_id", "qty"]);
      showToast(msg, context);
    }
    if (mounted)
      setState(() {
        isAddingCart = false;
      });
  }
}
