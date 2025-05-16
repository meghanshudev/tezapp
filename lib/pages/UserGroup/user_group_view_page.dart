import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/provider/has_group.dart';
import 'package:tezapp/ui_elements/custom_primary_button.dart';
import 'package:tezapp/ui_elements/user_group_view_loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tezapp/ui_elements/custom_appbar.dart';
import 'package:tezapp/ui_elements/custom_footer.dart';
import 'package:tezapp/provider/account_info_provider.dart';

import '../../helpers/network.dart';

class UserGroupViewPage extends StatefulWidget {
  UserGroupViewPage({Key? key}) : super(key: key);

  @override
  State<UserGroupViewPage> createState() => _UserGroupViewPageState();
}

class _UserGroupViewPageState extends State<UserGroupViewPage> {
  List groupMember = [];
  int orderDay = 1;
  String byLeader = '';
  String leaderId = '';
  bool isLoading = false;
  List specialRates = [];
  int orderTotal = 0;
  String createdDate = '';
  String groupProfile = '';
  String groupCode = '';
  var zipCode = '';

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initialize();
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";

    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  Future initialize() async {
    setState(() {
      isLoading = true;
    });
    // set storage
    var user = await getProfileData(context);
    await setStorage(STORAGE_USER, user);
    await getStorageUser();

    await getMember();
    await fetchSpecialRate();
  }

  fetchSpecialRate() async {
    setState(() {
      isLoading = true;
    });
    var response =
        await netGet(isUserToken: true, endPoint: "product", params: {
      "page": "1",
      "limit": "5",
      "order": "name",
      "sort": "asc",
    });

    if (response['resp_code'] == "200") {
      if (mounted) {
        setState(() {
          isLoading = false;
          specialRates = response['resp_data']['data']['list'];
        });
      }
    } else {
      setState(() {
        isLoading = false;
        specialRates = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomAppBar(
            subtitle:
                zipCode + " - " + context.watch<AccountInfoProvider>().name,
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        body: isLoading ? UserGroupViewLoading() : getBody(),
        bottomNavigationBar: CustomFooter(
          onTapBack: () {
            Navigator.of(context).pop();
          },
        ));
  }

  getMember() async {
    if (!checkIsNullValue(userSession['group'])) {
      var groupId = userSession['group']['id'];

      var response = await netGet(endPoint: "group/$groupId");
      if (response["resp_code"] == "200") {
        List data = response['resp_data']['data']['members'];

        setState(() {
          groupMember = data;
          orderDay = response['resp_data']['data']['order_day'] ?? 1;
          leaderId = response['resp_data']['data']['leader']['id'].toString();
          orderTotal = response['resp_data']['data']['total_group_orders'] ?? 0;
          createdDate = response['resp_data']['data']['created_date'] ?? "";
          groupProfile =
              !checkIsNullValue(response['resp_data']['data']['image'])
                  ? response['resp_data']['data']['image'].toString()
                  : DEFAULT_GROUP_IMAGE;
          groupCode =
              !checkIsNullValue(response['resp_data']['data']['group_code'])
                  ? (response['resp_data']['data']['group_code'])
                  : '';
        });
        if (!checkIsNullValue(
            response['resp_data']['data']['leader']['name'])) {
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

    // set new order day
    context.read<HasGroupProvider>().refreshOrderDay(orderDay);
    //  set new number of member
    context.read<HasGroupProvider>().refreshGroupNumber(groupMember.length);
    // set user group profile
    context.read<HasGroupProvider>().refreshGroupLeaderProfile(groupProfile);
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 5,
      ),
      Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "your_tez_group",
            style: normalBoldBlackTitle,
          ).tr(),
          SizedBox(
            height: 2,
          ),
          Text(
            "get_upto_75%_off_when_you_buy_in_a_group",
            style: smallMediumGreyText,
          ).tr(),
          SizedBox(
            height: 20,
          ),
          Container(
            width: size.width,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: white,
              boxShadow: [
                BoxShadow(
                    color: black.withOpacity(0.06),
                    spreadRadius: 5,
                    blurRadius: 10)
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 13, right: 13, top: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(context
                                  .watch<HasGroupProvider>()
                                  .groupLeaderProfile),
                              fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              checkIsNullValue(userSession['group'])
                                  ? "N/A"
                                  : userSession['group']['name'],
                              style: meduimBoldBlackText,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              context.watch<HasGroupProvider>().groupNumber == 1
                                  ? context
                                          .watch<HasGroupProvider>()
                                          .groupNumber
                                          .toString() +
                                      " " +
                                      "member".tr() +
                                      " • " +
                                      "by".tr() +
                                      " " +
                                      byLeader
                                  : context
                                          .watch<HasGroupProvider>()
                                          .groupNumber
                                          .toString() +
                                      " " +
                                      "members".tr() +
                                      " • " +
                                      "by".tr() +
                                      " " +
                                      byLeader,
                              style: smallMediumGreyText,
                            ),
                            // SizedBox(
                            //   height: 8,
                            // ),
                            // Text(
                            //   "orders_every".tr() + getOrderDay(context.watch<HasGroupProvider>().orderDay),
                            //   style: smallMediumBoldBlackText,
                            // )
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "since".tr() +
                              " " +
                              "${formatDate(createdDate)}  •  $orderTotal" +
                              " " +
                              "orders".tr(),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      leaderId == userSession['id'].toString()
                          ? Container(
                              // height: 25,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 12),
                                child: Text(
                                  groupCode,
                                  style: smallBoldWhiteText,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  SizedBox(
                    height: 0,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.of(context).pushNamed('/leader_view_detail_page');
          //   },
          //   child: CustomPrimaryButton(
          //     text: "View Details",
          //   ),
          // ),

          Row(
            children: [
              leaderId == userSession['id'].toString()
                  ? Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/leader_view_detail_page');
                        },
                        child: CustomPrimaryButton(
                          text: "view_details".tr(),
                        ),
                      ),
                    )
                  : Container(),
              leaderId == userSession['id'].toString()
                  ? SizedBox(
                      width: 20,
                    )
                  : Container(),
              Expanded(
                child: leaderId == userSession['id'].toString()
                    ? InkWell(
                        onTap: () async {
                          Navigator.pushNamed(context, "/edit_user_group_page");
                          // deleteGroup();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: placeHolderColor)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Center(
                              child: Text(
                                "edit_group",
                                style: normalBlackText,
                              ).tr(),
                            ),
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          leaveGroup();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: placeHolderColor)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Center(
                              child: Text(
                                "leave_group",
                                style: normalBlackText,
                              ).tr(),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          // SizedBox(height: 20,),
          // leaderId == userSession['id'].toString() ? GestureDetector(
          //         onTap: () {
          //           deleteGroup();
          //         },
          //         child: CustomPrimaryButton(
          //           text: "delete_group".tr(),
          //         ),
          //       ) : Container(),
          SizedBox(
            height: 20,
          ),
          leaderId == userSession['id'].toString()
              ? Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        shareLeaderOnWhatsapp();
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: whatsAppColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LineIcons.whatSApp,
                              color: white,
                              size: 25,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              "share_group_on_whatsapp",
                              style: normalWhiteText,
                            ).tr()
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                )
              : Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        shareMemberOnWhatsapp();
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: whatsAppColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LineIcons.whatSApp,
                              color: white,
                              size: 25,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              "share",
                              style: normalWhiteText,
                            ).tr()
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
          leaderId == userSession['id'].toString()
              ? InkWell(
                  onTap: () {
                    // mix panel
                    dynamic dataPanel = {
                      "phone": userSession['phone_number'],
                      "how_to_earn_using_tez_group":
                          "how_to_earn_using_tez_group"
                    };

                    mixpanel.track(CLICK_HOW_TO_EARN_TEZ_GROUPS,
                        properties: dataPanel);

                    Navigator.pushNamed(context, "youtube_link_page",
                        arguments: {
                          "link": EARN_WITH_TEZ,
                          "title": "how_to_earn_using_tez_groups".tr()
                        });
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: placeHolderColor)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Center(
                        child: Text(
                          "how_to_earn_using_tez_groups",
                          style: normalBlackText,
                        ).tr(),
                      ),
                    ),
                  ),
                )
              : Container(),
        ]),
      ),
      SizedBox(
        height: 5,
      ),
    ]));
  }

  deleteGroup() async {
    confirmAlert(context, des: "delete_group_des".tr(), onCancel: () {
      Navigator.pop(context);
    }, onConfirm: () async {
      var groupId = userSession['group']['id'];

      var response = await netDelete(
          isUserToken: true, endPoint: "group/$groupId", params: {});

      if (mounted) {
        if (response['resp_code'] == "200") {
          // set refresh group
          context.read<HasGroupProvider>().refreshGroup(false);
          // set new session for group
          userSession['group'] = null;
          await setStorage(STORAGE_USER, userSession);

          await getStorageUser();

          showToast("you_have_left_a_group_successfully".tr(), context);

          Navigator.pop(context);
          //
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/root_app",
            (route) => false,
            arguments: {"activePageIndex": 1},
          );
        } else {
          Navigator.pop(context);
          notifyAlert(context,
              desc: response['resp_data']['message'].toString(),
              btnTitle: "Ok!", onConfirm: () {
            Navigator.pop(context);
          });
        }
      }
    });
  }

  shareLeaderOnWhatsapp() async {
    String text =
        "Hi, I have become a Tez Group Leader! Aab sab kuch ek jageh – Tez – Aapka Smart Kiranewala. Sasta aur Bharosemand! Join my Group ID: $groupCode to get up to 75% OFF! Download the app: $PLAY_STORE_LINK";
    if (Platform.isIOS) {
      if (await canLaunch(WHATSAPP_IOS_URL)) {
        await launch(WHATSAPP_IOS_URL + "&text=${Uri.encodeFull(text)}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp_not_installed".tr())));
      }
    } else {
      if (await canLaunch(WHATSAPP_ANDROID_URL)) {
        await launch(WHATSAPP_ANDROID_URL + "&text=" + Uri.encodeFull(text));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp_not_installed".tr())));
      }
    }
    // mix panel
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "share_group_whatsapp": "share_group_whatsapp"
    };

    mixpanel.track(CLICK_SHARE_GROUP_ON_WHATSAPP, properties: dataPanel);
  }

  shareMemberOnWhatsapp() async {
    String text =
        "Hi, I am using Tez App to shop my Kirana and getting upto 75% OFF! Aab sab kuch ek jageh – Tez – Aapka Smart Kiranewala. Sasta aur Bharosemand! Download the app: $PLAY_STORE_LINK";
    if (Platform.isIOS) {
      if (await canLaunch(WHATSAPP_IOS_URL)) {
        await launch(WHATSAPP_IOS_URL + "?phone=&text=${Uri.encodeFull(text)}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp_not_installed".tr())));
      }
    } else {
      if (await canLaunch(WHATSAPP_ANDROID_URL)) {
        await launch(WHATSAPP_ANDROID_URL + "&text=" + Uri.encodeFull(text));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp_not_installed".tr())));
      }
    }
    // mix panel
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "share_group_whatsapp": "share_group_whatsapp"
    };

    mixpanel.track(CLICK_SHARE_GROUP_ON_WHATSAPP, properties: dataPanel);
  }

  leaveGroup() async {
    var groupId = userSession['group']['id'];
    var response = await netPost(
        isUserToken: true, endPoint: "group/$groupId/left", params: {});

    if (mounted) {
      if (response['resp_code'] == "200") {
        // set refresh group
        context.read<HasGroupProvider>().refreshGroup(false);

        // set new session for group

        userSession['group'] = null;
        await setStorage(STORAGE_USER, userSession);

        await getStorageUser();

        showToast("you_have_left_a_group_successfully".tr(), context);

        Navigator.pop(context);
        //
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/root_app",
          (route) => false,
          arguments: {"activePageIndex": 1},
        );
      } else {
        showToast(response['resp_data']['message'].toString(), context);
      }
    }
  }
}
