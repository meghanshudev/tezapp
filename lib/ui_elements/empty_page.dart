import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';

class EmptyPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const EmptyPage({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200 / 2),
            ),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(color: white, shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  child: Image.asset(image),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
        Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: black.withOpacity(0.5),
              ),
            ).tr(),
            SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(color: black.withOpacity(0.5)),
            ).tr(),
            SizedBox(height: 10),
          ],
        ),
      ],
    );
  }
}