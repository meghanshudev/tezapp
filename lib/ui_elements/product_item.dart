import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';

class ProductItem extends StatelessWidget {
  final double? width, height;
  final String discountLabel;
  final String kgLabel;
  final String image;
  final String name;
  final String priceStrike;
  final String price;
  const ProductItem(
      {Key? key,
      required this.discountLabel,
      required this.kgLabel,
      required this.image,
      required this.name,
      required this.priceStrike,
      required this.price,
      this.width = 160,
      this.height = 230})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: white,
          boxShadow: [
            BoxShadow(
                color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 70,
                  height: 25,
                  decoration: BoxDecoration(
                      color: primary, borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      discountLabel,
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
            Image.asset(
              image,
              width: 130,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              name,
              style: meduimGreyText,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceStrike,
                      style: smallStrikeBoldBlackText,
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Text(
                      price,
                      style: smallMediumBoldBlackText,
                    )
                  ],
                ),
                Container(
                  width: 80,
                  height: 35,
                  decoration: BoxDecoration(
                      border: Border.all(color: greyLight),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      "ADD",
                      style: meduimPrimaryText,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
