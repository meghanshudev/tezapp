import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/network.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/provider/account_info_provider.dart';
import 'package:tezapp/ui_elements/custom_primary_button.dart';
import 'package:tezapp/ui_elements/custom_primary_button_suffix.dart';
import 'package:tezapp/ui_elements/custom_textfield.dart';
import 'package:tezapp/ui_elements/error_message.dart';

class AddNamePage extends StatefulWidget {
  const AddNamePage({Key? key}) : super(key: key);

  @override
  _AddNamePageState createState() => _AddNamePageState();
}

class _AddNamePageState extends State<AddNamePage> {
  TextEditingController nameController = TextEditingController();

  double paddingTopAnimation = 0;

  bool isAddName = false;
  bool isName = false;
  String nameMessage = '';

  int pageIndex = 0;

  bool isLoadingButton = false;

  late Mixpanel mixpanel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     initMixpanel();
  }
  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
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
                              "your_profile",
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
                        child: CustomTextField(
                          controller: nameController,
                          hintText: "enter_your_name".tr(),
                        ),
                      ),
                      ErrorMessage(
                        isError: isName,
                        message: nameMessage,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            Flexible(
                                child: GestureDetector(
                              onTap: () async {
                                // change button color
                                setState(() {
                                  pageIndex = 0;
                                });
                                // Set Session
                                var lang = "en";
                                await setStorage(LANGUAGE, lang);
                                await getStorage(LANGUAGE);
                                context.setLocale(APP_LOCALES[0]);
                              },
                              child: pageIndex == 0 ?  CustomPrimaryButton(
                                text: "English",
                              ) : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(color: primary),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  "English",
                                  style: normalPrimaryText,
                                )),
                              ),
                            )),
                            SizedBox(
                              width: 15,
                            ),
                            Flexible(
                                child: GestureDetector(
                              onTap: () async {
                                // change button color
                                setState(() {
                                  pageIndex = 1;
                                });
                                // Set Session
                                var lang = "hi";
                                await setStorage(LANGUAGE, lang);
                                await getStorage(LANGUAGE);
                                context.setLocale(APP_LOCALES[1]);
                              },
                              child: pageIndex == 1 ?  CustomPrimaryButton(
                                text: "हिन्दी",
                              ) :  Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(color: primary),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  "हिन्दी",
                                  style: normalPrimaryText,
                                )),
                              ),
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: GestureDetector(
                          onTap: () {
                            onSignUp();
                          },
                          child: CustomPrimaryButtonSuffixIcon(
                            isLoading: isLoadingButton,
                            text: "start_using_tez".tr(),
                          ),
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
      isName = false;
    });

    if (checkIsNullValue(nameController.text)) {
      if (mounted) {
        setState(() {
          isName = true;
          nameMessage = "please_enter_name".tr();
        });
      }
      res = false;
    }

    return res;
  }

  onSignUp() async {
    if (!onValidate() || isAddName) {
      return;
    }
    if (mounted)
      setState(() {
        isAddName = true;
        isLoadingButton = true;
      });

    var name = nameController.text;

    var response = await netPost(
        isUserToken: true,
        endPoint: "me/update/profile",
        params: {
          "name": name,
        });
    if (mounted)
      setState(() {
        isAddName = false;
        isLoadingButton = false;
      });

    if (response['resp_code'] == "200") {

      // mix panel
      dynamic dataPanel = {
      "name" : name
    };

    mixpanel.track(ADD_NAME,properties: dataPanel);

      var user = await getProfileData(context);

      

      await setStorage(STORAGE_USER, user);

      await getStorageUser();

      context.read<AccountInfoProvider>().refreshName(userSession['name'] ?? "");


      Future.delayed(Duration.zero, () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/root_app",
          (route) => false,
          arguments: {"activePageIndex": 0},
        );
      });
    } else {
      print(response);
      var message = reponseErrorMessage(response, requestedParams: ["name"]);
      notifyAlert(context, desc: message, btnTitle: "Ok!", onConfirm: () {
        Navigator.pop(context);
      });
    }
  }
}
