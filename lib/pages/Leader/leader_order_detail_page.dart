import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/ui_elements/custom_appbar_dynamic.dart';
import 'package:tezchal/ui_elements/custom_button.dart';
import 'package:tezchal/ui_elements/custom_sub_header.dart';
import 'package:tezchal/ui_elements/icon_box.dart';
import 'package:tezchal/ui_elements/leader_order_detail_item.dart';
import 'package:tezchal/ui_elements/leader_order_detail_loading.dart';

class LeaderOrderDetailPage extends StatefulWidget {
  final data;
  const LeaderOrderDetailPage({Key? key,required this.data}) : super(key: key);

  @override
  State<LeaderOrderDetailPage> createState() => _LeaderOrderDetailPageState();
}

class _LeaderOrderDetailPageState extends State<LeaderOrderDetailPage> {
  List groupMember = [];
  List requestMember = [];
  int orderDay = 0;
  int orderTotal = 0;
  var groupData = {};
  var groupDatMember = '';

  bool isLoading = false;

  // group order
  bool isLoadingOrder = false;
  dynamic groupOrder = {};
  @override
  void initState() {
    super.initState();
    getMember();
    getGroupOrderDetail();
  }

  getMember() async {
    setState(() {
      isLoading = true;
    });
    if (!checkIsNullValue(userSession['group'])) {
      var groupOrderId = userSession['group']['id'];
      var response = await netGet(endPoint: "group/$groupOrderId");
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
            groupDatMember = groupMember.length.toString() + " " + "member".tr();
          });
        } else {
          setState(() {
            groupDatMember = groupMember.length.toString() + " " + "members".tr();
          });
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  getGroupOrderDetail() async {
    setState(() {
      isLoadingOrder = true;
    });
    if (!checkIsNullValue(userSession['group'])) {
      var groupOrderId = widget.data['id'];
    
      var response = await netGet(endPoint: "group/order/$groupOrderId");
      if (mounted) {
        if (response["resp_code"] == "200") {
          setState(() {
            groupOrder = response['resp_data']['data'] ?? {};
          });
        } else {
          setState(() {
            groupOrder = {};
          });
        }
      }
    }
    setState(() {
      isLoadingOrder = false;
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
        body: isLoadingOrder ? LeaderOrderDetailLoading() : buildBody(),
        bottomNavigationBar: getFooter());
  }

  Widget buildBody() {
    var date = formatDateOne(groupOrder['confirmed_date']);
    var day = formatDay(groupOrder['confirmed_date']);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSubHeader(
            title: "order_details".tr(),
            subtitle: isLoading
                ? ""
                : userSession['group']['name'] +
                    "  •  " +
                    groupDatMember +
                    "  •  $orderTotal " + "orders".tr(),
            subChild: Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
              child: CustomButton(
                height: 50,
                title: isLoadingOrder ? "" : "$day • $date",
                onTap: () {},
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          // isLoadingOrder
          // ? Padding(
          //     padding: const EdgeInsets.only(top: 150),
          //     child: Center(child: CustomCircularProgress()),
          //   )
          // : 
          getOrders(),
        ],
      ),
    );
  }

  Widget getOrders() {
    List items = groupOrder['orders'];

    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return LeaderOrderDetailItem(data: items[index]);
        });
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
                Navigator.popUntil(
                    context, ModalRoute.withName("/leader_view_detail_page"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
