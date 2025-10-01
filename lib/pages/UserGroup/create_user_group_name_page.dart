import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/UserGroup/create_user_group_page.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_textfield.dart';
import 'package:tezchal/ui_elements/slider_widget.dart';

import '../../ui_elements/custom_footer_buttons.dart';
import '../../ui_elements/error_message.dart';

class CreateUserGroupNamePage extends StatefulWidget {
  const CreateUserGroupNamePage({Key? key}) : super(key: key);

  @override
  State<CreateUserGroupNamePage> createState() =>
      _CreateUserGroupNamePageState();
}

class _CreateUserGroupNamePageState extends State<CreateUserGroupNamePage> {
  TextEditingController nameController = TextEditingController();

  bool isAdsLoading = false;
  List ads = [];

  String zipCode = '';
  var deliverTo = '';

  @override
  void initState() {
    super.initState();
    initPage();
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code']
            : "";
  }

  initPage() async {
    await fetchAds();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: CustomAppBar(
            subtitle:
                zipCode + " - " + context.watch<AccountInfoProvider>().name,
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  bool isRequiredGroupName = false;
  String groupNameMessage = "";
  bool validateForm() {
    bool res = true;
    if (checkIsNullValue(nameController.text)) {
      res = false;
      setState(() {
        isRequiredGroupName = true;
        groupNameMessage = "please_enter_group_name".tr();
      });
    }
    return res;
  }

  Widget getFooter() {
    return CustomFooterButtons(
      proceedTitle: "proceed".tr(),
      titleCenter: true,
      titlePadding: EdgeInsets.zero,
      onTapProceed: () {
        if (validateForm())
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CreateUserGroupPage(
                    data: {"name": nameController.text, "join": true},
                  ),
            ),
          );
      },
      onTapBack: () {
        Navigator.of(context).pop();
      },
    );
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
                Text("create_your_tez_group", style: normalBoldBlackTitle).tr(),
                SizedBox(height: 2),
                Text("5%_commission", style: smallMediumGreyText).tr(),
                SizedBox(height: 20),
                SliderWidget(items: ads),
                SizedBox(height: 20),
                Container(
                  width: size.width,
                  child: CustomTextField(
                    controller: nameController,
                    hintText: "group_name".tr(),
                  ),
                ),
                ErrorMessage(
                  isError: isRequiredGroupName,
                  message: groupNameMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
