import 'package:flutter/material.dart';
import 'package:tezchal/dummy_data/category_json.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/ui_elements/custom_image.dart';

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
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey[100]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                data["name"],
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600),
              ),
            ),
            // Spacer(),
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
