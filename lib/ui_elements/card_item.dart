import 'package:flutter/material.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';

class CardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final GestureTapCallback? onTap;

  const CardItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width,
        height: 70,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: white,
            boxShadow: [
              BoxShadow(
                  color: black.withOpacity(0.06),
                  spreadRadius: 5,
                  blurRadius: 10)
            ]),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: primary.withOpacity(0.6),
                    size: 30,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: normalBlackText,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        subTitle,
                        style: smallBlackText,
                      )
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: primary,
                  size: 18,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
