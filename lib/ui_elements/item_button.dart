import 'package:flutter/material.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';

import 'custom_button.dart';

class ItemButton extends StatelessWidget {
  ItemButton(
      {Key? key,
      required this.title,
      required this.onTap,
      this.icon = Icons.arrow_forward_ios,
      this.textStyle = normalBlackText,
      this.iconColor = darker})
      : super(key: key);
  final String title;
  final TextStyle textStyle;
  final IconData icon;
  final Color iconColor;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      bgColor: cardColor,
      height: 55,
      child: Padding(
        padding: const EdgeInsets.only(left: 29, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textStyle,
            ),
            Icon(
              icon,
              size: 20,
              color: iconColor,
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
