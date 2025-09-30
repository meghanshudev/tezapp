import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/pages/Product/product_search_page.dart';

Widget getSearchButton(context, Function onOpenSearch, Function onCloseSearch) {
  return Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: greyLight,
        width: 1.5,
      ),
    ),
    margin: EdgeInsets.all(10),
    child: Row(
      children: [
        Container(
          width: 50,
          child: Center(child: Icon(Icons.search, size: 30, color: greyLight)),
        ),
        Flexible(
          child: TextField(
            onTap: () async {
              onOpenSearch();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductSearchPage()),
              );
              onCloseSearch();
            },
            cursorColor: black,
            readOnly: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "search_for_dal_atta_oil_bread".tr(),
            ),
          ),
        ),
        SizedBox(width: 20),
      ],
    ),
  );
}
