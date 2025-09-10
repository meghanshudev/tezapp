import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';

class IconBox extends StatelessWidget {
  IconBox(
      {Key? key,
      required this.child,
      this.bgColor = primary,
      this.onTap,
      this.borderColor = Colors.transparent,
      this.radius = 50,
      this.padding = 5,
      this.isShadow = true})
      : super(key: key);
  final Widget child;
  final Color borderColor;
  final Color bgColor;
  final double padding;
  final double radius;
  final GestureTapCallback? onTap;
  final bool isShadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (isShadow)
              BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0), // changes position of shadow
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}
