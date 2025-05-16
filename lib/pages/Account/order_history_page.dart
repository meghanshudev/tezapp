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
import 'package:tezapp/ui_elements/custom_footer.dart' as footer;
import 'package:tezapp/ui_elements/custom_sub_header.dart';
import 'package:tezapp/ui_elements/order_history_box.dart';
import 'package:tezapp/ui_elements/order_history_loading.dart';
import 'package:tezapp/ui_elements/pagination_widget.dart';

import '../../helpers/network.dart';
import '../../helpers/utils.dart';
import '../../ui_elements/loading_widget.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  RefreshController refreshController = RefreshController();
  bool isLoading = false;
  bool isPulling = false;

  int page = 1;
  int total = 0;
  List orders = [];

  bool loading = false;
  // var orders;
  final scollController = ScrollController();

  var zipCode = '';
  var deliverTo = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    initPage();

    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" ?? "" : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";
    phone = !checkIsNullValue(userSession) ? userSession['phone_number'] : "";
  }

  initPage() async {
    // loadOrders();
    // scollController.addListener(() async {
    //   if (scollController.position.pixels >
    //       (scollController.position.maxScrollExtent * 0.7)) {
    //     await loadMore();
    //   }
    // });
    fetchData();
  }

  // bool loadingMore = false;
  // int pageIndex = 1;
  // bool isNoMore = false;
  // Future<bool> loadMore() async {
  //   if (loadingMore || isNoMore) return false;
  //   loadingMore = true;
  //   pageIndex++;
  //   await loadOrders();
  //   loadingMore = false;
  //   return true;
  // }

  // loadOrders() async {
  //   if (loading) return;
  //   loading = true;

  //   var params = {
  //     "page": "$pageIndex",
  //     "limit": "10",
  //     "order": "id",
  //     "sort": "asc"
  //   };

  //   var response = await netGet(endPoint: "me/order", params: params);
  //   if (response["resp_code"] == "200") {
  //     var data = response["resp_data"]["data"];
  //     if (pageIndex == 1)
  //       orders = data["list"];
  //     else
  //       orders.addAll(data["list"]);
  //     isNoMore = orders.length >= data["total"];
  //   } else {
  //     var ms = response["resp_data"]["message"];
  //     showToast(ms.toString(), context);
  //   }
  //   if (mounted)
  //     setState(() {
  //       loading = false;
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(95),
          child: CustomSubHeader(
            title: "order_history".tr(),
            subtitle: "$deliverTo • $phone",
          )),
      body: getBody(),
    );
  }

  // Widget buildBody() {
  //   return SingleChildScrollView(
  //     controller: scollController,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         CustomSubHeader(
  //           title: "order_history".tr(),
  //           subtitle: "$deliverTo • $phone",
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         getOrders(),
  //       ],
  //     ),
  //   );
  // }

  Widget getBody() {
    if (isLoading && page == 1 && !isPulling) return LoadingData();
    return PaginationWidget(
      isLoading: isLoading,
      totalRow: total,
      currentTotalRow: orders.length,
      currentPage: page,
      refreshController: refreshController,
      items: [
        getOrders(),
      ],
      onLoading: () {
        onLoading();
      },
      onRefresh: () {
        onRefresh();
      },
      loadMore: () {
        loadMore();
      },
    );
  }

  Widget getOrders() {
    if (isLoading && page == 1) return orderHistoryLoading();
    return (checkIsNullValue(orders) || orders.length == 0)
        ? Container(
            margin: EdgeInsets.only(top: 30),
            child: Center(
              child: Text("no_order").tr(),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return OrderHistoryBox(
                data: orders[index],
              );
            });
  }

  Widget orderHistoryLoading() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 3,
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
                const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 15),
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

  Future<void> loadMore() async {
    await fetchData();
  }

  void onLoading() async {
    refreshController.loadComplete();
  }

  void onRefresh() async {
    setState(() {
      page = 1;
      isPulling = true;
    });
    fetchData().then((isSuccess) {
      if (isSuccess) {
        refreshController.refreshCompleted();
      } else {
        refreshController.refreshFailed();
      }
    });
  }

  fetchData() async {
    if (isLoading) return;
    if (mounted)
      setState(() {
        isLoading = true;
      });

    var params = {
      "page": page.toString(),
      "limit": "10",
      "order": "id",
      "sort": "desc"
    };

    var response = await netGet(endPoint: "me/order", params: params);
    var data = response["resp_data"]["data"];
    int cnt = data["total"];

    if (mounted)
      setState(() {
        if (page == 1)
          orders = data['list'];
        else
          orders.addAll(data['list']);

        total = cnt;
        isLoading = false;
        isPulling = false;
        page++;
      });
    return true;
  }
}
