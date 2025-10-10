import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/crypto.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Authentication/enter_otp_page.dart';
import 'package:tezchal/pages/Authentication/privacy_policy_login_page.dart';
import 'package:tezchal/pages/Authentication/term_condition_login_page.dart';
import 'package:tezchal/pages/Guest/guest_root_app.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:tezchal/ui_elements/custom_primary_button.dart';
import 'package:tezchal/ui_elements/custom_textfield_phone.dart';
import 'package:tezchal/ui_elements/error_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  MaskTextInputFormatter phoneFormatter = new MaskTextInputFormatter(
    mask: PHONE_FORMAT,
    filter: {"#": RegExp(r'[0-9]')},
  );
  bool isSignIn = false;

  TextEditingController phoneNumberController = TextEditingController();
  bool isPhoneNumber = false;
  String phoneNumberMessage = '';

  bool isLoadingButton = false;
  bool isVerifyOTP = false;

  late Mixpanel mixpanel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMixpanel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(backgroundColor: white, body: getBody()),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: primary),
      child: KeyboardAvoider(
        autoScroll: true,
        child: Column(
          children: [
            Container(
              width: size.width,
              height: size.height * 0.50,
              decoration: BoxDecoration(color: primary),
              child: Center(child: Image.asset("assets/images/logo.png")),
            ),
            Container(
              width: size.width,
              height: size.height * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: white,
              ),
              child: Column(
                children: [
                  Container(
                    height: 70,
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: placeHolderColor),
                      ),
                    ),
                    child: Center(
                      child:
                          Text("login_or_signup", style: normalBlackText).tr(),
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: CustomTextFieldPhone(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      // inputFormatters: [phoneFormatter],
                      hintText: "enter_your_phone_number".tr(),
                    ),
                  ),
                  ErrorMessage(
                    isError: isPhoneNumber,
                    message: phoneNumberMessage,
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: InkWell(
                      onTap: () {
                        onSignIn();
                      },
                      child: CustomPrimaryButton(
                        isLoading: isLoadingButton,
                        text: "send_otp".tr(),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => loginDirectly(),
                            child: Text(
                              "Skip this step",
                              style: meduimPrimaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Text(
                        "by_continuing_you_agree_to_tez's",
                        style: smallBlackText,
                      ).tr(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TermConditionLoginPage(),
                                  ),
                                ),
                            child:
                                Text(
                                  // "Terms & Conditions ",
                                  "terms_&_conditions",
                                  style: smallBoldBlackText,
                                ).tr(),
                          ),
                          Text("and", style: smallBlackText).tr(),
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PrivacyPolicyLoginPage(),
                                  ),
                                ),
                            child:
                                Text(
                                  "privacy_policy",
                                  style: smallBoldBlackText,
                                ).tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  onValidate() {
    bool res = true;

    setState(() {
      isPhoneNumber = false;
    });

    if (checkIsNullValue(phoneNumberController.text)) {
      if (mounted) {
        setState(() {
          isPhoneNumber = true;
          phoneNumberMessage = "phone_number_is_required".tr();
        });
      }
      res = false;
    }

    return res;
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(
      MIX_PANEL,
      optOutTrackingDefault: false,
      trackAutomaticEvents: true,
    );
  }

  loginDirectly() async {
    var phoneNumber = "9000000000";

    String value =
        phoneNumber + "-" + DateTime.now().millisecondsSinceEpoch.toString();
    var encryptAccess = encrypt(value, CREDENTIAL_KEY, CREDENTIAL_IV);
    print("SKIP LOGIN - $encryptAccess");

    setState(() {
      isVerifyOTP = false;
      isLoadingButton = true;
    });

    try {
      var response = await netPost(
        isUserToken: false,
        endPoint: "auth/login",
        params: {"phone_number": encryptAccess},
      );

      if (!mounted) return;

      setState(() {
        isLoadingButton = false;
      });

      if (response['resp_code'] == "200") {
        var userData = response["resp_data"]['data'];

        // store login token
        await setStorage(STORAGE_USER, userData);
        userSession = await getStorageUser();

        // Get profile data before navigation
        var user = await getProfileData(context);
        await setStorage(STORAGE_USER, user);
        await getStorageUser();

        if (!mounted) return;

        // Navigate after all data is ready
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GuestRootApp(data: {"activePageIndex": 0}),
          ),
          (Route<dynamic> route) => false, // remove all previous routes
        );
      } else {
        var message = reponseErrorMessage(
          response,
          requestedParams: ["verification_code", "user_id"],
        );
        if (!mounted) return;
        notifyAlert(
          context,
          desc: message,
          btnTitle: "Ok!",
          onConfirm: () {
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      print("Login error: $e");
      if (!mounted) return;
      setState(() {
        isLoadingButton = false;
      });
      notifyAlert(
        context,
        desc: "An error occurred during login",
        btnTitle: "Ok!",
        onConfirm: () {
          Navigator.pop(context);
        },
      );
    }
  }

  onSignIn() async {
    if (!onValidate() || isSignIn) {
      return;
    }

    dynamic dataPanel = {"phone": PREFIX_PHONE + phoneNumberController.text};

    mixpanel.track(LOGIN_PHONE_NUMBER, properties: dataPanel);

    // validate phone number as indian phone number

    var phoneNumber = phoneNumberController.text;

    var data = {"phone_number": phoneNumber};
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterOTPPage(data: data),
      ),
    );
  }
}
