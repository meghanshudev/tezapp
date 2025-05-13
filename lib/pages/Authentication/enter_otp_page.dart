import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:tez_mobile/helpers/constant.dart';
import 'package:tez_mobile/helpers/crypto.dart';
import 'package:tez_mobile/helpers/network.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/helpers/utils.dart';
import 'package:tez_mobile/provider/account_info_provider.dart';
import 'package:tez_mobile/ui_elements/custom_button_loading.dart';
import 'package:tez_mobile/ui_elements/error_message.dart';

class EnterOTPPage extends StatefulWidget {
  final data;
  const EnterOTPPage({Key? key, this.data}) : super(key: key);

  @override
  _EnterOTPPageState createState() => _EnterOTPPageState();
}

class _EnterOTPPageState extends State<EnterOTPPage> {
  TextEditingController codeController = TextEditingController();

  double paddingTopAnimation = 0;
  bool isVerifySignUp = false;
  bool isVerifyOTP = false;
  bool isResend = false;
  bool isCode = false;
  String codeMessage = '';

  bool isLoadingButton = false;
  bool isLoadingResendButton = false;
  bool isResendButtonClickable = false;

  int sendCount = 1;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initMixpanel();
    if (ENV == "production" && widget.data['phone_number'] != "9061234560") {
      onResend();
    } else if (widget.data['phone_number'] == "9061234560") {
      loginDirectly();
    } else {
      loginDirectly();
    }
  }

  loginDirectly() async {
    var phoneNumber = widget.data['phone_number'];

    String value = phoneNumber +
        "-" +
        new DateTime.now().millisecondsSinceEpoch.toString();
    var encryptAccess = encrypt(value, CREDENTIAL_KEY, CREDENTIAL_IV);

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

      bool isFirstTimeLogin =
          response['resp_data']['data']['is_first_time_login'];

      if (isFirstTimeLogin) {
        // first time
        Navigator.pushNamed(context, "/add_name_page");
      } else {
        // profile + token
        var user = await getProfileData(context);

        await setStorage(STORAGE_USER, user);

        await getStorageUser();
        // second time
        Future.delayed(Duration.zero, () async {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/root_app",
            (route) => false,
            arguments: {"activePageIndex": 0},
          );
        });
      }
    } else {
      var message = reponseErrorMessage(response,
          requestedParams: ["verification_code", "user_id"]);
      notifyAlert(context, desc: message, btnTitle: "Ok!", onConfirm: () {
        Navigator.pop(context);
      });
    }
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
                  height: size.height * 0.4,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Ionicons.md_arrow_back)),
                            Text(
                              "otp_verification",
                              style: normalBlackText,
                            ).tr(),
                            Opacity(
                              opacity: 0,
                              child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Ionicons.md_arrow_back)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: PinCodeTextField(
                                enablePinAutofill: false,
                                cursorColor: greyLight,
                                textStyle: TextStyle(color: black),
                                keyboardType: TextInputType.number,
                                autoFocus: true,
                                appContext: context,
                                length: 4,
                                obscureText: false,
                                animationType: AnimationType.fade,
                                pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(10),
                                    fieldHeight: 50,
                                    fieldWidth: 50,
                                    borderWidth: 1,
                                    inactiveColor: black.withOpacity(0.5),
                                    activeFillColor: Colors.transparent,
                                    activeColor: black.withOpacity(0.5),
                                    selectedColor: black.withOpacity(0.5),
                                    selectedFillColor: Colors.transparent,
                                    inactiveFillColor: Colors.transparent),
                                animationDuration: Duration(milliseconds: 300),
                                enableActiveFill: true,
                                // errorAnimationController: errorController,
                                controller: codeController,
                                onCompleted: (code) {
                                  verifyLogin();
                                },
                                onChanged: (code) {
                                  // setState(() {
                                  //   pinCode = code;
                                  // });
                                },
                                beforeTextPaste: (text) {
                                  print("Allowing to paste $text");
                                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                  return true;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                verifyLogin();
                              },
                              child: Container(
                                width: 95,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(10)),
                                child: isLoadingButton
                                    ? CustomButtonLoading()
                                    : Center(
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: white,
                                          size: 18,
                                        ),
                                      ),
                              ),
                            )
                          ],
                        ),
                      ),
                      ErrorMessage(
                        isError: isCode,
                        message: codeMessage,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 20),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            Flexible(
                                child: GestureDetector(
                              onTap: () {
                                if (isResendButtonClickable) {
                                  onResend();
                                }
                              },
                              child: isResendButtonClickable
                                  ? Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          border: Border.all(color: primary),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: isLoadingResendButton
                                          ? CustomButtonLoading(
                                              color: primary,
                                            )
                                          : Center(
                                              child: Text(
                                                "resend_sms",
                                                style: normalPrimaryText,
                                              ).tr(),
                                            ),
                                    )
                                  : Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: isLoadingResendButton
                                          ? CustomButtonLoading(
                                              color: primary,
                                            )
                                          : Center(
                                              child: Text(
                                              "Resend SMS after 30s",
                                              style: normalGrayedText,
                                            )),
                                    ),
                            )),
                          ],
                        ),
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
      isCode = false;
    });

    if (checkIsNullValue(codeController.text)) {
      if (mounted) {
        setState(() {
          isCode = true;
          codeMessage = "please_enter_code".tr();
        });
      }
      res = false;
    }
    if (!checkIsNullValue(codeController.text) &&
        codeController.text.length < 4) {
      if (mounted) {
        setState(() {
          isCode = true;
          codeMessage = "code_must_be_4_digits".tr();
        });
      }
      res = false;
    }
    return res;
  }

  onResend() async {
    Duration time = Duration(seconds: 30);
    setState(() {
      isResendButtonClickable = false;
      Future.delayed(time, () {
        setState(() {
          isResendButtonClickable = true;
        });
      });
    });

    if (isResend) {
      return;
    }
    if (mounted) {
      setState(() {
        isResend = true;
        isLoadingResendButton = sendCount == 1 ? false : true;
      });

      var phoneNumber = widget.data['phone_number'];

      var response = await netPost(
          isUserToken: false,
          endPoint: "auth/otp/request",
          params: {"phone_number": phoneNumber, "country_code": COUNTRY_CODE});

      if (mounted) {
        if (response['resp_code'] == "200") {
          showToast("sms_sent_successfully".tr(), context);
        } else {
          showToast(response["resp_data"]['message'].toString(), context);
        }
        setState(() {
          isResend = false;
          isLoadingResendButton = false;
          sendCount = sendCount + 1;
        });
      }
    }
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false);
  }

  verifyLogin() async {
    if (mounted)
      setState(() {
        isLoadingButton = true;
      });

    if (!onValidate() || isVerifyOTP) {
      return;
    }

    var phoneNumber = widget.data['phone_number'];

    var response =
        await netPost(isUserToken: false, endPoint: "auth/otp/verify", params: {
      "phone_number": phoneNumber,
      "otp": codeController.text,
      "country_code": COUNTRY_CODE
    });

    if (response['resp_code'] == "200") {
      var userData = response["resp_data"]['data'];

      // mix panel
      dynamic dataPanel = {"phone": phoneNumber, "otp": codeController.text};

      mixpanel.track(ENTER_OTP, properties: dataPanel);
      // no profile account
      await setStorage(STORAGE_USER, userData);

      await getStorageUser();

      bool isFirstTimeLogin =
          response['resp_data']['data']['is_first_time_login'];

      if (isFirstTimeLogin) {
        // first time
        Navigator.pushNamed(context, "/add_name_page");
      } else {
        // profile + token
        var user = await getProfileData(context);

        await setStorage(STORAGE_USER, user);

        await getStorageUser();
        // second time
        Future.delayed(Duration.zero, () async {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/root_app",
            (route) => false,
            arguments: {"activePageIndex": 0},
          );
        });
      }
    } else {
      var message = reponseErrorMessage(response,
          requestedParams: ["phone_number", "otp"]);
      notifyAlert(context, desc: message, btnTitle: "Ok!", onConfirm: () {
        Navigator.pop(context);
      });
    }
    if (mounted)
      setState(() {
        isVerifyOTP = false;
        isLoadingButton = false;
      });
  }
}
