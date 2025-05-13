import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tez_mobile/helpers/network.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/helpers/utils.dart';
import 'package:tez_mobile/ui_elements/border_button.dart';
import 'package:tez_mobile/ui_elements/custom_appbar_dynamic.dart';
import 'package:tez_mobile/ui_elements/custom_button.dart';
import 'package:tez_mobile/ui_elements/custom_sub_header.dart';
import 'package:tez_mobile/ui_elements/icon_box.dart';
import 'package:tez_mobile/ui_elements/leader_all_order_loading.dart';

class LeaderAllOrderPage extends StatefulWidget {
  const LeaderAllOrderPage({Key? key}) : super(key: key);

  @override
  State<LeaderAllOrderPage> createState() => _LeaderAllOrderPageState();
}

class _LeaderAllOrderPageState extends State<LeaderAllOrderPage> {
  List groupMember = [];
  List requestMember = [];
  int orderDay = 0;
  int orderTotal = 0;
  var groupData = {};
  var groupDatMember = '';

  bool isLoading = false;

  // order list
  bool isLoadingActive = false;
  bool isLoadingPast = false;
  List activeItems = [];
  List pastItems = [];

  @override
  void initState() {
    super.initState();
    getMember();
    getActiveOrder();
    getPastOrder();
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

  getActiveOrder() async {
    setState(() {
      isLoadingActive = true;
    });
    if (!checkIsNullValue(userSession['group'])) {
      var params = {
        "limit": "0",
        "order": "id",
        "sort": "asc",
        "type": 'active'
      };
      var response = await netGet(endPoint: "group/order", params: params);
      if (mounted) {
        if (response["resp_code"] == "200") {
          setState(() {
            activeItems = response['resp_data']['data']['list'] ?? [];
          });
        } else {
          setState(() {
            activeItems = [];
          });
        }
      }
    }
    setState(() {
      isLoadingActive = false;
    });
  }

  getPastOrder() async {
    setState(() {
      isLoadingPast = true;
    });
    if (!checkIsNullValue(userSession['group'])) {
      var params = {"limit": "0", "order": "id", "sort": "asc", "type": 'past'};
      var response = await netGet(endPoint: "group/order", params: params);
      if (mounted) {
        if (response["resp_code"] == "200") {
          setState(() {
            pastItems = response['resp_data']['data']['list'] ?? [];
          });
        } else {
          setState(() {
            pastItems = [];
          });
        }
      }
    }
    setState(() {
      isLoadingPast = false;
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
                color: cardColor, borderRadius: BorderRadius.circular(10)),
            child: Text(
              userSession['group']['name'],
              style: meduimGreyText,
            ),
          )),
        ),
        body: isLoading && isLoadingActive && isLoadingPast
            ? LeaderAllOrderLoading()
            : buildBody(),
        bottomNavigationBar: getFooter());
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSubHeader(
            title: "view_all_orders".tr(),
            subtitle: isLoading
                ? ""
                : userSession['group']['name'] +
                    "  •  " +
                    groupDatMember +
                    "  •  $orderTotal " +
                    "orders".tr(),
          ),
          SizedBox(
            height: 10,
          ),
         
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  "new_orders",
                  style: meduimBlackText,
                ).tr(),
              ),
              SizedBox(
                height: 15,
              ),
              checkIsNullValue(activeItems.length)
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                      "no_order".tr(),
                      style: meduimGreyText,
                    ),
                ),
              )
              : Column(
                children: List.generate(activeItems.length, (index) {
                  var date =
                      formatDateOne(activeItems[index]['confirmed_date']);
                  var day = formatDay(activeItems[index]['confirmed_date']);
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: BorderButton(
                      width: double.infinity,
                      alignment: MainAxisAlignment.spaceBetween,
                      padding: EdgeInsets.only(left: 25, right: 18),
                      title: "$day  •  $date",
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: primary,
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed("/leader_order_detail_page", arguments: {
                          "id": activeItems[index]['id'].toString()
                        });
                      },
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Text(
                  "past_orders",
                  style: meduimBlackText,
                ).tr(),
              ),
              SizedBox(
                height: 15,
              ),
              checkIsNullValue(pastItems.length)
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                      "no_order".tr(),
                      style: meduimGreyText,
                    ),
                ),
              )
              : Column(
                children: List.generate(pastItems.length, (index) {
                  var date = formatDateOne(pastItems[index]['confirmed_date']);
                  var day = formatDay(pastItems[index]['confirmed_date']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed("/leader_order_detail_page", arguments: {
                          "id": pastItems[index]['id'].toString()
                        });
                      },
                      child: orderItemButton(
                        "$day  •  $date",
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget orderItemButton(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: BorderButton(
        width: double.infinity,
        alignment: MainAxisAlignment.spaceBetween,
        padding: EdgeInsets.only(left: 25, right: 18),
        borderColor: darker,
        title: title,
        textStyle: normalBlackText,
        suffixIcon: Icon(
          Icons.arrow_forward_ios,
          color: darker,
        ),
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
                    padding: EdgeInsets.only(left: 35),
                    child: Text(
                      "back_to_group_details",
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
