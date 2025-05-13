import 'package:flutter/material.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';

import '../helpers/constant.dart';
import '../helpers/utils.dart';

class CustomSubHeader extends StatelessWidget {
  CustomSubHeader({Key? key, required this.title, this.subtitle, this.subChild})
      : super(key: key);
  final String title;
  final String? subtitle;
  final Widget? subChild;

  @override
  Widget build(BuildContext context) {
    String tempSubTitile = subtitle ??
        "${userProfile['name']}  • $PREFIX_PHONE ${userProfile['phone_number']}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18, top: 21),
          child: Text(
            title,
            style: normalBoldBlackTitle,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18, bottom: 10),
          child: Text(
            tempSubTitile,
            style: smallBlackText,
          ),
        ),
        if (subChild != null)
          SizedBox(
            child: subChild,
          ),
        Divider(
          color: dividerColor,
        ),
      ],
    );
  }
}
