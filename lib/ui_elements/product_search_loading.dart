import 'package:flutter/material.dart';
import 'package:tezchal/ui_elements/content_placeholder.dart';

class ProductSearchLoading extends StatelessWidget {
  const ProductSearchLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: List.generate(5, (index) {
              return Row(
                children: [
                  Expanded(child: ContentPlaceholder(height: 230,)),
                  SizedBox(width: 15,),
                  Expanded(child: ContentPlaceholder(height: 230,)
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