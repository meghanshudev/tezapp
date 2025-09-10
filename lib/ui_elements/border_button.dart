import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';

class BorderButton extends StatelessWidget {
  BorderButton(
      {Key? key,
      this.width = 99,
      this.height = 50,
      this.title = "",
      this.textStyle = normalPrimaryText,
      this.prefixIcon,
      this.isLoading = false,
      this.suffixIcon,
      this.borderColor = primary,
      this.padding,
      this.alignment = MainAxisAlignment.center,
      this.onTap})
      : super(key: key);
  final double width;
  final double height;
  final String title;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color borderColor;
   final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final TextStyle textStyle;
  final GestureTapCallback? onTap;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor)),
        child: Row(
          mainAxisAlignment: alignment,
          children: [

            if (prefixIcon != null) prefixIcon!,
            isLoading
                    ? 
                        SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: primary,
                              strokeWidth: 3,
                            ))
                      
                    :
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text(
                title,
                style: textStyle,
              ),
            ),
            // suffixIcon ?? SizedBox(),
            if (suffixIcon != null) suffixIcon!,
          ],
        ),
      ),
    );
  }
}
