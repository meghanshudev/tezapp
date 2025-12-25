import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'package:tezchal/helpers/network.dart';

import '../helpers/utils.dart';
import 'custom_box.dart';

class OrderHistoryBox extends StatelessWidget {
  OrderHistoryBox({Key? key, required this.data, this.onOrderCancelled})
      : super(key: key);
  final data;
  final VoidCallback? onOrderCancelled;

  @override
  Widget build(BuildContext context) {
    String timeStamp =
        DateFormat("MMM d").format(DateTime.parse(data['order_date'])) +
            " at " +
            DateFormat("hh:mmaaa").format(DateTime.parse(data['order_date']));
    String expectedDate = "N/A";
    if (data.containsKey('schedules')) {
      for (int i = 0; i < data['schedules'].length; i++) {
        if (data['schedules'][i]['state']['code'] == "delivery_to_you") {
          expectedDate = DateFormat("EEEE, MMM d")
              .format(DateTime.parse(data['schedules'][i]['date']));
          break;
        }
      }
    }
    bool isCancelled = data["is_cancelled"] ? true : false;
    bool isDelivered = data["state"]["code"] == "delivery_to_you";
    bool canCancel = data['can_cancel'] ?? false;

    var cart = data['lines'];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, 25, 22, 25),
      margin: EdgeInsets.fromLTRB(15, 5, 15, 10),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("order_id",
                      style:
                          TextStyle(height: 1.5, fontWeight: FontWeight.w700))
                  .tr(),
              Text(data["invoice_number"], style: TextStyle(height: 1.5)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "order_placed_on".tr(),
                maxLines: 2,
                style: TextStyle(height: 1.5, fontWeight: FontWeight.w700),
              ),
              Text(" $timeStamp", style: TextStyle(height: 1.5)),
            ],
          ),
          if (data.containsKey('payment_type') &&
              !checkIsNullValue(data['payment_type']))
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("payment_method".tr(),
                    style: TextStyle(height: 1.5, fontWeight: FontWeight.w700)),
                Text(data['payment_type']['name'],
                    style: TextStyle(
                      height: 1.5,
                    )),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCancelled
                    ? "Order Cancelled"
                    : isDelivered
                        ? "Order Delivered"
                        : "In Progress",
                style: TextStyle(
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: isCancelled
                      ? Colors.red
                      : isDelivered
                          ? Colors.green
                          : Colors.orange,
                ),
              ),
              if (!isCancelled && !isDelivered)
                GestureDetector(
                  onTap: canCancel
                      ? () {
                          _cancelOrder(context, data['id'].toString());
                        }
                      : null,
                  child: Text("cancel_order?".tr(),
                      style: TextStyle(
                          height: 1.5,
                          color: canCancel ? primary : Colors.grey,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Divider(
              color: dividerColor,
            ),
          ),
          getItems(cart),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Divider(
              color: dividerColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("mrp_total", style: meduimBlackText).tr(),
              SizedBox(
                width: 5,
              ),
              Text("$CURRENCY ${data['mrp_total']}"),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("defence_discount", style: meduimPrimaryText).tr(),
              SizedBox(
                width: 5,
              ),
              Text("- $CURRENCY ${data['discount']}",
                  style: TextStyle(color: primary)),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("item_total", style: meduimBlackText).tr(),
              SizedBox(
                width: 5,
              ),
              Text("$CURRENCY ${data['sub_total']}"),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("delivery_fee", style: meduimBlackText).tr(),
              SizedBox(
                width: 5,
              ),
              Text("$CURRENCY ${data['delivery']}"),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("charges_&_taxed", style: meduimBlackText).tr(),
              SizedBox(
                width: 5,
              ),
              Text("$CURRENCY ${data['vat'] ?? 0}"),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          if (!checkIsNullValue(userSession) && userSession['is_defence_personnel'] == true && !checkIsNullValue(data['defence_discount_percent']))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("defence_discount", style: meduimPrimaryText).tr(),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "- $CURRENCY ${data['defence_discount_percent'].toStringAsFixed(2)}",
                  style: TextStyle(color: primary),
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("total", style: meduimBlackText).tr(),
              SizedBox(
                width: 5,
              ),
              Text("$CURRENCY ${data['total']}"),
            ],
          ),
          // Text("Group Leader Address:", style: meduimBlackText),
          // SizedBox(
          //   height: 5,
          // ),
          // Text("Kartik Gurmule"),
          // SizedBox(
          //   height: 5,
          // ),
          // Text("+91 7709690475"),
          // SizedBox(
          //   height: 5,
          // ),
          // Text("192, Nandanwan Main Road, Nagpur, 440024"),
          // SizedBox(
          //   height: 20,
          // ),
        ],
      ),
    );
  }

  Widget getItems(cart) {
    if (checkIsNullValue(cart)) return SizedBox();

    return Column(
      children: List.generate(cart.length, (index) {
        var _product = cart[index]["product"];
        var qty = cart[index]['qty'].toString();
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  "[$qty]" + " ${_product["name"]}",
                ),
              ),
              SizedBox(
                width: 30,
              ),
              checkIsNullValue(cart[index]['percent_off'])
                  ? Text(
                      "$CURRENCY ${cart[index]['total']}",
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
                        )
                      ],
                    )
            ],
          ),
        );
      }),
    );
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    confirmAlert(
      context,
      des: 'are_you_sure_you_want_to_cancel_this_order'.tr(),
      btnCancelTitle: 'no'.tr(),
      btnConfirmTitle: 'yes'.tr(),
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () async {
        Navigator.of(context).pop();
        var response =
            await netPost(endPoint: "me/order/$orderId/cancel", params: {});
        if (response["resp_code"] == "200") {
          showToast('order_cancelled_successfully'.tr(), context);
          if (onOrderCancelled != null) {
            onOrderCancelled!();
          }
        } else {
          var ms = response["resp_data"]["message"] ??
              'failed_to_cancel_order'.tr();
          showToast(ms.toString(), context);
        }
      },
    );
  }
}
