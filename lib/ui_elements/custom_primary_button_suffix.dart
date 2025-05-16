import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';

class CustomPrimaryButtonSuffixIcon extends StatelessWidget {
  final String text;
   final bool isLoading;
  const CustomPrimaryButtonSuffixIcon({Key? key, required this.text,this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 50,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isLoading ?  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: white,
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ) :
      Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Opacity(
              opacity: 0,
              child: Icon(Ionicons.md_arrow_back) ,
            ),
            Text(
              text,
              style: normalWhiteText,
            ),
           Icon(
                  Icons.arrow_forward_ios,
                  color: white,
                  size: 18,
                )
          ],
        ),
      ),
    );
  }
}
