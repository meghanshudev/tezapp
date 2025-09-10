import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/models/transaction.dart';

class TransactionItem extends StatefulWidget {

  final Transaction item;
  const TransactionItem({ 
    Key? key,
    required this.item 
  }) : super(key: key);

  @override
  _TransactionItemState createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
      margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.remark,
                  style: normalBlackText,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(widget.item.date),
              ],
            ),
          ),
          Text(
            (widget.item.trxType == "cr") ?
            "+ ₹" + widget.item.amount.toString() : "- ₹" + widget.item.amount.toString(),
            style: normalGreyText,
          ),
        ],
      ),
    );
  }
}