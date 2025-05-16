import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';

class LeaderOrderDetailItem extends StatefulWidget {
  final data;
  const LeaderOrderDetailItem({Key? key, this.data}) : super(key: key);

  @override
  _LeaderOrderDetailItemState createState() => _LeaderOrderDetailItemState();
}

class _LeaderOrderDetailItemState extends State<LeaderOrderDetailItem> {
  dynamic data = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      data = widget.data;
    });
    // print(widget.data);
  }
  @override
  Widget build(BuildContext context) {
     var customerName= formatFullDateTime(data['customer_name']);
    var date= formatFullDateTime(data['order_date']);
    var total = data['total'].toString();
    List productItems = data['lines'];
    var paymentType = data['payment_type']['name'];
    var commission = data['commission'].toString();
  
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
          Text(
            customerName,
            style: normalBlackText,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 100),
            child: Divider(
              color: dividerColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("order_id".tr() + " ${data['invoice_number']}"),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "order_placed_on".tr() + " $date",
                style: smallBlackText,
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Column(
            children: List.generate(productItems.length, (index) {
              var name = productItems[index]['product']['name'];
              var attributeValue = productItems[index]['product']['attributes'][0]['attribute_value'];
            
             
              return   Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text("$name • $attributeValue"),
            ],
          ),
              );
            }),
          ),
        
          SizedBox(
            height: 20,
          ),
          Text(
            "total".tr() + ": ₹$total • ${productItems.length} " + "item_s".tr() + " • $paymentType",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,height: 1.3),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "your_commission".tr() + ": ₹$commission",
            style: TextStyle(
                color: primary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
         
         
        ],
      ),
    );
  }
}
