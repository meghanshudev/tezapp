import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key,
      required this.onTap,
      this.title = "",
      this.fsize = 18,
      this.width = double.infinity,
      this.height = 45,
      this.bgColor = primary,
      this.icon,
      this.disableButton = false,
      this.isLoading = false,
      this.radius = 10,
      this.textColor = Colors.white,
      this.child})
      : super(key: key);
  final GestureTapCallback onTap;
  final String title;
  final double fsize;
  final Color textColor;
  final double width;
  final double height;
  final double radius;
  final Color bgColor;
  final IconData? icon;
  final bool disableButton;
  final bool isLoading;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disableButton,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: disableButton ? bgColor.withOpacity(0.3) : bgColor,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          width: width,
          height: height,
          child: child ??
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: isLoading
                    ? [
                        SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: textColor,
                              strokeWidth: 3,
                            ))
                      ]
                    : (icon == null)
                        ? [
                            Text(
                              title,
                              style: TextStyle(
                                  fontSize: fsize,
                                  color: disableButton
                                      ? textColor.withOpacity(0.3)
                                      : textColor,
                                  fontWeight: FontWeight.w600),
                            )
                          ]
                        : [
                            Icon(
                              icon,
                              size: fsize + 7,
                              color: disableButton
                                  ? textColor.withOpacity(0.3)
                                  : textColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              title,
                              style: TextStyle(
                                  fontSize: fsize,
                                  color: disableButton
                                      ? textColor.withOpacity(0.3)
                                      : textColor,
                                  fontWeight: FontWeight.w600),
                            )
                          ],
              ),
        ),
      ),
    );
  }
}
