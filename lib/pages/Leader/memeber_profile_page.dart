import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/helpers/network.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/provider/has_group.dart';
import 'package:tezapp/ui_elements/border_button.dart';
import 'package:tezapp/ui_elements/custom_appbar_dynamic.dart';
import 'package:tezapp/ui_elements/custom_button.dart';
import 'package:tezapp/ui_elements/custom_circular_progress.dart';
import 'package:tezapp/ui_elements/custom_sub_header.dart';
import 'package:tezapp/ui_elements/icon_box.dart';
import 'package:url_launcher/url_launcher.dart';


class MemberProfilePage extends StatefulWidget {
  MemberProfilePage({Key? key, required this.data}) : super(key: key);
  final data;
  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  List groupMember = [];
  var groupDatMember = '';
  int orderTotal = 0;

  bool isLoadingRemoveButton = false;
  String leaderId = '';
  bool isLoading = false;
  String joinDate = '';

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
        List data = response['resp_data']['data']['members'];
        setState(() {
          groupMember = data;
          leaderId = response['resp_data']['data']['leader']['id'].toString();
          orderTotal = response['resp_data']['data']['total_group_orders'];
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
              checkIsNullValue(userSession['group'])
                  ? "N/A"
                  : userSession['group']['name'],
              style: meduimGreyText,
            ),
          )),
        ),
        body: buildBody(),
        bottomNavigationBar: getFooter());
  }

  Widget buildBody() {
    if (isLoading) {
      return Center(
          child: CustomCircularProgress(
        strokeWidth: 3,
      ));
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSubHeader(
            title: "member_profile".tr(),
            subtitle: userSession['group']['name'] +
                "  •  " +
                groupDatMember +
                "  •  $orderTotal " + "orders".tr(),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text(
              !checkIsNullValue(widget.data['name'])
                  ? widget.data['name']
                  : "N/A",
              style: normalBlackText,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: [
                  Text(
                    "group_member_since".tr(),
                    style: smallBoldBlackText,
                  ),
                  SizedBox(width: 3,),
                  Text(
                    !checkIsNullValue(widget.data['joint_group_at']) ? formatDateOne(widget.data['joint_group_at']) : "N/A",
                    style: smallBoldBlackText,
                  ),
                ],
              )),
          SizedBox(
            height: 15,
          ),
          leaderId == widget.data['id'].toString()
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          title: "call".tr(), 
                          height: 55, 
                          onTap: () async {
                            var phone = widget.data['phone_number'].toString();
                            await launch("tel:$phone");
                          }
                      )),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: BorderButton(
                              isLoading: isLoadingRemoveButton,
                              title: "remove".tr(),
                              height: 55,
                              onTap: () {
                                remove();
                              }))
                    ],
                  ),
                ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text(
              "address",
              style: meduimBlackText,
            ).tr(),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text(
                !checkIsNullValue(widget.data['address'])
                    ? widget.data['address']
                    : "N/A",
                style: smallBlackText,
              )),
          SizedBox(
            height: 5,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text(
                !checkIsNullValue(widget.data['zip_code'])
                    ? widget.data['zip_code']
                    : "N/A",
                style: smallBlackText,
              )),
          SizedBox(
            height: 5,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text(
                !checkIsNullValue(widget.data['phone_number'])
                    ? widget.data['phone_number']
                    : "N/A",
                style: smallBlackText,
              )),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "report_this_person",
                  style: smallBlackText,
                ).tr()
              ),
            ),
          )
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

  remove() async {
    if (isLoadingRemoveButton) return;
    setState(() {
      isLoadingRemoveButton = true;
    });
    var groupId = userSession['group']['id'];
    var memberId = widget.data['id'].toString();
    var response = await netDelete(
      isUserToken: true,
      endPoint: "group/$groupId/member/$memberId",
      params: {},
    );

    if (mounted) {
      if (response['resp_code'] == "200") {
        notifyAlert(context,
            desc: "you_have_removed_a_new_member".tr(),
            btnTitle: "Ok", onConfirm: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
        // get group member length
        var groupId = userSession['group']['id'];
        var response = await netGet(endPoint: "group/$groupId");
        if (response["resp_code"] == "200") {
          List data = response['resp_data']['data']['members'];
          context.read<HasGroupProvider>().refreshGroupNumber(data.length);
        }
      } else {
        notifyAlert(context,
            desc: response['resp_data']['message'],
            btnTitle: "Ok", onConfirm: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    }
    setState(() {
      isLoadingRemoveButton = false;
    });
  }
}
