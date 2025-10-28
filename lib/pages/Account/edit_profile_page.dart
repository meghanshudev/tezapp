import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_footer_buttons.dart';
import 'package:tezchal/ui_elements/custom_textfield.dart';

import '../../ui_elements/error_message.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoadingButton = false;
  String name = '';

  bool isName = false;
  String nameMessage = '';

  var zipCode = '';
  var deliverTo = '';
  String phone = '';
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() {
    nameController.text =
        !checkIsNullValue(userSession['name'] ?? "") ? userSession['name'] ?? "" : "N/A";
    phoneController.text = !checkIsNullValue(userSession['phone_number'])
        ? userSession['phone_number']
        : "N/A";
    emailController.text =
        !checkIsNullValue(userSession['email']) ? userSession['email'] : "";
    name = !checkIsNullValue(userSession['name'] ?? "") ? userSession['name'] ?? "" : "N/A";

    deliverTo = !checkIsNullValue(userSession['name'])
        ? userSession['name'] ?? ""
        : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code'] ?? ""
        : "";
    phone = !checkIsNullValue(userSession['phone_number'])
        ? userSession['phone_number'] ?? ""
        : "";
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
          nameMessage = "name_is_required".tr();
        });
      }
      res = false;
    }

    return res;
  }

  updateUserProfile() async {
    if (!onValidate() || isLoadingButton) return;
    setState(() {
      isLoadingButton = true;
    });
    var response = await netPost(
      isUserToken: true,
      endPoint: "me/update/profile",
      params: {
        "name": nameController.text,
        "email": emailController.text,
      },
    );

    if (mounted) {
      if (response['resp_code'] == "200") {
        var user = await getProfileData();

        setState(() {
          name = user['name'];
        });

        context.read<AccountInfoProvider>().refreshName(name);

        await setStorage(STORAGE_USER, user);

        await getStorageUser();

        notifyAlert(context,
            desc: "your_profile_has_been_updated".tr(),
            btnTitle: "Ok", onConfirm: () {
          Navigator.pop(context);
        });
      }
      setState(() {
        isLoadingButton = false;
      });
    }
  }

  getProfileData() async {
    var response = await netGet(isUserToken: true, endPoint: "me/profile");
    if (response['resp_code'] == "200") {
      if (mounted) {
        var object = {
          "id": response['resp_data']['data']['id'],
          "name": response['resp_data']['data']['name'],
          "country_code": response['resp_data']['data']['country_code'],
          "phone_number": response['resp_data']['data']['phone_number'],
          "lat": response['resp_data']['data']['lat'],
          "lng": response['resp_data']['data']['lng'],
          "address": response['resp_data']['data']['address'],
          "zip_code": response['resp_data']['data']['zip_code'],
          "email": response['resp_data']['data']['email'],
          "balance": response['resp_data']['data']['balance'],
          "group": response['resp_data']['data']['group'],
          "access_token": userSession['access_token'] ?? "",
          "is_first_time_login": userSession['is_first_time_login'],
          "token_type": userSession['token_type']
        };
        return object;
      }
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(
          title: "edit_profile".tr(),
          subtitle: "$deliverTo • $phone",
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              "name",
              style: smallMediumGreyText,
            ).tr(),
          ),
          CustomTextField(
            controller: nameController,
            hintText: "enter_your_name".tr(),
          ),
          ErrorMessage(
            isError: isName,
            message: nameMessage,
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              "phone",
              style: smallMediumGreyText,
            ).tr(),
          ),
          CustomTextField(
            readOnly: true,
            controller: phoneController,
            keyboardType: TextInputType.phone,
            hintText: "enter_your_phone_number".tr(),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              "email",
              style: smallMediumGreyText,
            ).tr(),
          ),
          CustomTextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            hintText: "enter_your_email".tr(),
          ),
        ],
      ),
    );
  }

  Widget getFooter() {
    return CustomFooterButtons(
      isLoading: isLoadingButton,
      proceedTitle: "save_changes".tr(),
      onTapProceed: () {
        updateUserProfile();
      },
      onTapBack: () {
        Navigator.pop(context, name);
      },
    );
  }
}
