import 'package:flutter/material.dart';
import 'package:tezchal/pages/Category/category_page.dart';
import 'package:tezchal/ui_elements/category_item.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class CategorySection extends StatelessWidget {
  final List categories;
  final Mixpanel mixpanel;
  final Function(bool) onLeave;

  const CategorySection({
    Key? key,
    required this.categories,
    required this.mixpanel,
    required this.onLeave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shop by Category",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(categories.length, (index) {
                return GestureDetector(
                  onTap: () async {
                    dynamic dataPanel = {
                      "phone": userSession['phone_number'],
                      "category": categories[index]['name'],
                    };

                    mixpanel.track('CLICK_CATEGORY', properties: dataPanel);

                    onLeave(false);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(
                          data: {
                            "category": categories[index],
                            "allCategories": categories,
                            "isParent": true,
                          },
                        ),
                      ),
                    );
                    onLeave(true);
                  },
                  child: CategoryItem(data: categories[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}