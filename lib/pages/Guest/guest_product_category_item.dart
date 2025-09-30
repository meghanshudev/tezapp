import 'package:flutter/material.dart';
import 'package:tezchal/pages/Guest/guest_product_card.dart';

class GuestProductCategoryItem extends StatelessWidget {
  final dynamic data;
  final GestureTapCallback? onTap;

  const GuestProductCategoryItem({Key? key, required this.data, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GuestProductCard(
      data: data,
      onTap: onTap,
    );
  }
}
