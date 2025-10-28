import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/ui_elements/custom_image.dart';

import '../helpers/constant.dart';
import '../helpers/utils.dart';
import 'add_to_cart_button_item.dart';

class ProductCard extends StatelessWidget {
  final dynamic data;
  final GestureTapCallback? onTap;

  const ProductCard({Key? key, required this.data, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int discountRounded = convertDouble(data["percent_off"]).toInt();
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
            // Increase image section size slightly
            Expanded(
              flex: 6,
              child: CustomImage(
                data["image"],
                radius: 10,
                width: double.infinity,
                isShadow: false,
                fit: BoxFit.cover,
              ),
            ),
            // Decrease content section size slightly
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and attributes section - with tighter constraints
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Limit product name to 1 line to save space
                          Text(
                            data["name"],
                            style: meduimBoldBlackText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // SizedBox(
                          //   height: 2, // Reduce spacing
                          // ),
                          Text(
                            data["attributes"].length == 0
                                ? ""
                                : data["attributes"][0]["value"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price and add to cart button section - reduce height
                    Container(
                      height: 40, // Reduced height for the bottom section
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price section - give it more space (75%)
                          Expanded(
                            flex: 3,
                            child: checkIsNullValue(data["percent_off"]) ||
                                    data["percent_off"] == 0
                                ? Text(
                                    CURRENCY + "${data["unit_price"]}",
                                    style: smallMediumBoldBlackText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        CURRENCY + "${data["unit_price"]}",
                                        style: smallStrikeBoldBlackText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        CURRENCY + "${data["sale_price"]}",
                                        style: smallMediumBoldBlackText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                          ),
                          // Add button section - make it even smaller
                          Container(
                            width: 50, // Fixed width for the button
                            height: 35, // Fixed height for the button
                            child: AddToCardButtonItem(
                              product: data,
                            ),
                          )
                        ],
                      ),
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
