import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';

class CustomCircularProgress extends StatelessWidget {
  const CustomCircularProgress(
      {Key? key, this.color = primary, this.strokeWidth = 2})
      : super(key: key);
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CircularProgressIndicator(
        color: color,
        
        strokeWidth: strokeWidth,
      ),
    );
  }
}
