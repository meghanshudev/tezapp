import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/ui_elements/custom_image.dart';

import '../../helpers/constant.dart';
import '../../helpers/utils.dart';
import 'guest_add_to_cart_button_item.dart';

class GuestProductCard extends StatelessWidget {
  final dynamic data;
  final GestureTapCallback? onTap;

  const GuestProductCard({Key? key, required this.data, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: white,
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.06),
              spreadRadius: 2,
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: CustomImage(
                data["image"],
                radius: 10,
                width: double.infinity,
                isShadow: false,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data["name"],
                      style: meduimBoldBlackText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      data["attributes"].length == 0
                          ? ""
                          : data["attributes"][0]["value"],
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: checkIsNullValue(data["percent_off"]) ||
                                  data["percent_off"] == 0
                              ? Text(
                                  CURRENCY + "${data["unit_price"]}",
                                  style: smallMediumBoldBlackText,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CURRENCY + "${data["unit_price"]}",
                                      style: smallStrikeBoldBlackText,
                                    ),
                                    Text(
                                      CURRENCY + "${data["sale_price"]}",
                                      style: smallMediumBoldBlackText,
                                    )
                                  ],
                                ),
                        ),
                        GuestAddToCardButtonItem(
                          product: data,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}