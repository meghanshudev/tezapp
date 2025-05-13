import 'package:flutter/foundation.dart';

class CreditProvider with ChangeNotifier, DiagnosticableTreeMixin {
  

  double balance = 0;


  double get getBalance => balance;

  Future<void> refreshCredit(double credit) async {
    balance = credit;
    notifyListeners();
  }
}
