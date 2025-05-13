import 'package:flutter/material.dart';

import '../helpers/theme.dart';
import 'content_placeholder.dart';

class LeaderOrderDetailLoading extends StatelessWidget {
  const LeaderOrderDetailLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          ContentPlaceholder(height: 20, width: 180,),
          ContentPlaceholder(height: 10, width: 280,),
          ContentPlaceholder(height: 50,),
          SizedBox(height: 20,),
          Column(
            children: List.generate(5, (index) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 25, 20, 5),
                margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
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
                    ContentPlaceholder(height: 15, width: 150,),
                    SizedBox(height: 5,),
                    ContentPlaceholder(height: 10, width: 200, spacing: EdgeInsets.only(bottom: 5)),
                    ContentPlaceholder(height: 10, width: 250,),
                    SizedBox(height: 10,),
                    Column(
                      children: List.generate(2, (index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContentPlaceholder(height: 10, width: 110, spacing: EdgeInsets.only(bottom: 5),),
                            ContentPlaceholder(height: 10, width: 140, spacing: EdgeInsets.only(bottom: 5),),
                          ],
                        );
                      }),
                    ),
                    SizedBox(height: 10,),
                    ContentPlaceholder(height: 15,),
                    ContentPlaceholder(height: 15, width: 230,),
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}