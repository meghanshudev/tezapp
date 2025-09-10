import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/UserGroup/create_user_group_name_page.dart';
import 'package:tezchal/provider/has_group.dart';
import 'package:tezchal/root_app.dart';
import 'package:tezchal/ui_elements/custom_button.dart';
import 'package:tezchal/ui_elements/custom_primary_button_suffix.dart';
import 'package:tezchal/ui_elements/custom_textfield.dart';
import 'package:tezchal/ui_elements/error_message.dart';
import 'package:tezchal/ui_elements/slider_widget.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_footer.dart';
import 'package:tezchal/provider/account_info_provider.dart';

class UserGroupPage extends StatefulWidget {
  const UserGroupPage({Key? key}) : super(key: key);

  @override
  _UserGroupPageState createState() => _UserGroupPageState();
}

class _UserGroupPageState extends State<UserGroupPage> {
  bool isLoadingButton = false;
  var zipCode = '';

  TextEditingController groupCodeController = TextEditingController();

  bool isAdsLoading = false;
  List ads = [];

  bool isJoinGroup = false;

  bool isEnterGroupID = false;
  String groupIDMessage = '';

  late Mixpanel mixpanel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPage();
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code']
            : "";

    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(
      MIX_PANEL,
      optOutTrackingDefault: false,
      trackAutomaticEvents: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar(
          subtitle: zipCode + " - " + context.watch<AccountInfoProvider>().name,
          subtitleIcon: Entypo.location_pin,
        ),
      ),
      body: getBody(),
      bottomNavigationBar: CustomFooter(
        onTapBack: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  initPage() async {
    await fetchAds();
  }

  fetchAds() async {
    // if(mounted)
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

    if (mounted) {
      setState(() {
        isAdsLoading = false;
      });
    }
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("your_tez_group", style: normalBoldBlackTitle).tr(),
                SizedBox(height: 2),
                Text(
                  "get_upto_75%_off_when_you_buy_in_a_group",
                  style: smallMediumGreyText,
                ).tr(),
                SizedBox(height: 20),
                SliderWidget(items: ads),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child:
                      Text(
                        "become_a_tez_group_leader_and_get_your_kirana_for_free_5%_commission_and_more",
                        textAlign: TextAlign.center,
                        style: smallMediumBoldBlackText.copyWith(height: 1.5),
                      ).tr(),
                ),
                SizedBox(height: 20),
                CustomButton(
                  icon: Icons.add,
                  title: "create_a_tez_group".tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateUserGroupNamePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
              Flexible(child: Divider(thickness: 0.8, color: placeHolderColor)),
              SizedBox(width: 20),
              Text("or", style: normalGreyText).tr(),
              SizedBox(width: 20),
              Flexible(child: Divider(thickness: 0.8, color: placeHolderColor)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("join_a_tez_group", style: normalBoldBlackTitle).tr(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: CustomTextField(
                        controller: groupCodeController,
                        hintText: "enter_group_id".tr(),
                      ),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          joinGroup();
                        },
                        child: CustomPrimaryButtonSuffixIcon(
                          isLoading: isLoadingButton,
                          text: "join".tr(),
                        ),
                      ),
                    ),
                  ],
                ),
                ErrorMessage(isError: isEnterGroupID, message: groupIDMessage),
                SizedBox(height: 20),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text(
                //           "You can also click on the ",
                //           style: smallMediumGreyText,
                //         ),
                //         Text(
                //           "Group Invite Link ",
                //           style: smallMediumBoldBlackText,
                //         ),
                //       ],
                //     ),
                //     SizedBox(
                //       height: 5,
                //     ),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Text(
                //           "that you received to directly join the group.",
                //           style: smallMediumGreyText,
                //         ),
                //       ],
                //     )
                //   ],
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child:
                      Text(
                        "you_can_also_click",
                        textAlign: TextAlign.center,
                        style: smallMediumGreyText.copyWith(height: 1.5),
                      ).tr(),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  searchGroup(data) async {
    var response = await netGet(
      isUserToken: true,
      endPoint: "group/code/$data",
    );

    if (mounted) {
      if (response['resp_code'] == "200") {
        return response['resp_data']['data'] ?? null;
      } else {
        return null;
      }
    }
  }

  onValidate() {
    bool res = true;

    setState(() {
      isEnterGroupID = false;
    });

    if (checkIsNullValue(groupCodeController.text)) {
      if (mounted) {
        setState(() {
          isEnterGroupID = true;
          groupIDMessage = "group_id_is_required".tr();
        });
      }
      res = false;
    }

    return res;
  }

  joinGroup() async {
    if (!onValidate() || isJoinGroup) {
      return;
    }
    if (mounted)
      setState(() {
        isJoinGroup = true;
        isLoadingButton = true;
      });

    var result = await searchGroup(groupCodeController.text);

    if (!checkIsNullValue(result)) {
      // has
      var groupId = result['id'];

      var response = await netPost(
        isUserToken: true,
        endPoint: "group/$groupId/join",
        params: {},
      );

      if (mounted) {
        if (response['resp_code'] == "200") {
          // mix panel
          dynamic dataPanel = {
            "phone": userSession['phone_number'],
            "group_code": groupCodeController.text,
          };

          mixpanel.track(CLICK_JOIN_GROUP, properties: dataPanel);

          // showToast("you_have_request_to_group_successfully".tr(), context);
          notifyAlert(
            context,
            desc: "you_have_request_to_group_successfully".tr(),
            btnTitle: "Ok",
            onConfirm: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => RootApp()),
                (Route<dynamic> route) => false,
              );
            },
          );
          setState(() {
            groupCodeController.text = "";
          });
        } else {
          // showToast(response['resp_data']['message'], context);
          notifyAlert(
            context,
            desc: response['resp_data']['message'],
            btnTitle: "Ok",
            onConfirm: () {
              Navigator.pop(context);
            },
          );
        }
      }
    } else {
      notifyAlert(
        context,
        desc: "group_not_found".tr(),
        btnTitle: "Ok",
        onConfirm: () {
          Navigator.pop(context);
        },
      );
    }

    setState(() {
      isJoinGroup = false;
      isLoadingButton = false;
    });
  }
}
