import 'package:flutter/material.dart';

import 'content_placeholder.dart';

class LeaderViewDetailLoading extends StatelessWidget {
  const LeaderViewDetailLoading({ Key? key }) : super(key: key);

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
          SizedBox(height: 10,),
          ContentPlaceholder(height: 15, width: 130,),
          ContentPlaceholder(height: 10, width: 280, spacing: EdgeInsets.only(bottom: 5),),
          ContentPlaceholder(height: 10, width: 230,),
          ContentPlaceholder(height: 50,),
          Column(
            children: List.generate(2, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  ContentPlaceholder(height: 15, width: 130,),
                  ContentPlaceholder(height: 50, spacing: EdgeInsets.only(bottom: 0),),
                  ContentPlaceholder(height: 50, spacing: EdgeInsets.only(bottom: 0),),
                  ContentPlaceholder(height: 50,),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}