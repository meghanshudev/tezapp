import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';

class CustomRoundTextBox extends StatelessWidget {
  CustomRoundTextBox(
      {Key? key,
      this.hint = "",
      this.prefix,
      this.suffix,
      this.controller,
      this.readOnly = false,
      this.boxShadow,
      this.contentPadding})
      : super(key: key);
  final String hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool readOnly;
  final BoxShadow? boxShadow;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    BoxShadow _boxShadow = boxShadow ??
        BoxShadow(
          color: shadowColor.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 0), // changes position of shadow
        );
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 3),
      height: 40,
      decoration: BoxDecoration(
        color: textBoxColor,
        border: Border.all(color: textBoxColor),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [_boxShadow],
      ),
      child: TextField(
        readOnly: readOnly,
        controller: controller,
        decoration: InputDecoration(
            contentPadding: contentPadding,
            prefixIcon: prefix,
            suffixIcon: suffix,
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 15)),
      ),
    );
  }
}
