import 'package:flutter/material.dart';

import '../helpers/theme.dart';

class CustomBox extends StatelessWidget {
  CustomBox(
      {Key? key,
      required this.child,
      this.bgColor,
      this.borderColor = Colors.transparent,
      this.radius = 50,
      this.isShadow = true,
      this.height = 45,
      this.padding = 5})
      : super(key: key);
  final Widget child;
  final Color borderColor;
  final Color? bgColor;
  final double radius;
  final double padding;
  final bool isShadow;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: bgColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (isShadow)
            BoxShadow(
              color: shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1), // changes position of shadow
            ),
        ],
      ),
      child: child,
    );
  }
}
