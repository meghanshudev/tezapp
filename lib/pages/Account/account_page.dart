import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/dummy_data/language_json.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Account/customer_support_page.dart';
import 'package:tezchal/pages/Account/edit_profile_page.dart';
import 'package:tezchal/pages/Account/general_info_page.dart';
import 'package:tezchal/pages/Account/suggest_page.dart';
import 'package:tezchal/pages/Account/wallet_page.dart';
import 'package:tezchal/pages/Location/choose_location_page.dart';
import 'package:tezchal/pages/UserGroup/user_group_page.dart';
import 'package:tezchal/pages/UserGroup/user_group_view_page.dart';
import 'package:tezchal/provider/has_group.dart';
import 'package:tezchal/ui_elements/card_item.dart';
import '../../ui_elements/slider_widget.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List groupMember = [];
  int orderDay = 0;
  String byLeader = '';
  String name = '';
  String phoneNumber = '';
  String groupProfile = '';
  List ads = [];
  bool isAdsLoading = false;
  int orderTotal = 0;
  String createdDate = '';
  int langIndex = 0;
  String lang = "English";

  @override
  void initState() {
    super.initState();

    fetchAds();
    getMember();

    name =
        !checkIsNullValue(userSession['name'] ?? "")
            ? userSession['name'] ?? ""
            : "N/A";
    phoneNumber =
        !checkIsNullValue(userSession['phone_number'])
            ? userSession['phone_number']
            : "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: white, body: getBody());
  }

  fetchAds() async {
    setState(() {
      isAdsLoading = true;
    });

    var params = {"limit": "0", "order": "rgt", "sort": "asc"};

    var response = await netGet(endPoint: "advertisement", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List adsItems = data['list'] ?? [];
      if (mounted) {
        setState(() {
          ads = adsItems;
        });
      }
    } else {
      setState(() {
        ads = [];
      });
    }
    setState(() {
      isAdsLoading = false;
    });
  }

  getMember() async {
    if (!checkIsNullValue(userSession['group'])) {
      var groupId = userSession['group']['id'];
      var response = await netGet(endPoint: "group/$groupId");
      if (response["resp_code"] == "200") {
        List data = response['resp_data']['data']['members'];
        setState(() {
          groupMember = data;
          orderDay = response['resp_data']['data']['order_day'];
          orderTotal = response['resp_data']['data']['total_group_orders'];
          createdDate = response['resp_data']['data']['created_date'];
          groupProfile =
              !checkIsNullValue(response['resp_data']['data']['image'])
                  ? response['resp_data']['data']['image'].toString()
                  : DEFAULT_GROUP_IMAGE;
        });
        if (!checkIsNullValue(
          response['resp_data']['data']['leader']['name'],
        )) {
          setState(() {
            byLeader = response['resp_data']['data']['leader']['name'];
          });
        } else {
          setState(() {
            byLeader = " • ";
          });
        }
      }
    }
    // set group leader profile
    // context.read<HasGroupProvider>().refreshGroupLeaderProfile(groupProfile);
  }

  void getCurrentLang(BuildContext context) async {
    var currentLang = context.locale.toString();
    if (currentLang == "en_US") {
      setState(() {
        lang = "English";
        langIndex = 0;
      });
    } else {
      setState(() {
        lang = "हिन्दी";
        langIndex = 1;
      });
    }
  }

  setLang(int index) async {
    if (index == 0) {
      // Set Session
      var lang = "en";
      await setStorage(LANGUAGE, lang);
      await getStorage(LANGUAGE);
      context.setLocale(APP_LOCALES[0]);
    } else {
      // Set Session
      var lang = "hi";
      await setStorage(LANGUAGE, lang);
      await getStorage(LANGUAGE);
      context.setLocale(APP_LOCALES[1]);
    }
  }

  @override
  void didChangeDependencies() {
    getCurrentLang(context);
    super.didChangeDependencies();
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: normalBoldBlackTitle),
                  SizedBox(height: 2),
                  Text(phoneNumber, style: smallMediumGreyText),
                ],
              ),
              TextButton(
                onPressed: () async {
                  dynamic result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfile()),
                  );
                  setState(() {
                    name = result;
                  });
                },
                child: Text(
                  "edit_profile".tr().toUpperCase(),
                  style: meduimBoldPrimaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          getAccountSection(),
          SizedBox(height: 20),
          getHelpAndFeedbackSection(),
          SizedBox(height: 25),
          getLogoutSection(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget getAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardItem(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WalletPage()),
              ),
          icon: MaterialCommunityIcons.wallet,
          title: "tez_cash".tr(),
          subTitle: "view_your_wallet".tr(),
        ),
        SizedBox(height: 10),
        // context.watch<HasGroupProvider>().hasGroup
        //     ? CardItem(
        //       onTap:
        //           () => Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => UserGroupViewPage(),
        //             ),
        //           ),
        //       icon: MaterialCommunityIcons.account_group,
        //       title: "Tez Group",
        //       subTitle: "Join or start your Tez group",
        //     )
        //     : CardItem(
        //       onTap:
        //           () => Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (context) => UserGroupPage()),
        //           ),
        //       icon: MaterialCommunityIcons.account_group,
        //       title: "Tez Group",
        //       subTitle: "Join or start your Tez group",
        //     ),
        // SizedBox(height: 10),
        CardItem(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChoooseLocationPage()),
              ),
          icon: MaterialCommunityIcons.crosshairs_gps,
          title: "change_location".tr(),
          subTitle: "set_or_change_your_delivery_location".tr(),
        ),
        SizedBox(height: 10),
        CardItem(
          onTap: () => onChangedLang(),
          icon: MaterialIcons.language,
          title: lang,
          subTitle: "choose_your_language".tr(),
        ),
      ],
    );
  }

  Widget getHelpAndFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("help_&_feedback", style: normalBoldBlackTitle).tr(),
        SizedBox(height: 20),
        CardItem(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerSupportPage()),
              ),
          icon: MaterialIcons.chat,
          title: "customer_support".tr(),
          subTitle: "have_an_issue_chat_with_us".tr(),
        ),
        SizedBox(height: 10),
        CardItem(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuggestPage()),
              ),
          icon: MaterialIcons.tag_faces,
          title: "suggest_us".tr(),
          subTitle: "tell_us_what_you_want_on_tez".tr(),
        ),
        SizedBox(height: 10),
        CardItem(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeneralInfoPage()),
              ),
          icon: MaterialIcons.info,
          title: "general_information".tr(),
          subTitle: "privacy_policy_terms_&_about_tez".tr(),
        ),
      ],
    );
  }

  Widget getLogoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            confirmAlert(
              context,
              des: "are_you_sure_you_want_to_logout?".tr(),
              onCancel: () => Navigator.pop(context),
              onConfirm: () => onSignOut(context),
            );
          },
          child: Text("logout", style: normalBoldPrimaryTitle).tr(),
        ),
      ],
    );
  }

  onChangedLang() async {
    int tempIndex = langIndex;
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("choose_your_language".tr(),
                          style: normalBoldBlackTitle),
                      TextButton(
                        onPressed: () {
                          setLang(tempIndex);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "done".tr(),
                          style: TextStyle(color: primary, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      return RadioListTile(
                        title: Text(languages[index]),
                        value: index,
                        groupValue: tempIndex,
                        activeColor: primary,
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              tempIndex = value;
                            });
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
