import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/ui_elements/content_placeholder.dart';

class TransactionLoading extends StatelessWidget {
  const TransactionLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
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
                ContentPlaceholder(
                  height: 15,
                ),
                SizedBox(
                  height: 5,
                ),
                ContentPlaceholder(
                  width: 150,
                  height: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}