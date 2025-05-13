import 'package:flutter/material.dart';

import '../helpers/theme.dart';
import 'content_placeholder.dart';

class CategoryLoading extends StatelessWidget {
  const CategoryLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
      margin: EdgeInsets.fromLTRB(0, 0, 10, 20),
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
      child: Row(
        children: [
          Expanded(flex: 2, child: ContentPlaceholder(height: 80,),),
          SizedBox(width: 20,),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContentPlaceholder(height: 10, spacing: EdgeInsets.only(bottom: 5),),
                ContentPlaceholder(height: 10, width: 100, spacing: EdgeInsets.only(bottom: 5),),
                Row(
                  children: [
                    Expanded(flex: 2, child: ContentPlaceholder(height: 30),),
                    Spacer(),
                    Expanded(
                      flex: 3,
                      child: ContentPlaceholder(height: 30,),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}