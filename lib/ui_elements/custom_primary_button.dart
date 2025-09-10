import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  const CustomPrimaryButton(
      {Key? key, required this.text, this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 50,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: normalWhiteText,
              ),
      ),
    );
  }
}
