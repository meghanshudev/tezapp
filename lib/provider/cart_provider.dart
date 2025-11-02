import 'package:flutter/foundation.dart';

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

  Future<void> refreshCartData(Map<String, dynamic>? data) async {
    cartData = data;
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
