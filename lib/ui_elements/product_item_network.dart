import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/ui_elements/add_to_cart_button_item.dart';
import 'package:tezchal/ui_elements/custom_image.dart';

class ProductItemNetwork extends StatelessWidget {
  final double? width;
  final int discountLabel;
  final String kgLabel;
  final String image;
  final String name;
  final String priceStrike;
  final String price;
  final dynamic product;
  const ProductItemNetwork(
      {Key? key,
      this.width = 160,
      this.product,
      required this.discountLabel,
      required this.kgLabel,
      required this.image,
      required this.name,
      required this.priceStrike,
      required this.price})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (!checkIsNullValue(discountLabel) && discountLabel > 0)
                    ? Container(
                        width: 80,
                        height: 25,
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "$discountLabel% " + "off".tr(),
                            style: smallBoldWhiteText,
                          ),
                        ),
                      )
                    : Container(
                        width: 72,
                        height: 25,
                        margin: EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "popular".tr(),
                            style: smallBoldWhiteText,
                          ),
                        ),
                      ),
                Text(
                  kgLabel,
                  style: smallBoldBlackText,
                )
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: CustomImage(
                image,
                radius: 0,
                isShadow: false,
                width: 85,
                height: 85,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              height: 33,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceStrike,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                // Container(
                //   width: 80,
                //   height: 35,
                //   decoration: BoxDecoration(
                //       border: Border.all(color: greyLight),
                //       borderRadius: BorderRadius.circular(10)),
                //   child: Center(
                //     child: Text(
                //       "add".tr(),
                //       style: meduimPrimaryText,
                //     ),
                //   ),
                // ),
                AddToCardButtonItem(product: product)
              ],
            )
          ],
        ),
      ),
    );
  }
}
