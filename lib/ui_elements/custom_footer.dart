import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/theme.dart';

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
          // Padding(
          //   padding: const EdgeInsets.only(top: 25, bottom: 20),
          //   child: Container(
          //     width: double.infinity,
          //     height: 50,
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(10),
          //         color: white,
          //         boxShadow: [
          //           BoxShadow(
          //               color: black.withOpacity(0.06),
          //               spreadRadius: 5,
          //               blurRadius: 10)
          //         ]),
          //     child: Row(
          //       children: [
          //         Container(
          //           width: 60,
          //           child: Center(
          //               child: Icon(
          //             Icons.search,
          //             size: 30,
          //             color: greyLight,
          //           )),
          //         ),
          //         Flexible(
          //             child: TextField(
          //               onTap: () => Navigator.pushNamed(context, "/product_search_page"),
          //           cursorColor: black,
          //           decoration: InputDecoration(
          //             border: InputBorder.none,
          //             hintText: "search_for_dal_atta_oil_bread".tr()
          //           ),
          //         )),
          //         SizedBox(
          //           width: 15,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.only(top: 8, bottom: 8),
          //           child: Container(
          //             width: 60,
          //             decoration: BoxDecoration(
          //                 border: Border(
          //                     left: BorderSide(
          //                         width: 1, color: placeHolderColor))),
          //             child: Center(
          //                 child: Icon(
          //               Icons.menu,
          //               size: 30,
          //               color: greyLight,
          //             )),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
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
