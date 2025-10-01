import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:intl/intl.dart' as date;
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:tezchal/provider/has_group.dart';
import 'package:tezchal/ui_elements/custom_circular_progress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:http/http.dart' as http;

import '../provider/cart_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey(
  debugLabel: "Main Navigator",
);
var scaffoldKey = GlobalKey<ScaffoldState>();
var userSession;
Map<String, dynamic> userProfile = {
  "name": "N/A",
  "phone_number": "N/A",
  "email": "",
};

Future<void> getStorageUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userResult = prefs.getString(APP_PREFIX + STORAGE_USER);
  if (!checkIsNullValue(userResult)) {
    userSession = json.decode(userResult!);
  }
}

getOrderDay(int number) {
  switch (number) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    case 0:
      return 'N/A';
  }
}

double convertDouble(dynamic value) {
  if (checkIsNullValue(value)) return 0.0;
  if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
  }
}

int convertInt(dynamic value) {
  if (checkIsNullValue(value)) return 0;
  if (value is String) {
    return int.parse(value);
  } else {
    return value;
  }
}

myFormatDateTime(datetime) {
  if (['', null, 0].contains(datetime)) return datetime.toString();
  try {
    String formattedDate = date.DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(datetime));
    String formattedTime = date.DateFormat(
      'hh:mm a',
    ).format(DateTime.parse(datetime));
    return formattedDate + " at " + formattedTime;
  } catch (e) {
    return datetime;
  }
}

getDay(datetime) {
  if (['', null, 0].contains(datetime)) return datetime.toString();
  try {
    String formattedDate = date.DateFormat(
      'EEEE',
    ).format(DateTime.parse(datetime));

    return formattedDate;
  } catch (e) {
    return datetime;
  }
}

formatDate(datetime) {
  if (['', null, 0].contains(datetime)) return datetime.toString();
  try {
    return Jiffy.parse(datetime).format(pattern: "do MMMM yyyy");
  } catch (e) {
    return datetime;
  }
}

formatDateOne(datetime) {
  if (['', null, 0].contains(datetime)) return datetime.toString();
  try {
    return Jiffy.parse(datetime).format(pattern: "MMMM dd, yyyy");
  } catch (e) {
    return datetime;
  }
}

formatFullDateTime(datetime) {
  if (['', null, 0].contains(datetime)) return datetime.toString();
  try {
    return Jiffy.parse(datetime).format(pattern: "EEEE, MMMM dd, hh:mm a");
  } catch (e) {
    return datetime;
  }
}

// Monday, Feb 7 at 07:38PM
formatDay(datetime) {
  if (['', null, 0].contains(datetime)) return datetime.toString();
  try {
    return Jiffy.parse(datetime).format(pattern: "EEEE");
  } catch (e) {
    return datetime;
  }
}

sendEmail(receiverEmail) {
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: receiverEmail,
    query: encodeQueryParameters(<String, String>{'subject': 'Email Us'}),
  );

  //launchUrl(emailLaunchUri);
}

launchSocialLink(link) async {
  if (await canLaunch(link)) {
    await launch(link);
  } else {
    throw 'Could not launch $link';
  }
}

getProfileData(BuildContext context) async {
  var response = await netGet(isUserToken: true, endPoint: "me/profile");
  await removeStorage(STORAGE_USER);
  if (response['resp_code'] == "200") {
    var object = {
      "id": response['resp_data']['data']['id'],
      "name": response['resp_data']['data']['name'],
      "country_code": response['resp_data']['data']['country_code'],
      "phone_number": response['resp_data']['data']['phone_number'],
      "lat": response['resp_data']['data']['lat'],
      "lng": response['resp_data']['data']['lng'],
      "address": response['resp_data']['data']['address'],
      "zip_code": response['resp_data']['data']['zip_code'] ?? "",
      "email": response['resp_data']['data']['email'],
      "balance": response['resp_data']['data']['balance'],
      "group": response['resp_data']['data']['group'],
      "access_token": userSession['access_token'] ?? "",
      "is_first_time_login": userSession['is_first_time_login'],
      "token_type": userSession['token_type'],
    };
    context.read<CreditProvider>().refreshCredit(
      convertDouble(response['resp_data']['data']['balance']),
    );
    context.read<AccountInfoProvider>().refreshName(
      response['resp_data']['data']['name'] ?? '',
    );
    // set group
    bool hasGroup =
        !checkIsNullValue(response['resp_data']['data']['group'])
            ? true
            : false;
    context.read<HasGroupProvider>().refreshGroup(hasGroup);
    return object;
  } else {
    return {};
  }
}

getHeight(width, [String ratio = "16:9"]) {
  var split = ratio.split(":");
  var wr = double.parse(split[0]);
  var hr = double.parse(split[1]);
  return (width / wr) * hr;
}

bool isPhoneNoValid(String? phoneNo) {
  if (phoneNo == null) return false;
  final regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
  return regExp.hasMatch(phoneNo);
}

Future<Position> determineUserLocationPosition(BuildContext context) async {
  //bool serviceEnabled;
  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      notifyAlert(
        context,
        desc: "Location permissions are denied",
        btnTitle: "Ok!",
        onConfirm: () {
          Navigator.pop(context);
        },
      );
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    notifyAlert(
      context,
      desc:
          'Location permissions are denied. Please enable Location from settings.',
      btnTitle: "Ok!",
      onConfirm: () {
        Navigator.pop(context);
      },
    );
    return Future.error(
      'Location permissions are denied. Please enable Location from settings.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

var alertStyle = AlertStyle(
  animationType: AnimationType.shrink,
  isCloseButton: false,
  isOverlayTapDismiss: false,
  descStyle: const TextStyle(fontSize: 15, color: greyLight),
  descTextAlign: TextAlign.center,
  animationDuration: const Duration(milliseconds: 400),
  alertBorder: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
    side: const BorderSide(color: Colors.grey),
  ),
  constraints: const BoxConstraints.expand(width: 300),
  overlayColor: const Color(0x55000000),
  alertElevation: 0,
  alertAlignment: Alignment.center,
);
dynamic confirmAlert(
  context, {
  final GestureTapCallback? onCancel,
  final GestureTapCallback? onConfirm,
  final String btnCancelTitle = "Cancel",
  final String btnConfirmTitle = "Continue",
  final des = "",
}) {
  return Alert(
    context: context,
    style: alertStyle,
    desc: des,
    buttons: [
      DialogButton(
        border: Border.all(color: primary, width: 1),
        height: 50,
        child: Text(
          btnCancelTitle,
          style: const TextStyle(
            color: primary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        color: Colors.transparent,
        onPressed: onCancel,
        radius: BorderRadius.circular(10.0),
      ),
      DialogButton(
        height: 50,
        child: Text(
          btnConfirmTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onConfirm,
        color: primary,
        radius: BorderRadius.circular(10.0),
      ),
    ],
  ).show();
}

setStorage(storageName, data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(APP_PREFIX + storageName, json.encode(data));
}

getStorage(storageName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userResult = prefs.getString(APP_PREFIX + storageName);
  return userResult;
}

redirectLogin(response) {
  if (response.statusCode.toString() == "401") {
    onSignOut(response);
  }
}

removeStorage(storageName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(APP_PREFIX + storageName);
}

onSignOut(context) async {
  await removeStorage(STORAGE_USER);
  userSession = '';
  Navigator.pushNamedAndRemoveUntil(
      context, "/login_page", (Route<dynamic> route) => false);
}

// check if null value and return back the value if not null
checkIsNullValueAndReturn(value, {dynamic dValue = ""}) {
  return checkIsNullValue(value) ? dValue : value;
}

bool checkIsNullValue(dynamic value) {
  return value == null ||
      value == "null" ||
      value == 0 ||
      value == "0" ||
      value == "";
}

reponseErrorMessage(
  response, {
  String defaultMsg = "Error",
  required List requestedParams,
}) {
  switch (response["resp_code"]) {
    case "403":
    case "401":
    case "400":
    case "422":
      var message = response["resp_data"]["message"];
      return message;
    case "500":
      var message = "Server Error";
      return message;
    default:
      var message = response["resp_data"]["message"];
      return message;
  }
}

reponseErrorMessageDy(
  response, {
  String defaultMsg = "Error",
  required List requestedParams,
}) {
  switch (response["resp_code"]) {
    case "403":
    case "400":
      var message = response["resp_data"]["message"];
      return message;
    case "422":
      var message =
          response["resp_data"]["errors"] ?? response["resp_data"]["message"];

      List error = [];
      for (var i = 0; i < requestedParams.length; i++) {
        if (!checkIsNullValue(message[requestedParams[i]])) {
          error = message[requestedParams[i]];
          break;
        }
      }
      String propertyErrorText = error[0].toString();
      return propertyErrorText;
    case "500":
      var message = "Server Error";
      return message;
    default:
      return defaultMsg;
  }
}

loadingPopup(context) {
  var alertStyle = AlertStyle(
    animationType: AnimationType.shrink,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontSize: 15, color: primary),
    descTextAlign: TextAlign.center,
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide.none,
    ),
    titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    constraints: BoxConstraints.expand(width: 50, height: 50),
    overlayColor: Color(0x55000000),
    alertElevation: 0,
    alertAlignment: Alignment.center,
  );

  Alert(
    context: context,
    style: alertStyle,
    content: Column(children: [SizedBox(height: 30), CustomCircularProgress()]),
    buttons: [],
  ).show();
}

loadingAlert(
  context, {
  String title = "request",
  String detail = "requesting_for_otp_code",
}) {
  var alertStyle = AlertStyle(
    animationType: AnimationType.shrink,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontSize: 15, color: greyLight),
    descTextAlign: TextAlign.start,
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(color: Colors.grey),
    ),
    titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    constraints: BoxConstraints.expand(width: 300),
    //First to chars "55" represents transparency of color
    overlayColor: Color(0x55000000),
    alertElevation: 0,
    alertAlignment: Alignment.center,
  );

  // Alert dialog using custom alert style
  Alert(
    context: context,
    style: alertStyle,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        CustomCircularProgress(),
        SizedBox(height: 20),
        Text(
          title.tr(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(detail.tr(), style: TextStyle(fontSize: 16, color: greyLight)),
      ],
    ),
    // title: "Requesting",
    // desc: "Processing to verify customer",
    buttons: [],
  ).show();
}

notifyAlert(
  context, {
  String title = APP_PREFIX,
  String desc = "",
  String btnTitle = "",
  final GestureTapCallback? onConfirm,
}) {
  var alertStyle = AlertStyle(
    animationType: AnimationType.shrink,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontSize: 15, color: greyLight),
    descTextAlign: TextAlign.center,
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(color: Colors.grey),
    ),
    constraints: BoxConstraints.expand(width: 300),
    //First to chars "55" represents transparency of color
    overlayColor: Color(0x55000000),
    alertElevation: 0,
    alertAlignment: Alignment.center,
  );
  Alert(
    context: context,
    style: alertStyle,
    desc: desc,
    buttons: [
      DialogButton(
        height: 50,
        child: Text(
          btnTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onConfirm,
        color: primary,
        radius: BorderRadius.circular(10.0),
      ),
    ],
  ).show();
}

ImageProvider displayImage(String imageUrl) {
  if (checkIsNullValue(imageUrl)) return AssetImage(LOCAL_DEFAULT_IMAGE);
  return NetworkImage(imageUrl);
}

showToast(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(duration: Duration(milliseconds: 1800), content: Text("$message")),
  );
}

String getCartInfo(BuildContext context) {
  String res = "";
  res =
      context.watch<CartProvider>().cartCount > 1
          ? context.watch<CartProvider>().cartCount.toString() +
              " " +
              "items".tr() +
              " • $CURRENCY" +
              double.parse(
                context.watch<CartProvider>().cartGrandTotal.toString(),
              ).toStringAsFixed(0)
          : context.watch<CartProvider>().cartCount.toString() +
              " " +
              "items".tr() +
              " • $CURRENCY" +
              double.parse(
                context.watch<CartProvider>().cartGrandTotal.toString(),
              ).toStringAsFixed(0);
  // List _cartItems = cart["lines"];
  // var _total = cart["total"];
  // res = "${_cartItems.length} " +
  //     ((_cartItems.isNotEmpty && _cartItems.length > 1) ? "items" : "item");
  // res = res + "  •  " + "$CURRENCY $_total";
  return res;
}

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
int nowTimeStamp() => DateTime.now().millisecondsSinceEpoch;

Future<XFile> getFileImage(file) async {
  final dir = await path_provider.getTemporaryDirectory();

  final targetPath = dir.absolute.path + "/" + timestamp() + ".jpg";
  final imgFile = await testCompressAndGetFile(file, targetPath);

  return imgFile;
}

Future<XFile> testCompressAndGetFile(File file, String targetPath) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    minWidth: 628,
    minHeight: 1200,
    quality: 30,
  );
  return result!;
}

Future<String?> networkImageToBase64(String imageUrl) async {
  var url = Uri.parse(imageUrl);
  http.Response response = await http.get(url);
  final bytes = response.bodyBytes;
  return (bytes != null ? HEADER_IMAGE_BASE64 + base64Encode(bytes) : null);
}
