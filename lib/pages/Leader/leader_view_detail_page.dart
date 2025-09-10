import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Leader/leader_all_order_page.dart';
import 'package:tezchal/pages/Leader/member_request_page.dart';
import 'package:tezchal/pages/Leader/memeber_profile_page.dart';
import 'package:tezchal/ui_elements/custom_appbar_dynamic.dart';
import 'package:tezchal/ui_elements/custom_button.dart';
import 'package:tezchal/ui_elements/custom_sub_header.dart';
import 'package:tezchal/ui_elements/icon_box.dart';
import 'package:tezchal/ui_elements/item_button.dart';
import 'package:tezchal/ui_elements/leader_view_detail_loading.dart';

class LeaderViewDetailPage extends StatefulWidget {
  const LeaderViewDetailPage({Key? key}) : super(key: key);

  @override
  State<LeaderViewDetailPage> createState() => _LeaderViewDetailPageState();
}

class _LeaderViewDetailPageState extends State<LeaderViewDetailPage> {
  List groupMember = [];
  List requestMember = [];
  int orderDay = 0;
  int orderTotal = 0;
  var groupData = {};
  var groupDatMember = '';

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getMember();
  }

  getMember() async {
    setState(() {
      isLoading = true;
    });
    if (!checkIsNullValue(userSession['group'])) {
      var groupId = userSession['group']['id'];
      var response = await netGet(endPoint: "group/$groupId");
      if (response["resp_code"] == "200") {
        List members = response['resp_data']['data']['members'] ?? [];
        List requests = response['resp_data']['data']['requests'] ?? [];
        setState(() {
          groupMember = members;
          requestMember = requests;
          orderTotal = response['resp_data']['data']['total_group_orders'];
          groupData = response['resp_data']['data'];
        });
        if (groupMember.length == 1) {
          setState(() {
            groupDatMember =
                groupMember.length.toString() + " " + "member".tr();
          });
        } else {
          setState(() {
            groupDatMember =
                groupMember.length.toString() + " " + "members".tr();
          });
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBarDynamic(
          actionChild: Container(
            height: 40,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(userSession['group']['name'], style: meduimGreyText),
          ),
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      // return Center(child: CustomCircularProgress(
      //   strokeWidth: 3,
      // ));
      return LeaderViewDetailLoading();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSubHeader(
            title: "view_details".tr(),
            subtitle:
                userSession['group']['name'] +
                "  •  " +
                groupDatMember +
                "  •  $orderTotal " +
                "orders".tr(),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text("group_orders", style: normalBlackText).tr(),
          ),
          SizedBox(height: 5),
          // Padding(
          //     padding: const EdgeInsets.only(left: 15, right: 15),
          //     child: RichText(
          //         text: TextSpan(children: [
          //       TextSpan(text: "group_order_ending".tr(), style: smallBlackText),
          //       TextSpan(
          //           text: "Monday, Feb 14 at 11:59pm",
          //           style: smallBoldBlackText),
          //     ]))),
          // SizedBox(
          //   height: 5,
          // ),
          // Padding(
          //     padding: const EdgeInsets.only(left: 15, right: 15),
          //     child: RichText(
          //         text: TextSpan(children: [
          //       TextSpan(text: "delivery_scheduled_on".tr(), style: smallBlackText),
          //       TextSpan(text: "Tuesday, Feb 15", style: smallBoldBlackText),
          //     ]))),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ItemButton(
              title: "view_all_orders".tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderAllOrderPage()),
                );
              },
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text("requests", style: normalBlackText).tr(),
          ),
          SizedBox(height: 20),
          requestMember.length != 0
              ? Column(
                children: List.generate(requestMember.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                    ),
                    child: ItemButton(
                      title:
                          checkIsNullValue(
                                requestMember[index]['member']['name'],
                              )
                              ? "N/A"
                              : requestMember[index]['member']['name'],
                      onTap: () async {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MemberRequestPage(
                                  data: requestMember[index],
                                ),
                          ),
                        );
                        getMember();
                      },
                    ),
                  );
                }),
              )
              : Center(
                child:
                    Text("no_request_member", style: smallMediumGreyText).tr(),
              ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text("group_members", style: normalBlackText).tr(),
          ),
          SizedBox(height: 20),
          Column(
            children: List.generate(groupMember.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: ItemButton(
                  title:
                      checkIsNullValue(groupMember[index]['name'])
                          ? "N/A"
                          : groupMember[index]['name'],
                  onTap: () async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                MemberProfilePage(data: groupMember[index]),
                      ),
                    );
                    getMember();
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 20),
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
            offset: Offset(0, 0),
          ),
        ],
      ),
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
          SizedBox(width: 10),
          Expanded(
            child: CustomButton(
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 35),
                    child:
                        Text(
                          "back_to_group",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
