import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/event/ProductListEvent.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/models/cart.dart';
import 'package:tezchal/provider/cart_provider.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/respositories/cart/cart_repository.dart';

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
  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  @override
  Widget build(BuildContext context) {
    // Get product quantity from CartProvider
    int productQty = 0;
    var cartData = context.watch<CartProvider>().getCartData;
    if (cartData != null && cartData.containsKey('lines')) {
      for (var item in cartData['lines']) {
        if (item['product_id'].toString() == widget.product["id"].toString()) {
          productQty = item['qty'];
          break;
        }
      }
    }

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
                    log('Minus button tapped for product id: ${widget.product["id"]}');
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
                    log('Plus button tapped for product id: ${widget.product["id"]}');
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
                  log('Add to cart button tapped for product id: ${widget.product["id"]}');
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
    log('addProductToCart called with productId: $_productId and type: $type');
    if (isAddingCart) return;
    isAddingCart = true;

   

   Cart cartItem = new Cart();
   int cnt = 0;
   var response;

   // Get current product quantity from CartProvider for accurate local update
   int currentProductQty = 0;
   var cartData = context.read<CartProvider>().getCartData;
   if (cartData != null && cartData.containsKey('lines')) {
     for (var item in cartData['lines']) {
       if (item['product_id'].toString() == _productId.toString()) {
         currentProductQty = item['qty'];
         break;
       }
     }
   }

   if (type == "minus" && currentProductQty <= 1) {
     cartItem = new Cart(productId: _productId.toString(), qty: 1);
     cnt = await CartRepository().addOrUpdate(cart: cartItem, type: type);
     response = await netDelete(
       endPoint: "me/cart/product/${_productId.toString()}",
       params: {
         "qty": cnt,
       },
     );
     // Update CartProvider directly after deletion
     if (response['resp_code'] == "200") {
       var temp = response["resp_data"]["data"];
       context.read<CartProvider>().refreshCartData(
           temp, context.read<AccountInfoProvider>());
       if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
         List cartItems = temp['lines'];
         context.read<CartProvider>().refreshCart(true);
         context.read<CartProvider>().refreshCartCount(cartItems.length);
         context.read<CartProvider>().refreshCartGrandTotal(double.parse(temp['total'].toString()));
       } else {
         context.read<CartProvider>().refreshCart(false);
         context.read<CartProvider>().refreshCartCount(0);
         context.read<CartProvider>().refreshCartGrandTotal(0.0);
       }
     }
   } else {
     cartItem = new Cart(productId: _productId.toString(), qty: 1);
     cnt = await CartRepository().addOrUpdate(cart: cartItem, type: type);
     response = await netPatch(
       endPoint: "me/cart/product",
       params: {
         "product_id": _productId,
         "qty": cnt,
       },
     );
     log(response.toString());
     // Update CartProvider with full cart data after patch
     if (response['resp_code'] == "200") {
       var temp = response["resp_data"]["data"];
       context.read<CartProvider>().refreshCartData(
           temp, context.read<AccountInfoProvider>());
       if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
         List cartItems = temp['lines'];
         context.read<CartProvider>().refreshCart(true);
         context.read<CartProvider>().refreshCartCount(cartItems.length);
         context.read<CartProvider>().refreshCartGrandTotal(double.parse(temp['total'].toString()));
       }
     }
   }

   // No need for setState((){ productQty = cnt; }) here, as it's now derived from CartProvider.
   // The UI will rebuild when CartProvider notifies listeners.

   eventBus.fire(ProductListEvent(
     id: _productId.toString(),
     quantity: cnt, // Use the updated count
   ));

   if (response['resp_code'] == "200") {
     // CartProvider is already updated above
     if (type == "add") showToast("Added", context);
   } else {
     // Revert local cart if API call fails
     int revertedCnt = await CartRepository()
         .addOrUpdate(cart: cartItem, type: (type == "add") ? "minus" : "add");
     // No need for setState((){ productQty = revertedCnt; }) here.
     // The UI will rebuild when CartProvider notifies listeners.
     var msg = reponseErrorMessageDy(response,
         requestedParams: ["product_id", "qty"]);
     showToast(msg, context);
   }
   if (mounted) {
     setState(() {
       isAddingCart = false;
     });
   }
  }
}
