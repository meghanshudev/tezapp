import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier, DiagnosticableTreeMixin {
  bool isHasCart = false;

  int cartCount = 0;

  double cartGrandTotal = 0;

  List carts = [];

  int get getCartCount => cartCount;

  double get getCartGrandTotal => cartGrandTotal;

  bool get isCart => isHasCart;

  List get getCarts => carts;

  Future<void> refreshCart(bool cart) async {
    isHasCart = cart;
    notifyListeners();
  }

  // Future<void> refreshListCart(List productId) {
  //   carts = productId;
  //   notifyListeners();
  // }

  Future<void> refreshCartCount(count) async {
    cartCount = count;
    notifyListeners();
  }

  Future<void> refreshCartGrandTotal(total) async {
    cartGrandTotal = total;
    notifyListeners();
  }
}
