import 'package:flutter/material.dart';
import 'package:tezchal/ui_elements/product_card.dart';

class ProductCategoryItem extends StatelessWidget {
  final dynamic data;
  final GestureTapCallback? onTap;

  const ProductCategoryItem({Key? key, required this.data, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      data: data,
      onTap: onTap,
    );
  }
}
