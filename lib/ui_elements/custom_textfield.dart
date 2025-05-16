import 'package:flutter/material.dart';
import 'package:tezapp/helpers/theme.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool readOnly;

  const CustomTextField(
      {Key? key,
      this.hintText,
      this.controller,
      this.readOnly = false,
      this.keyboardType = TextInputType.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(

      width: size.width,
      height: 50,
      decoration: BoxDecoration(
          color: readOnly ? black.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: placeHolderColor)),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: TextField(
          readOnly: readOnly,
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: black,
          decoration:
              InputDecoration(border: InputBorder.none, hintText: hintText),
        ),
      ),
    );
  }
}
