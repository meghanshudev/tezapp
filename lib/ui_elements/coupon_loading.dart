import 'package:flutter/material.dart';

import '../helpers/theme.dart';
import 'content_placeholder.dart';

class CouponLoading extends StatelessWidget {
  const CouponLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
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
            children: [
              Expanded(child: ContentPlaceholder(height: 20, spacing: EdgeInsets.only(bottom: 5),)),
              Spacer(),
              Expanded(child: ContentPlaceholder(height: 20, spacing: EdgeInsets.only(bottom: 5),)),
            ],
          ),
          ContentPlaceholder(height: 10, width: 150,),
          SizedBox(height: 5,),
          ContentPlaceholder(height: 15, width: 80,),
        ],
      ),
    );
  }
}