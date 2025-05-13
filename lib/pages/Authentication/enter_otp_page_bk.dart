

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
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

class EnterOTPPageBK extends StatefulWidget {
  final data;
  const EnterOTPPageBK({Key? key, this.data}) : super(key: key);

  @override
  _EnterOTPPageBKState createState() => _EnterOTPPageBKState();
}

class _EnterOTPPageBKState extends State<EnterOTPPageBK> {
  TextEditingController codeController = TextEditingController();

  double paddingTopAnimation = 0;
  bool isVerifySignUp = false;
  bool isVerifyOTP = false;
  bool isResend = false;
  bool isCode = false;
  String codeMessage = '';

  bool isLoadingButton = false;
  bool isLoadingResendButton = false;

  // firebase otp
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool isCodeSent = false;
  String _verificationId = "";
  int? _resendToken;
  @override
  void initState() {
    super.initState();
    _onVerifyCode();
  }
  

  void _onVerifyCode() async {
    Future.delayed(Duration.zero,() {
        //use context here
      loadingAlert(context);
    });
    
    // new Future.delayed(new Duration(seconds: 1), );
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
          // Handle loogged in state
          print(value.user?.phoneNumber);
          //  setState(() {
          //   isVerifyOTP = false;
          //   isLoadingButton = false;
          //   isCode = false;
          //   isCodeSent = false;
          // });
           Navigator.pop(context);
        } else {
          notifyAlert(context,
              desc: "Error validating OTP, try again",
              btnTitle: "Ok!", onConfirm: () {
            Navigator.pop(context);
          });
          setState(() {
            isVerifyOTP = false;
            isLoadingButton = false;
            isCode = false;
            isCodeSent = false;
          });
          Navigator.pop(context);
        }
      }).catchError((error) {
        // showToast(error.message.toString(), context);
        notifyAlert(context, desc: "Try again in sometime", btnTitle: "Ok!",
            onConfirm: () {
          Navigator.pop(context);
        });
        setState(() {
          isVerifyOTP = false;
          isLoadingButton = false;
          isCode = false;
          isCodeSent = false;
        });
         Navigator.pop(context);
      });
    };
    final PhoneVerificationFailed verificationFailed = (authException) {
      // showToast(authException.message.toString(), context);
      notifyAlert(context,
          desc: authException.message.toString(),
          btnTitle: "Ok!", onConfirm: () {
        Navigator.pop(context);
      });
      setState(() {
        isCodeSent = false;
      });
       Navigator.pop(context);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    // TODO: Change country code
    await _firebaseAuth.setSettings(appVerificationDisabledForTesting: false);
    await _firebaseAuth.verifyPhoneNumber(
        forceResendingToken:  _resendToken,
        phoneNumber: "$PREFIX_PHONE${widget.data['phone_number']}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          setState(() {
             isCodeSent = false;
          });
           Navigator.pop(context);
        },
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

      
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        body: getBody() ,
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
                  height: size.height * 0.48,
                  decoration: BoxDecoration(color: primary),
                  child: Center(
                      child: Text(
                    "tez",
                    style: logoText,
                  )),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.52,
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
                                  onVerifyOTP();
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
                            // SizedBox(
                            //   width: 15,
                            // ),
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  onVerifyOTP();
                                },
                                child: Container(
                                  // width: 95,
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
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Flexible(
                                child: GestureDetector(
                              onTap: () {
                                // onResend();
                                _onVerifyCode();
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(color: primary),
                                    borderRadius: BorderRadius.circular(10)),
                                child: isLoadingResendButton
                                    ? CustomButtonLoading(
                                        color: primary,
                                      )
                                    : Center(
                                        child: Text(
                                        "resend_sms",
                                        style: normalPrimaryText,
                                      ).tr()),
                              ),
                            )),
                            // SizedBox(
                            //   width: 15,
                            // ),
                            // Expanded(
                            //   child: Container(
                            //     height: 50,
                            //     decoration: BoxDecoration(
                            //       border: Border.all(color: primary),
                            //       borderRadius: BorderRadius.circular(10)
                            //     ),
                            //     child: Center(child: Text("Call Me", style: normalPrimaryText,)),
                            //   )
                            // )
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

 

  // onResend() async {
  //   if (isResend) {
  //     return;
  //   }
  //   if (mounted) {
  //     setState(() {
  //       isResend = true;
  //       isLoadingResendButton = true;
  //     });

  //     var phoneNumber = widget.data['phone_number'];
  //     var response = await netPost(
  //         isUserToken: false,
  //         endPoint: "auth/otp/request",
  //         params: {
  //           "phone_number": phoneNumber,
  //         });

  //     if (mounted) {
  //       if (response['resp_code'] == "200") {
  //         notifyAlert(context,
  //             desc: "sms_sent_successfully".tr(),
  //             btnTitle: "Ok!", onConfirm: () {
  //           Navigator.pop(context);
  //         });
  //       } else {
  //         notifyAlert(context,
  //             desc: response["resp_data"]['message'].toString(),
  //             btnTitle: "Ok!", onConfirm: () {
  //           Navigator.pop(context);
  //         });
  //       }
  //       setState(() {
  //         isResend = false;
  //         isLoadingResendButton = false;
  //       });
  //     }
  //   }
  // }

  // firebase otp
  onVerifyOTP() async {
    if (!onValidate() || isVerifyOTP) {
      return;
    }
    if (mounted)
      setState(() {
        isVerifyOTP = true;
        isLoadingButton = true;
        
      });

    AuthCredential _authCredential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: codeController.text,
    );

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((UserCredential value) async {
      if (value.user != null) {
        print(value.user?.phoneNumber);
        print("success");
        // post to login
        await verifyLogin();
      } else {
        notifyAlert(context,
            desc: "Error validating OTP, try again",
            btnTitle: "Ok!", onConfirm: () {
          Navigator.pop(context);
        });
        setState(() {
          isVerifyOTP = false;
          isLoadingButton = false;
          isCodeSent = false;
        });
      }
    }).catchError((error) {
      notifyAlert(context, desc: "Invalid OTP, try again", btnTitle: "Ok!",
          onConfirm: () {
        Navigator.pop(context);
      });
      setState(() {
        isVerifyOTP = false;
        isLoadingButton = false;
        isCodeSent = false;
      });
    });
  }

  verifyLogin() async {
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
}
