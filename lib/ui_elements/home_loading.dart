import 'package:flutter/material.dart';
import 'package:tez_mobile/ui_elements/content_placeholder.dart';

class HomeLoading extends StatelessWidget {
  const HomeLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentPlaceholder(height: 50),
          ContentPlaceholder(height: 100,),
          Column(
            children: List.generate(2, (index) {
              return Row(
                children: [
                  Expanded(child: ContentPlaceholder(height: 70,)),
                  SizedBox(width: 20,),
                  Expanded(child: ContentPlaceholder(height: 70,)),
                  SizedBox(width: 20,),
                  Expanded(child: ContentPlaceholder(height: 70,)),
                ],
              );
            }),
          ),
          Column(
            children: List.generate(3, (index) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: ContentPlaceholder(height: 15)),
                      SizedBox(width: 50,),
                      Expanded(child: ContentPlaceholder(height: 15)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: ContentPlaceholder(height: 200)),
                      SizedBox(width: 20,),
                      Expanded(child: ContentPlaceholder(height: 200)),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}