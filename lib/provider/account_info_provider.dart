import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:tezchal/helpers/utils.dart';

class AccountInfoProvider with ChangeNotifier, DiagnosticableTreeMixin {
  String name = "";

  String get getName => name;

  bool isDefencePersonnel = false;

  bool get getIsDefencePersonnel => isDefencePersonnel;

  Future<void> refreshName(String fullname) async {
    name = fullname;
    notifyListeners();
  }

  Future<void> refreshIsDefencePersonnel(bool isDefence) async {
    isDefencePersonnel = isDefence;
    log("isDefencePersonnel $isDefencePersonnel");
    notifyListeners();
  }
  
}
