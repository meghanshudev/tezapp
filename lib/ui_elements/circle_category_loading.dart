import 'package:flutter/material.dart';

import 'content_placeholder.dart';

class CircleCategoryLoading extends StatelessWidget {
  const CircleCategoryLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContentPlaceholder(
          height: 60, 
          width: 60, 
          borderRadius: 60, 
          spacing: EdgeInsets.only(bottom: 0),
        ),
        ContentPlaceholder(height: 15, width: 60,),
      ],
    );
  }
}