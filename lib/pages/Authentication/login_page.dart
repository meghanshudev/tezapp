import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/crypto.dart';
import 'package:tezapp/helpers/network.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/ui_elements/custom_primary_button.dart';
import 'package:tezapp/ui_elements/custom_textfield_phone.dart';
import 'package:tezapp/ui_elements/error_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  MaskTextInputFormatter phoneFormatter = new MaskTextInputFormatter(
      mask: PHONE_FORMAT, filter: {"#": RegExp(r'[0-9]')});
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
      child: Scaffold(
        backgroundColor: white,
        body: getBody(),
      ),
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
                  height: size.height * 0.40,
                  decoration: BoxDecoration(color: primary),
                  child: Center(
                      child: Text(
                    "tez",
                    style: logoText,
                  )),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), color: white),
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        width: size.width,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: placeHolderColor))),
                        child: Center(
                            child: Text(
                          "login_or_signup",
                          style: normalBlackText,
                        ).tr()),
                      ),
                      SizedBox(
                        height: 25,
                      ),
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
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: InkWell(
                            onTap: () {
                              onSignIn();
                              // Navigator.pushNamed(context, "/enter_otp_page");
                            },
                            child: CustomPrimaryButton(
                              isLoading: isLoadingButton,
                              text: "send_otp".tr(),
                            )),
                      ),
                      SizedBox(
                        height: 25,
                      ),
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
                              )
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            "by_continuing_you_agree_to_tez's",
                            style: smallBlackText,
                          ).tr(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/term_condition_login_page'),
                                child: Text(
                                  // "Terms & Conditions ",
                                  "terms_&_conditions",
                                  style: smallBoldBlackText,
                                ).tr(),
                              ),
                              Text(
                                "and",
                                style: smallBlackText,
                              ).tr(),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/privacy_policy_login_page'),
                                child: Text(
                                  "privacy_policy",
                                  style: smallBoldBlackText,
                                ).tr(),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )));
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
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  loginDirectly() async {
    var phoneNumber = "9000000000";

    String value = phoneNumber +
        "-" +
        new DateTime.now().millisecondsSinceEpoch.toString();
    var encryptAccess = encrypt(value, CREDENTIAL_KEY, CREDENTIAL_IV);
    print("SKIP LOGIN - $encryptAccess");
    var response =
        await netPost(isUserToken: false, endPoint: "auth/login", params: {
      "phone_number": encryptAccess,
    });
    if (mounted)
      setState(() {
        isVerifyOTP = false;
        isLoadingButton = false;
      });

    if (response['resp_code'] == "200") {
      var userData = response["resp_data"]['data'];

      // no profile account
      await setStorage(STORAGE_USER, userData);

      await getStorageUser();

      // profile + token
      var user = await getProfileData(context);

      await setStorage(STORAGE_USER, user);

      await getStorageUser();
      // second time
      Future.delayed(Duration.zero, () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/guest_root_app",
          (route) => false,
          arguments: {"activePageIndex": 0},
        );
      });
    } else {
      var message = reponseErrorMessage(response,
          requestedParams: ["verification_code", "user_id"]);
      notifyAlert(context, desc: message, btnTitle: "Ok!", onConfirm: () {
        Navigator.pop(context);
      });
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
    print(data);

    Navigator.pushNamed(context, "/enter_otp_page", arguments: {"data": data});
  }
}
