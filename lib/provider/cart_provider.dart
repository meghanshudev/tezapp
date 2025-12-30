import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/provider/account_info_provider.dart';

class CartProvider with ChangeNotifier, DiagnosticableTreeMixin {
  bool isHasCart = false;

  int cartCount = 0;

  double cartGrandTotal = 0;

  // Add a field to store the full cart data
  Map<String, dynamic>? cartData;

  int get getCartCount => cartCount;

  double get getCartGrandTotal => cartGrandTotal;

  bool get isCart => isHasCart;

  Map<String, dynamic>? get getCartData => cartData;

  Future<void> refreshCart(bool cart) async {
    isHasCart = cart;
    notifyListeners();
  }

  Future<void> refreshCartData(
      Map<String, dynamic>? data, AccountInfoProvider accountInfoProvider) async {
    cartData = data;
    if (data != null) {
      if (data['total'] != null) {
          cartGrandTotal = data['total'];
      } else {
        cartGrandTotal = 0.0;
      }
    }
    log("cartGrandTotal $cartGrandTotal");
    notifyListeners();
  }

  Future<void> refreshCartCount(count) async {
    cartCount = count;
    notifyListeners();
  }

  Future<void> refreshCartGrandTotal(total) async {
    cartGrandTotal = total;
    notifyListeners();
  }

}
