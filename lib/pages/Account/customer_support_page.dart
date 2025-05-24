import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/provider/account_info_provider.dart';
import 'package:tezapp/ui_elements/custom_appbar.dart';
import 'package:tezapp/ui_elements/custom_button.dart';
import 'package:tezapp/ui_elements/custom_footer.dart';
import 'package:tezapp/ui_elements/custom_sub_header.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/constant.dart';

class CustomerSupportPage extends StatefulWidget {
  const CustomerSupportPage({Key? key}) : super(key: key);

  @override
  _CustomerSupportPageState createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
  final Uri androidUrl = Uri.parse(WHATSAPP_ANDROID_URL + WHATSAPP);
  final Uri iosUrl = Uri.parse(WHATSAPP_IOS_URL + WHATSAPP);

  var zipCode = '';
  var deliverTo = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code'] ?? ""
        : "";
    phone = !checkIsNullValue(userSession) ? userSession['phone_number'] : "";
  }

  onlaunchWhatsapp() async {
    if (Platform.isIOS) {
      if (await canLaunch(WHATSAPP_IOS_URL + WHATSAPP)) {
        await launch(WHATSAPP_IOS_URL + WHATSAPP);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("Install Whatsapp and try again")));
      }
    } else {
      if (await canLaunch(WHATSAPP_ANDROID_URL + WHATSAPP)) {
        await launch(WHATSAPP_ANDROID_URL + WHATSAPP);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("Install Whatsapp and try again")));
      }
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
        body: buildBody(),
        bottomNavigationBar: CustomFooter(
          onTapBack: () {
            Navigator.of(context).pop();
          },
        ));
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSubHeader(
            title: "customer_support".tr(),
            subtitle: "$deliverTo • $phone",
          ),
          SizedBox(
            height: 23,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: CustomButton(
              height: 55,
              child: Padding(
                padding: const EdgeInsets.only(left: 29, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "chat_with_us",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ).tr(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              onTap: () => onlaunchWhatsapp(),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: CustomButton(
              height: 55,
              child: Padding(
                padding: const EdgeInsets.only(left: 29, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "email_us",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ).tr(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              onTap: () {
                sendEmail(APP_EMAIL);
              },
            ),
          ),
        ],
      ),
    );
  }
}
