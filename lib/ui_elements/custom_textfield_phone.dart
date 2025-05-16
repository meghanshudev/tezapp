import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';

class CustomTextFieldPhone extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextFieldPhone({Key? key, this.hintText, this.controller, this.keyboardType, this.inputFormatters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: placeHolderColor)),
      child: Row(
        children: [
          Container(
            width: 60,
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(width: 1, color: placeHolderColor))),
            child: Center(
                child: Text(
              PREFIX_PHONE,
              style: normalBlackCountryCode,
            )),
          ),
          SizedBox(
            width: 15,
          ),
          Flexible(
              child: TextField(
                inputFormatters: inputFormatters,
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: black,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: hintText),
          )),
          SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }
}
