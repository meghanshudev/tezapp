import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/pages/Authentication/login_page.dart';

import '../../helpers/styles.dart';
import '../../helpers/theme.dart';

class GuestAddToCardButtonItem extends StatefulWidget {
  final product;
  final GestureTapCallback? onTap;
  const GuestAddToCardButtonItem({
    Key? key,
    this.product = const {"quantity": 0},
    this.onTap,
  }) : super(key: key);

  @override
  _GuestAddToCardButtonItemState createState() =>
      _GuestAddToCardButtonItemState();
}

class _GuestAddToCardButtonItemState extends State<GuestAddToCardButtonItem> {
  int productQty = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(height: 40, width: 100),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: AnimatedContainer(
            width: (productQty >= 1) ? 0 : 80,
            height: (productQty >= 1) ? 0 : 35,
            decoration: BoxDecoration(
              border: Border.all(color: greyLight),
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(milliseconds: 200),
            child: Center(child: Text("add", style: meduimPrimaryText).tr()),
          ),
        ),
      ],
    );
  }

  bool isAddingCart = false;
}
