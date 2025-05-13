import 'package:flutter/material.dart';

import 'content_placeholder.dart';

class CartLoading extends StatelessWidget {
  const CartLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: List.generate(2, (index) {
              return Row(
                children: [
                  ContentPlaceholder(width: 70, height: 70, borderRadius: 0,),
                  SizedBox(width: 10,),
                  Expanded(
                    flex: 3, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContentPlaceholder(height: 15,),
                        ContentPlaceholder(height: 10, width: 100,),
                      ],
                    )
                  ),
                  SizedBox(width: 10,),
                  ContentPlaceholder(width: 40, height: 70, borderRadius: 0,),
                ],
              );
            }),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContentPlaceholder(height: 60,),
                SizedBox(height: 10,),
                ContentPlaceholder(height: 15, width: 150, spacing: EdgeInsets.only(bottom: 5),),
                ContentPlaceholder(height: 10, width: 100,),
                ContentPlaceholder(height: 60,),
                ContentPlaceholder(height: 60,),
                Column(
                  children: List.generate(4, (index) {
                    return Row(
                      children: [
                        Expanded(child: ContentPlaceholder(height: 15,)),
                        Spacer(),
                        Expanded(child: ContentPlaceholder(height: 15,)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}