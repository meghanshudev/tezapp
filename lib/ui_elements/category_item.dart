import 'package:flutter/material.dart';
import 'package:tezapp/dummy_data/category_json.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/ui_elements/custom_image.dart';

class CategoryItem extends StatelessWidget {
  final data;
  const CategoryItem({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: (size.width - 80) / 3,
      height: (size.width - 40) / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: white,
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.06),
            spreadRadius: 5,
            blurRadius: 10,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
              child: Text(
                data["name"],
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 14, color: primary, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: CustomImage(
                data["image"],
                radius: 0,
                width: 75,
                height: 55,
                isShadow: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
