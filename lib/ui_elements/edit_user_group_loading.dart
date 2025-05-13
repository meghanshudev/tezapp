import 'package:flutter/material.dart';

import 'content_placeholder.dart';

class EditUserGroupLoading extends StatelessWidget {
  const EditUserGroupLoading({ Key? key }) : super(key: key);

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
          Row(
            children: [
              ContentPlaceholder(
                height: 100,
                width: 100,
                borderRadius: 100,
              ),
              SizedBox(width: 20,),
              Expanded(child: ContentPlaceholder(height: 50, ))
            ],
          ),
          ContentPlaceholder(height: 15, width: 100, spacing: EdgeInsets.only(bottom: 5),),
          ContentPlaceholder(height: 10, spacing: EdgeInsets.only(bottom: 0),),
          ContentPlaceholder(height: 10, width: 150,),
          ContentPlaceholder(height: 50,),
          Row(
            children: [
              Expanded(child: ContentPlaceholder(height: 50,),),
              SizedBox(width: 20,),
              Expanded(flex: 2, child: ContentPlaceholder(height: 50,),),
            ],
          ),
          ContentPlaceholder(height: 15, width: 100, spacing: EdgeInsets.only(bottom: 5),),
          ContentPlaceholder(height: 10, spacing: EdgeInsets.only(bottom: 0),),
          ContentPlaceholder(height: 10, width: 150,),
          ContentPlaceholder(height: 50,),
        ],
      ),
    );
  }
}