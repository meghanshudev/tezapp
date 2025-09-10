import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/ui_elements/custom_image.dart';

import '../../helpers/constant.dart';
import '../../helpers/utils.dart';
import '../Guest/guest_add_to_cart_button_item.dart';

class GuestProductCategoryItem extends StatefulWidget {
  GuestProductCategoryItem(
      {Key? key, required this.data, this.onTap, this.onTapAddToCart})
      : super(key: key);
  final data;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onTapAddToCart;

  @override
  _GuestProductCategoryItemState createState() =>
      _GuestProductCategoryItemState();
}

class _GuestProductCategoryItemState extends State<GuestProductCategoryItem> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var cardWidth = (size.width - (size.width * 0.23)) - 48;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: (size.width),
        height: 130,
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                flex: 4,
                child: Container(
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomImage(
                        widget.data["image"],
                        radius: 0,
                        width: (cardWidth / 12) * 4,
                        height: getHeight((cardWidth / 12) * 4, "1:1"),
                        isShadow: false,
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Flexible(
                flex: 8,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 38,
                        child: Text(
                          widget.data["name"],
                          style: meduimBoldBlackText,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        // height: 25,
                        // decoration: BoxDecoration(
                        //   color: primary
                        // ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.data["attributes"].length == 0
                                  ? ""
                                  : widget.data["attributes"][0]["value"],
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            if (!checkIsNullValue(widget.data["percent_off"]) &&
                                widget.data["percent_off"] > 0)
                              Container(
                                width: 78,
                                height: 25,
                                margin: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    "${widget.data["percent_off"]}% " +
                                        "off".tr(),
                                    style: verySmallBoldWhiteText,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          checkIsNullValue(widget.data["percent_off"])
                              ? Text(
                                  CURRENCY + "${widget.data["unit_price"]}",
                                  style: smallMediumBoldBlackText,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CURRENCY + "${widget.data["unit_price"]}",
                                      style: smallStrikeBoldBlackText,
                                    ),
                                    SizedBox(
                                      height: 1,
                                    ),
                                    Text(
                                      CURRENCY + "${widget.data["sale_price"]}",
                                      style: smallMediumBoldBlackText,
                                    )
                                  ],
                                ),
                          GuestAddToCardButtonItem(
                            product: widget.data,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
