import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tezapp/helpers/network.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';

import '../../ui_elements/loading_widget.dart';

class TermConditionLoginPage extends StatefulWidget {
  const TermConditionLoginPage({ Key? key }) : super(key: key);

  @override
  State<TermConditionLoginPage> createState() => _TermConditionLoginPageState();
}

class _TermConditionLoginPageState extends State<TermConditionLoginPage> {
  bool isLoading = false;
  String title = "";
  String content = "";
  @override
  void initState() {
    super.initState();
    fetchTermCondition();
  }

  fetchTermCondition() async {
    setState(() { isLoading = true; });
    var response = await netGet(
      isUserToken: false, 
      endPoint: "public-content/term-and-condition",
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
      appBar: getAppBar(),
      body: isLoading ? LoadingData() : getBody(),
      bottomNavigationBar: getFooter(),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: primary,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 61,
      title: Text(
        "tez",
        style: appBarText,
      ),
    );
  }

  Widget getBody() {
    return  SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(
        children: <Widget>[
          // Text(
          //   title,
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //       fontSize: 18, height: 1.5, fontWeight: FontWeight.bold),
          // ),
          // SizedBox(height: 15,),
          Html(data: content,),
        ]
      ),
    );
  }

  Widget getFooter() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(color: white, boxShadow: [
        BoxShadow(
            color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
      ]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: black.withOpacity(0.06),
                            spreadRadius: 5,
                            blurRadius: 10)
                      ]),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: black,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                
                Flexible(
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: white,
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.06),
                                spreadRadius: 5,
                                blurRadius: 10)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "terms_&_conditions",
                              style: normalBlackText,
                            ).tr(),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}