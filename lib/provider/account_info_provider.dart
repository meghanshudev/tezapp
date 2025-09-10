import 'package:flutter/foundation.dart';
import 'package:tezchal/helpers/utils.dart';

class AccountInfoProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String name = "";

  String get getName => name;

  Future<void> refreshName(String fullname) async {
    name = fullname;
    notifyListeners();
  }
  
}
