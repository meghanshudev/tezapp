import 'package:flutter/foundation.dart';
import 'package:tez_mobile/helpers/utils.dart';

class HasGroupProvider with ChangeNotifier, DiagnosticableTreeMixin {
  bool isHasGroup = false;

  int orderDay = 1;

  int groupNumber = 1;

  String groupLeader = "";
  String groupLeaderProfile = "";
  String leaderzipCode = "";

  int get getOrderDay => orderDay;

  bool get hasGroup => isHasGroup;

  int get getGroupNumber => groupNumber;

  String get getGroupLeader => groupLeader;

  String get getGroupLeaderProfile => groupLeaderProfile;

  String get getLeaderzipCode => leaderzipCode;

  Future<void> refreshGroup(group) async {
    isHasGroup = group;
    notifyListeners();
  }

  Future<void> refreshOrderDay(index) async {
    orderDay = index;
    notifyListeners();
  }

  Future<void> refreshGroupNumber(index) async {
    groupNumber = index;
    notifyListeners();
  }

  Future<void> refreshGroupLeader(leader) async {
    groupLeader = leader;
    notifyListeners();
  }
  Future<void> refreshGroupLeaderProfile(profileUrl) async {
    groupLeaderProfile = profileUrl;
    notifyListeners();
  }

  Future<void> refreshLeaderZipCode(code) async {
    leaderzipCode = code;
    notifyListeners();
  }
}
