import 'package:flutter/material.dart';

class CreditProvider with ChangeNotifier {
  

  double balance = 0;


  double get getBalance => balance;

  Future<void> refreshCredit(double credit) async {
    balance = credit;
    notifyListeners();
  }
}
