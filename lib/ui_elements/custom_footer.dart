import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/theme.dart';

import 'border_button.dart';

class CustomFooter extends StatelessWidget {
  CustomFooter({Key? key, this.onTapBack, this.activePageIndex = 3})
      : super(key: key);
  final GestureTapCallback? onTapBack;
  final int activePageIndex;
  @override
  Widget build(BuildContext context) {
    List bottomItems = [
      iconPath + "home_icon.svg",
    ];
    return Container(
      width: double.infinity,
      height: 90,
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(color: white, boxShadow: [
        BoxShadow(
            color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
      ]),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(bottomItems.length, (index) {
                if (index == 0) {
                  return BorderButton(
                    title: "back".tr(),
                    prefixIcon: Icon(
                      Icons.arrow_back_ios_new,
                      color: primary,
                    ),
                    onTap: onTapBack,
                  );
                }
                return InkWell(
                  onTap: () {
                    if (activePageIndex == index) return;
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/root_app', (Route<dynamic> route) => false,
                        arguments: {"activePageIndex": index - 1});
                  },
                  child: SvgPicture.asset(
                    bottomItems[index],
                    width: 28,
                    color: activePageIndex == index ? black : greyLight,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
