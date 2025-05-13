import 'package:flutter/material.dart';

import '../helpers/theme.dart';
import 'content_placeholder.dart';

class UserGroupViewLoading extends StatelessWidget {
  const UserGroupViewLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          ContentPlaceholder(height: 20, width: 180,),
          ContentPlaceholder(height: 10, width: 300,),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
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
                Row(
                  children: [
                    ContentPlaceholder(
                      height: 70, 
                      width: 70, 
                      borderRadius: 70,
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContentPlaceholder(height: 10, width: 80,),
                          ContentPlaceholder(height: 10, width: 230,),
                          ContentPlaceholder(height: 10, width: 130,),
                        ],
                      ),
                    ),
                  ],
                ),
                ContentPlaceholder(height: 10, width: 180,),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Row(
            children: [
              Expanded(child: ContentPlaceholder(height: 50)),
              SizedBox(width: 30,),
              Expanded(child: ContentPlaceholder(height: 50)),
            ],
          ),
          ContentPlaceholder(height: 50),
        ],
      ),
    );
  }
}