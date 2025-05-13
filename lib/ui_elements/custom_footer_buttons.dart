import 'package:flutter/material.dart';

import '../helpers/theme.dart';
import 'custom_button.dart';
import 'icon_box.dart';

class CustomFooterButtons extends StatelessWidget {
  CustomFooterButtons(
      {Key? key,
      this.proceedTitle = "Save Changes",
      this.titleCenter = false,
      this.titlePadding = const EdgeInsets.only(left: 55),
      this.isLoading = false,
      required this.onTapBack,
      required this.onTapProceed})
      : super(key: key);
  final GestureTapCallback onTapBack;
  final GestureTapCallback onTapProceed;
  final String proceedTitle;
  final bool titleCenter;
  final EdgeInsets titlePadding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 23, 15, 33),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          IconBox(
            child: Icon(Icons.arrow_back_ios_new, color: black),
            radius: 10,
            padding: 15,
            bgColor: cardColor,
            onTap: () {
              onTapBack();
            },
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomButton(
              height: 55,
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: white,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (titleCenter)
                          SizedBox(
                            width: 15,
                          ),
                        Padding(
                          padding: titlePadding,
                          child: Text(
                            proceedTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
              onTap: onTapProceed,
            ),
          ),
        ],
      ),
    );
  }
}
