import 'package:flutter/material.dart';

import '../helpers/theme.dart';
import 'content_placeholder.dart';

class CategoryLoading extends StatelessWidget {
  const CategoryLoading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: ContentPlaceholder(),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContentPlaceholder(
                        height: 10,
                        spacing: EdgeInsets.only(bottom: 5),
                      ),
                      ContentPlaceholder(
                        height: 10,
                        width: 100,
                        spacing: EdgeInsets.only(bottom: 5),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ContentPlaceholder(height: 30),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: ContentPlaceholder(height: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}