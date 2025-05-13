import 'package:flutter/material.dart';
import 'package:tez_mobile/helpers/constant.dart';
import 'package:tez_mobile/helpers/utils.dart';

import '../helpers/styles.dart';
import '../helpers/theme.dart';

class SubCategoryItem extends StatelessWidget {
  final int activeItem;
  final int index; 
  const SubCategoryItem({Key? key, required this.data,this.activeItem = 0,this.index = 0, this.onTap})
      : super(key: key);
  final data;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primary, width: activeItem == index ? 2.5 : 1.5)),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60 / 2),
                child: Image(
                  image: displayImage(data["image"]),
                  width: 45,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              data['name'],
              textAlign: TextAlign.center,
              style: activeItem == index ? smallBoldPrimaryText : smallBlackText,
            ),
          )
        ],
      ),
    );
  }
}
