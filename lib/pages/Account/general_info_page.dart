import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Account/open_source_page.dart';
import 'package:tezchal/pages/Account/privacy_page.dart';
import 'package:tezchal/pages/Account/term_condition_page.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_button.dart';
import 'package:tezchal/ui_elements/custom_footer.dart';
import 'package:tezchal/ui_elements/custom_sub_header.dart';

class GeneralInfoPage extends StatefulWidget {
  const GeneralInfoPage({Key? key}) : super(key: key);

  @override
  _GeneralInfoPageState createState() => _GeneralInfoPageState();
}

class _GeneralInfoPageState extends State<GeneralInfoPage> {
  var zipCode = '';
  var deliverTo = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code']
            : "";
    phone = !checkIsNullValue(userSession) ? userSession['phone_number'] : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: CustomAppBar(
          isWidget: true,
          title: "general_information".tr(),
          subtitle: "$deliverTo • $phone",
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: CustomFooter(
        onTapBack: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 23),
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
                      "terms_&_conditions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ).tr(),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermConditionPage()),
                );
              },
            ),
          ),
          SizedBox(height: 15),
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
                      "privacy_policy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ).tr(),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPage()),
                );
              },
            ),
          ),
          SizedBox(height: 15),
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
                      "open_source_licenses",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ).tr(),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OpenSourcePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
