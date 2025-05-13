import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../helpers/styles.dart';
import '../helpers/theme.dart';

class CouponItem extends StatelessWidget {
  CouponItem({Key? key, required this.data, required this.onApply})
      : super(key: key);
  final data;
  final GestureTapCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 125,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: white,
        boxShadow: [
          BoxShadow(
              color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data["name"],
                      style: meduimBlackText,
                    ),
                    GestureDetector(
                      onTap: onApply,
                      child: Text(
                        "apply",
                        style: meduimBoldPrimaryText,
                      ).tr(),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  data["description"],
                  style: smallMediumGreyText,
                )
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.add,
                  size: 17,
                ),
                SizedBox(
                  width: 3,
                ),
                Text(
                  "more",
                  style: smallMediumBlackText,
                ).tr(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
