import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_button.dart';
import 'package:tezchal/ui_elements/custom_sub_header.dart';
import 'package:tezchal/ui_elements/icon_box.dart';

import '../../respositories/suggest_us/suggest_us_repository.dart';

class SuggestPage extends StatefulWidget {
  const SuggestPage({Key? key}) : super(key: key);

  @override
  _SuggestPageState createState() => _SuggestPageState();
}

class _SuggestPageState extends State<SuggestPage> {
  var zipCode = '';
  var deliverTo = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";
    phone = !checkIsNullValue(userSession) ? userSession['phone_number'] : "";
  }

  final TextEditingController messageController = TextEditingController();
  bool isSend = false;
  bool hasMessage = false;

  onValidate() {
    setState(() {
      hasMessage = false;
    });

    if (messageController.text.isEmpty) {
      setState(() {
        hasMessage = true;
      });
      return false;
    }
    return true;
  }

  onSend() async {
    if (onValidate() && !isSend) {
      if (mounted) {
        setState(() {
          isSend = true;
        });

        await SuggestUsRepository()
            .create(params: {"message": messageController.text});
        Navigator.pop(context);
        showToast("You have been submitted successfully.", context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: CustomAppBar(
            isWidget: true,
            title: "suggest_us".tr(),
            subtitle: "$deliverTo • $phone",
          ),
        ),
        body: buildBody(),
        bottomNavigationBar: getFooter(),
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 23,
          ),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: placeHolderColor)),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextField(
                controller: messageController,
                minLines: 3,
                maxLines: 6,
                cursorColor: black,
                style: TextStyle(height: 1.5),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  border: InputBorder.none,
                  hintText: "write_to_us_your_message".tr(),
                ),
              ),
            ),
          ),
          hasMessage
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    "please_write_something",
                    style: TextStyle(color: primary),
                  ).tr(),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget getFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 23, 15, 33),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0))
          ]),
      child: Row(
        children: [
          IconBox(
            child: Icon(Icons.arrow_back_ios_new, color: black),
            radius: 10,
            padding: 15,
            bgColor: cardColor,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomButton(
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 55),
                    child: Text(
                      "send_message",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ).tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              onTap: () => onSend(),
            ),
          ),
        ],
      ),
    );
  }
}
