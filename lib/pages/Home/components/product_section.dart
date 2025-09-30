import 'package:flutter/material.dart';
import 'package:tezchal/pages/Category/category_page.dart';
import 'package:tezchal/ui_elements/product_item_network.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/pages/Product/product_detail_page.dart';

class ProductSection extends StatelessWidget {
  final int index;
  final String title;
  final String subTitle;
  final List products;
  final List categoryFeatures;
  final Mixpanel mixpanel;
  final Function(bool) onLeave;

  const ProductSection({
    Key? key,
    required this.index,
    required this.title,
    required this.subTitle,
    required this.products,
    required this.categoryFeatures,
    required this.mixpanel,
    required this.onLeave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      subTitle,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        data: {
                          "category": categoryFeatures[index],
                          "allCategories": categoryFeatures,
                          "isParent":
                              !categoryFeatures[index]["is_sub_category"],
                        },
                      ),
                    ),
                  );
                  onLeave(true);
                  dynamic dataPanel = {
                    "phone": userSession['phone_number'],
                    "category": categoryFeatures[index],
                  };
                  mixpanel.track('CLICK_CATEGORY', properties: dataPanel);
                  onLeave(false);
                },
                child: Row(
                  children: [
                    Text("see_more", style: TextStyle(fontSize: 16)).tr(),
                    SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: black,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.only(left: 15),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(products.length, (index) {
              var product = products[index]['product'];
              return Padding(
                padding: const EdgeInsets.only(right: 20, top: 20, bottom: 20),
                child: Card(
                  elevation: 4,
                  child: GestureDetector(
                    onTap: () async {
                      dynamic dataPanel = {
                        "phone": userSession['phone_number'],
                        "product": products[index]['product']['name'],
                      };

                      mixpanel.track('CLICK_PRODUCT', properties: dataPanel);
                      onLeave(false);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            data: {"product": products[index]},
                          ),
                        ),
                      );
                      onLeave(true);
                    },
                    child: ProductItemNetwork(
                      product: product,
                      discountLabel:
                          convertDouble(product['percent_off']).toInt(),
                      kgLabel: product["attributes"].length == 0
                          ? ""
                          : product["attributes"][0]["value"],
                      image: product['image'],
                      name: product['name'],
                      priceStrike: CURRENCY + "${product["unit_price"]}",
                      price: CURRENCY + "${product["sale_price"]}",
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}