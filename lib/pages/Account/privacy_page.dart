import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:tez_mobile/helpers/constant.dart';
import 'package:tez_mobile/helpers/utils.dart';
import 'package:tez_mobile/provider/account_info_provider.dart';
import 'package:tez_mobile/ui_elements/custom_appbar.dart';
import 'package:tez_mobile/ui_elements/custom_footer.dart';
import 'package:tez_mobile/ui_elements/loading_widget.dart';
import 'package:tez_mobile/ui_elements/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/network.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  var zipCode = '';
  var deliverTo = '';
  bool isLoading = false;
  String title = "";
  String content = "";

  @override
  void initState() {
    super.initState();
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";
    fetchPrivacyPolicy();
  }

  fetchPrivacyPolicy() async {
    setState(() {
      isLoading = true;
    });
    var response = await netGet(
      isUserToken: true,
      endPoint: "public-content/privacy-policy",
    );

    if (response['resp_code'] == "200") {
      if (mounted) {
        setState(() {
          isLoading = false;
          title = response['resp_data']['data']['name'].toString();
          content = response['resp_data']['data']['value'].toString();
        });
      }
    } else {
      setState(() {
        isLoading = false;
        title = "";
        content = "";
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
        // body: buildBody(),
        body: isLoading ? LoadingData() : getBody(),
        bottomNavigationBar: CustomFooter(
          onTapBack: () {
            Navigator.of(context).pop();
          },
        ));
  }

  Widget getBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(children: <Widget>[
        // Text(
        //   title,
        //   textAlign: TextAlign.center,
        //   style: TextStyle(
        //       fontSize: 18, height: 1.5, fontWeight: FontWeight.bold),
        // ),
        // SizedBox(height: 15,),
        Html(
          data: content,
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0, right: 0),
          child: CustomButton(
            height: 55,
            child: Padding(
              padding: const EdgeInsets.only(left: 29, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Delete Account",
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
            onTap: () async {
              await launch("https://www.teznow.com/account-deletion");
            },
          ),
        ),
      ]),
    );
  }
}
