import 'package:flutter/material.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/ui_elements/content_placeholder.dart';

class OrderHistoryLoading extends StatelessWidget {
  const OrderHistoryLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
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
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentPlaceholder(height: 10, width: 150,),
          ContentPlaceholder(height: 10,),
          ContentPlaceholder(height: 10, width: 200,),
          Column(
            children: List.generate(7, (index) {
              return Row(
                children: [
                  Flexible(child: ContentPlaceholder(height: 10,)),
                  Spacer(),
                  Flexible(child: ContentPlaceholder(height: 10,)),
                ],
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: ContentPlaceholder(height: 40)),
              SizedBox(width: 50,),
              Expanded(child: ContentPlaceholder(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}