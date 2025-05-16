import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/provider/account_info_provider.dart';
import 'package:tezapp/ui_elements/border_button.dart';
import 'package:tezapp/ui_elements/custom_appbar.dart';
import 'package:tezapp/ui_elements/custom_circular_progress.dart';
import 'package:tezapp/ui_elements/custom_footer.dart' as footer;
import 'package:tezapp/ui_elements/custom_sub_header.dart';
import 'package:tezapp/ui_elements/order_history_box.dart';
import 'package:tezapp/ui_elements/order_history_loading.dart';

import '../../helpers/network.dart';
import '../../helpers/utils.dart';

class OrderDetailPage extends StatefulWidget {
  final String id;
  const OrderDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  RefreshController refreshController = RefreshController();
  bool loading = false;
  bool isPulling = false;
  var order;

  var zipCode = '';
  var deliverTo = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    initPage();

    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";
    phone = !checkIsNullValue(userSession) ? userSession['phone_number'] : "";
  }

  initPage() async {
    loadOrderDetail();
  }

  loadOrderDetail() async {
    setState(() {
      loading = true;
    });

    var id = widget.id;

    var response = await netGet(endPoint: "me/order/$id");
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      if (mounted) {
        setState(() {
          loading = false;
          isPulling = false;
          order = data;
        });
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
      setState(() {
        loading = false;
        isPulling = false;
        order = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomAppBar(
          subtitle: zipCode + " - " + context.watch<AccountInfoProvider>().name,
          subtitleIcon: Entypo.location_pin,
        ),
      ),
      body: getBody(),
      bottomNavigationBar: footer.CustomFooter(
        onTapBack: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget getBody() {
    if (loading && !isPulling) {
      return orderHistoryLoading();
    }
    return SmartRefresher(
      header: WaterDropHeader(),
      controller: refreshController,
      enablePullDown: true,
      onRefresh: () async {
        await initPage();
        refreshController.refreshCompleted();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSubHeader(
              title: "order_detail".tr(),
              subtitle: "$deliverTo • $phone",
            ),
            SizedBox(
              height: 10,
            ),
            OrderHistoryBox(
              data: order,
            ),
          ],
        ),
      ),
    );
  }

  Widget orderHistoryLoading() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 1,
        itemBuilder: (context, index) {
          return OrderHistoryLoading();
        });
  }

  int activeTabIndex = 3;
  Widget getFooter() {
    List bottomItems = [
      iconPath + "home_icon.svg",
      iconPath + "home_icon.svg",
      iconPath + "user_group_icon.svg",
      iconPath + "user_icon.svg",
    ];

    return Container(
      width: double.infinity,
      height: 90,
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(color: white, boxShadow: [
        BoxShadow(
            color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
      ]),
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(top: 25, bottom: 20),
          //   child: Container(
          //     width: double.infinity,
          //     height: 50,
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(10),
          //         color: white,
          //         boxShadow: [
          //           BoxShadow(
          //               color: black.withOpacity(0.06),
          //               spreadRadius: 5,
          //               blurRadius: 10)
          //         ]),
          //     child: Row(
          //       children: [
          //         Container(
          //           width: 60,
          //           child: Center(
          //               child: Icon(
          //             Icons.search,
          //             size: 30,
          //             color: greyLight,
          //           )),
          //         ),
          //         Flexible(
          //             child: TextField(
          //           cursorColor: black,
          //           decoration: InputDecoration(
          //               border: InputBorder.none,
          //               hintText: "Search for dal, atta, oil, bread..."),
          //         )),
          //         SizedBox(
          //           width: 15,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 8, bottom: 8),
          //           child: Container(
          //             width: 60,
          //             decoration: BoxDecoration(
          //                 border: Border(
          //                     left: BorderSide(
          //                         width: 1, color: placeHolderColor))),
          //             child: Center(
          //                 child: Icon(
          //               Icons.menu,
          //               size: 30,
          //               color: greyLight,
          //             )),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(bottomItems.length, (index) {
                if (index == 0) {
                  return BorderButton(
                    title: "Back",
                    prefixIcon: Icon(
                      Icons.arrow_back_ios_new,
                      color: primary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  );
                }
                return InkWell(
                  onTap: () {
                    setState(() {
                      activeTabIndex = index;
                    });
                  },
                  child: SvgPicture.asset(
                    bottomItems[index],
                    width: 28,
                    color: activeTabIndex == index ? black : greyLight,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void onLoading() async {
    refreshController.loadComplete();
  }

  void onRefresh() async {
    setState(() {
      isPulling = true;
    });
    loadOrderDetail().then((isSuccess) {
      if (isSuccess) {
        refreshController.refreshCompleted();
      } else {
        refreshController.refreshFailed();
      }
    });
  }
}
