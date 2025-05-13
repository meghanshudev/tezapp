import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tez_mobile/helpers/constant.dart';
import 'package:tez_mobile/helpers/network.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/helpers/utils.dart';
import 'package:tez_mobile/ui_elements/slider_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../../ui_elements/custom_appbar.dart';

class OrderConfirmedPage extends StatefulWidget {
  const OrderConfirmedPage({Key? key, required this.data}) : super(key: key);
  final data;

  @override
  State<OrderConfirmedPage> createState() => _OrderConfirmedPageState();
}

class _OrderConfirmedPageState extends State<OrderConfirmedPage> {
  bool hasCartItem = true;
  int activeOrder = 0;
  var orderData;
  var cart;
  List schedules = [];
  var couponData;
  var paymentType;
  String expectedConfirmDate = "N/A";
  late String timeStamp;
  bool isAdsLoading = false;
  List ads = [];
  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();

    initData();
    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false);
  }

  initData() async {
    orderData = widget.data['orderData'];
    cart = (!checkIsNullValue(orderData) && orderData.containsKey('lines'))
        ? orderData['lines']
        : cart;
    schedules =
        orderData.containsKey('schedules') ? orderData['schedules'] : [];
    paymentType =
        orderData.containsKey('paymentType') ? orderData['paymentType'] : null;
    timeStamp = DateFormat("EEEE, MMM d")
            .format(DateTime.parse(orderData['order_date'])) +
        " at " +
        DateFormat("hh:mmaaa").format(DateTime.parse(orderData['order_date']));

    if (orderData.containsKey('schedules')) {
      for (int i = 0; i < orderData['schedules'].length; i++) {
        if (orderData['schedules'][i]['state']['code'] == "group_confirm") {
          expectedConfirmDate = DateFormat("EEEE, d MMM")
              .format(DateTime.parse(orderData['schedules'][i]['date']));
          break;
        }
      }
    }

    await fetchAds();
  }

  fetchAds() async {
    setState(() {
      isAdsLoading = true;
    });

    var params = {"limit": "0", "order": "rgt", "sort": "asc"};

    var response = await netGet(endPoint: "advertisement", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List adsItems = data['list'] ?? [];
      if (mounted) {
        setState(() {
          ads = adsItems;
        });
      }
    } else {
      setState(() {
        ads = [];
      });
    }
    setState(() {
      isAdsLoading = false;
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
            subtitle: "your_order".tr(),
          ),
        ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  Widget getItems() {
    if (checkIsNullValue(cart)) return SizedBox();

    var size = MediaQuery.of(context).size;
    return Column(
      children: List.generate(cart.length, (index) {
        var _product = cart[index]["product"];
        var qty = cart[index]['qty'].toString();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: (size.width - 30) * 0.7,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        "[$qty]" " ${_product["name"]}",
                        style: smallMediumBlackText,
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  width: size.width,
                  child: checkIsNullValue(cart[index]['percent_off'])
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "$CURRENCY ${cart[index]['total']}",
                              style: meduimBoldBlackText,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "$CURRENCY ${cart[index]['unit_price']}",
                              style: smallMediumStrikeBlackText,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "$CURRENCY ${cart[index]['sale_price']}",
                              style: smallMediumBlackText,
                            )
                          ],
                        ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;

    return checkIsNullValue(schedules)
        ? Container(
            child: Center(
              child: Text("no_data").tr(),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(
                            top: 15,
                            bottom: 5,
                            left: 15,
                            right: 15,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "order_received",
                                  style: normalBlackCountryCode,
                                ).tr(),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: primary,
                                ),
                              ])),
                      Text(
                        "We will deliver your order in 24 hours!",
                        style: smallMediumBlackText,
                      ).tr(),
                      SizedBox(
                        height: 20,
                      ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       "your_order_will_be_confirmed_on",
                      //       style: smallBlackText,
                      //     ).tr(),
                      //     Text(
                      //       expectedConfirmDate,
                      //       style: smallBoldBlackText,
                      //     )
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 2,
                      // ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       "as_per",
                      //       style: smallBlackText,
                      //     ).tr(),
                      //     Text(
                      //       !checkIsNullValue(userSession['group'])
                      //           ? userSession['group']['name']
                      //           : "N/A",
                      //       style: smallBoldBlackText,
                      //     ),
                      //     Text(
                      //       " " + "settings".tr(),
                      //       style: smallBlackText,
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 25,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: List.generate(schedules.length, (index) {
                      //     return activeOrder == index
                      //         ? Container(
                      //             width: 50,
                      //             height: 50,
                      //             decoration: BoxDecoration(
                      //                 border: Border.all(
                      //                     width: 2,
                      //                     color: activeOrder != index
                      //                         ? primary
                      //                         : Colors.transparent),
                      //                 color: activeOrder == index
                      //                     ? primary
                      //                     : Colors.transparent,
                      //                 shape: BoxShape.circle),
                      //             child: Center(
                      //               child: Icon(
                      //                 MaterialIcons.check,
                      //                 color: white,
                      //               ),
                      //             ),
                      //           )
                      //         : Row(
                      //             children: [
                      //               Container(
                      //                 width: 70,
                      //                 height: 5,
                      //                 decoration: BoxDecoration(color: primary),
                      //               ),
                      //               Container(
                      //                 width: 50,
                      //                 height: 50,
                      //                 decoration: BoxDecoration(
                      //                     border: Border.all(
                      //                         width: 2,
                      //                         color: activeOrder != index
                      //                             ? primary
                      //                             : Colors.transparent),
                      //                     color: activeOrder == index
                      //                         ? primary
                      //                         : Colors.transparent,
                      //                     shape: BoxShape.circle),
                      //                 child: Center(
                      //                   child: Icon(
                      //                     MaterialIcons.check,
                      //                     color: white,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           );
                      //   }),
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Column(
                      //   children: [
                      //     Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //       children: List.generate(schedules.length, (index) {
                      //         return Container(
                      //           width: 70,
                      //           child: Text(
                      //             schedules[index]['state']["name"],
                      //             textAlign: TextAlign.center,
                      //             maxLines: 3,
                      //             style: smallMediumGreyText,
                      //           ),
                      //         );
                      //       }),
                      //     ),
                      //     SizedBox(
                      //       height: 10,
                      //     ),
                      //     Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //       children: List.generate(schedules.length, (index) {
                      //         return Container(
                      //           width: 70,
                      //           child: Text(
                      //             DateFormat("d MMM").format(DateTime.parse(
                      //                 schedules[index]['date'])),
                      //                 textAlign: TextAlign.center,
                      //                 maxLines: 1,
                      //             style: smallMediumBlackText,
                      //           ),
                      //         );
                      //       }),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 25,
                      // ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/customer_support_page'),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.chat,
                                  color: white,
                                ),
                                Text(
                                  "customer_support_have_an_issue",
                                  style: smallMediumWhiteText,
                                ).tr()
                              ],
                            ),
                          ),
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
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "order_id".tr() + " ${orderData['invoice_number']}",
                        style: smallMediumBlackText,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "order_placed_on".tr() + " $timeStamp",
                        style: smallBlackText,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      getItems(),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "mrp_total",
                            style: smallMediumBlackText,
                          ).tr(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "$CURRENCY ${orderData['mrp_total']}",
                                style: smallMediumBlackText,
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "discount",
                            style: smallMediumPrimaryText,
                          ).tr(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "- $CURRENCY ${orderData['discount']}",
                                style: smallMediumPrimaryText,
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "item_total",
                            style: smallMediumBlackText,
                          ).tr(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "$CURRENCY ${orderData['sub_total']}",
                                style: smallMediumBlackText,
                              )
                            ],
                          )
                        ],
                      ),
                      if (!checkIsNullValue(orderData['amount_off']))
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "coupon_discount",
                                style: smallMediumBlackText,
                              ).tr(),
                              Text(
                                "$CURRENCY ${orderData['amount_off']}",
                                style: smallMediumBlackText,
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "delivery",
                            style: smallMediumBlackText,
                          ).tr(),
                          Text(
                            "$CURRENCY ${orderData['delivery']}",
                            style: smallMediumBlackText,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "taxed_and_charges",
                            style: smallMediumBlackText,
                          ).tr(),
                          Text(
                            "$CURRENCY ${orderData['vat']}",
                            style: smallMediumBlackText,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "total",
                            style: smallMediumBoldBlackText,
                          ).tr(),
                          Text(
                            "$CURRENCY ${orderData['total']}",
                            style: smallMediumBoldBlackText,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Container(
                      width: size.width * 0.5,
                      child: Divider(
                        thickness: 0.8,
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 15, right: 15),
                //   child: Container(
                //     width: size.width,
                //     height: 135,
                //     decoration: BoxDecoration(
                //         color: placeHolderColor,
                //         borderRadius: BorderRadius.circular(10)),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: SliderWidget(
                    items: ads,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
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
          // Padding(
          //   padding:
          //       const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
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
          //             border: InputBorder.none,
          //             hintText: "search_for_dal_atta_oil_bread".tr()
          //           ),
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
          //               MaterialIcons.menu,
          //               size: 30,
          //               color: greyLight,
          //             )),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // cart section
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 15),
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
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/root_app", (route) => false);
                    },
                    child: Center(
                      child: SvgPicture.asset(
                        iconPath + "home_icon.svg",
                        width: 25,
                        color: greyLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      joinWhatsappGroup();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: whatsAppColor,
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
                            Icon(
                              LineIcons.whatSApp,
                              color: white,
                              size: 25,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              "Join Whatsapp Group",
                              style: normalWhiteText,
                            ).tr(),
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

  joinWhatsappGroup() async {
    await launch("https://go.teznow.com/whatsapp-group");
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "Joined Whatsapp Group": "Joined Whatsapp Group"
    };

    mixpanel.track(CLICK_SHARE_ORDER_WHATSAPP, properties: dataPanel);
  }
}
