import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/pages/Product/product_search_page.dart';

import 'dart:async';

class SearchButton extends StatefulWidget {
  final Function onOpenSearch;
  final Function onCloseSearch;

  const SearchButton({
    Key? key,
    required this.onOpenSearch,
    required this.onCloseSearch,
  }) : super(key: key);

  @override
  _SearchButtonState createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  int _currentIndex = 0;
  final List<String> _searchHints = [
    "search_for_dal_atta_oil_bread",
    "search_for_milk_eggs_cheese",
    "search_for_fresh_vegetables",
    "search_for_tasty_snacks",
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _searchHints.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        widget.onOpenSearch();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductSearchPage()),
        );
        widget.onCloseSearch();
      },
      child: Container(
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
              child:
                  Center(child: Icon(Icons.search, size: 30, color: greyLight)),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final inAnimation = Tween<Offset>(
                    begin: Offset(0, 1),
                    end: Offset(0, 0),
                  ).animate(animation);
                  final outAnimation = Tween<Offset>(
                    begin: Offset(0, -1),
                    end: Offset(0, 0),
                  ).animate(animation);

                  if (child.key == ValueKey<int>(_currentIndex)) {
                    return ClipRect(
                      child: SlideTransition(
                        position: inAnimation,
                        child: child,
                      ),
                    );
                  } else {
                    return ClipRect(
                      child: SlideTransition(
                        position: outAnimation,
                        child: child,
                      ),
                    );
                  }
                },
                child: Text(
                  _searchHints[_currentIndex].tr(),
                  key: ValueKey<int>(_currentIndex),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

Widget getSearchButton(
    BuildContext context, Function onOpenSearch, Function onCloseSearch) {
  return SearchButton(
    onOpenSearch: onOpenSearch,
    onCloseSearch: onCloseSearch,
  );
}
