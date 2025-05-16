import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/ui_elements/coupon_item.dart';

import '../../helpers/constant.dart';
import '../../helpers/network.dart';
import '../../provider/cart_provider.dart';
import '../../provider/has_group.dart';
import '../../ui_elements/coupon_loading.dart';
import '../../ui_elements/custom_appbar.dart';
import '../../ui_elements/custom_circular_progress.dart';

class AddCouponPage extends StatefulWidget {
  final schedule;

  const AddCouponPage({Key? key, this.schedule}) : super(key: key);

  @override
  State<AddCouponPage> createState() => _AddCouponPageState();
}

class _AddCouponPageState extends State<AddCouponPage> {
  TextEditingController textController = TextEditingController();
  List coupons = [];
  bool loading = false;

  // group
  List groupMember = [];
  int orderDay = 0;
  String byLeader = '';
  String leaderId = '';
  String leaderzipCode = '';
  String groupProfile = '';
  String byDate = 'N/A';

  @override
  void initState() {
    super.initState();
    loadCoupons();
    getMember();
  }

  loadCoupons() async {
    print("loadCoupons");
    if (loading) return;
    setState(() {
      loading = true;
    });
    var params = {"page": "1", "limit": "10", "order": "id", "sort": "asc"};

    var response = await netGet(endPoint: "coupon", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      if (mounted) {
        setState(() {
          coupons = data["list"];
        });
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    setState(() {
      loading = false;
    });
  }

  getMember() async {
    if (!checkIsNullValue(userSession['group'])) {
      var groupId = userSession['group']['id'];

      var response = await netGet(endPoint: "group/$groupId");
      if (response["resp_code"] == "200") {
        var data = response['resp_data']['data'];

        setState(() {
          groupProfile = !checkIsNullValue(data['image']) ? data['image'].toString() : DEFAULT_GROUP_IMAGE;
          byDate = !checkIsNullValue(widget.schedule) ? DateFormat("d MMM").format(DateTime.parse(widget.schedule[widget.schedule.length - 1]["date"])) : "N/A";
        });
      }
    }
  }

  searchCoupons(String couponCode) async {
    print("searchCoupons");
    if (checkIsNullValue(couponCode) || loading) return;
    setState(() {
      loading = true;
      coupons.clear();
    });

    var params = {"page": "1", "limit": "1", "order": "id", "sort": "asc"};

    var response =
        await netGet(endPoint: "coupon/code/$couponCode", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      print(data);
      if (mounted) {
        setState(() {
          coupons.insert(0, data);
        });
      }
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomAppBar(
            subtitle: "apply_coupon".tr(),
          ),
        ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  decoration: BoxDecoration(
                    color: secondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primary),
                  ),
                  child: TextField(
                    controller: textController,
                    onChanged: onTextChanged,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "enter_coupon_code".tr(),
                      hintStyle: normalGreyText,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              TextButton(
                onPressed: () {
                  searchCoupons(textController.text);
                },
                child: Text(
                  "apply".tr(),
                  style: meduimBoldPrimaryText,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Divider(
          thickness: 0.8,
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Text(
            "available_coupons",
            style: normalBlackText,
          ).tr(),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: getCoupons(),
        )
      ],
    ));
  }

  onTextChanged(String text) {
    if (text == "") {
      loadCoupons();
    }
  }

  getCoupons() {
    return loading
        // ? Container(
        //     margin: EdgeInsets.only(top: 30),
        //     child: Center(child: CustomCircularProgress()))
        ? ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return CouponLoading();
        })
        : (checkIsNullValue(coupons) || coupons.length == 0)
            ? Container(
                margin: EdgeInsets.only(top: 30),
                child: Center(
                  child: Text("no_coupon").tr(),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: coupons.length,
                itemBuilder: ((context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: CouponItem(
                      data: coupons[index],
                      onApply: () {
                        onApplyCoupon(coupons[index]);
                      },
                    ),
                  );
                }),
              );
  }

  onApplyCoupon(coupon) {
    Navigator.of(context).pop(coupon);
  }

  Widget getFooter() {
    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.06),
            spreadRadius: 5,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          // Padding(
          //   padding:
          //       const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
          //   child: Container(
          //     width: double.infinity,
          //     height: 60,
          //     child: Row(
          //       children: [
          //         Container(
          //           width: 45,
          //           height: 45,
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             image: DecorationImage(
          //               image: NetworkImage(checkIsNullValue(userSession['group']) ? groupProfile : userSession['group']['image']),
          //               fit: BoxFit.cover
          //             )
          //           ),
          //         ),
          //         SizedBox(
          //           width: 15,
          //         ),
          //         Flexible(
          //           child: Container(
          //             width: size.width * 0.5,
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 !checkIsNullValue(userSession['group'])
          //                     ? Text(
          //                         checkIsNullValue(userSession['group'])
          //                             ? "N/A"
          //                             : userSession['group']['name'],
          //                         style: normalBlackText,
          //                       )
          //                     : Text(
          //                         "no_group_found",
          //                         style: normalBlackText,
          //                       ).tr(),
          //                 SizedBox(
          //                   height: 5,
          //                 ),
          //                 !checkIsNullValue(userSession['group'])
          //                     ? Text(
          //                         context
          //                                 .watch<HasGroupProvider>()
          //                                 .getGroupLeader +
          //                             (checkIsNullValue(context
          //                                     .watch<HasGroupProvider>()
          //                                     .getLeaderzipCode)
          //                                 ? ""
          //                                 : " - " +
          //                                     context
          //                                         .watch<HasGroupProvider>()
          //                                         .getLeaderzipCode),
          //                         style: smallBlackText,
          //                       )
          //                     : Text(
          //                         "no_group_leader_found",
          //                         style: smallBlackText,
          //                       ).tr()
          //               ],
          //             ),
          //           ),
          //         ),
          //         SizedBox(
          //           width: 15,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 8, bottom: 8),
          //           child: Container(
          //             width: 90,
          //             decoration: BoxDecoration(
          //                 border: Border(
          //                     left: BorderSide(
          //                         width: 1, color: placeHolderColor))),
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Text("delivery_by", style: smallBlackText).tr(),
          //                 SizedBox(
          //                   height: 5,
          //                 ),
          //                 Text(
          //                   byDate,
          //                   style: normalBlackText,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // cart section
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15,top: 15,bottom: 20),
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
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
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
                  child: InkWell(
                    onTap: () async {
                      await confirmCheckout();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            context.watch<CartProvider>().isHasCart
                                ? Text(
                                    context.watch<CartProvider>().cartCount > 1
                                        ? context
                                                .watch<CartProvider>()
                                                .cartCount
                                                .toString() +
                                            " " + "items".tr() + " • $CURRENCY" +
                                            double.parse(context
                                                    .watch<CartProvider>()
                                                    .cartGrandTotal
                                                    .toString())
                                                .toStringAsFixed(0)
                                        : context
                                                .watch<CartProvider>()
                                                .cartCount
                                                .toString() +
                                            " " + "item".tr() + " • $CURRENCY" +
                                            double.parse(context
                                                    .watch<CartProvider>()
                                                    .cartGrandTotal
                                                    .toString())
                                                .toStringAsFixed(0),
                                    style: smallMediumWhiteText,
                                  )
                                : Text(
                                    "join_or_create_a_tez_group",
                                    style: smallMediumWhiteText,
                                  ).tr(),
                            SizedBox(
                              width: 5,
                            ),
                            context.watch<CartProvider>().isHasCart
                                ? Row(
                                    children: [
                                      Text(
                                        "checkout".tr(),
                                        style: smallMediumWhiteText,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      confirmingCheckout
                                          ? SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: CustomCircularProgress(
                                                color: white,
                                              ),
                                            )
                                          : Icon(
                                              Icons.arrow_forward_ios,
                                              color: white,
                                              size: 15,
                                            )
                                    ],
                                  )
                                : Icon(
                                    Icons.arrow_forward_ios,
                                    color: white,
                                    size: 18,
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  bool confirmingCheckout = false;
  confirmCheckout() async {
    if (confirmingCheckout) return;
    setState(() {
      confirmingCheckout = true;
    });
    var response = await netPost(
      endPoint: "me/cart/confirm",
      params: {},
    );
    if (response['resp_code'] == "200") {
      var temp = response["resp_data"]["data"];
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted)
      setState(() {
        confirmingCheckout = false;
      });
  }
}
