import 'package:flutter/material.dart';
import 'package:tezchal/helpers/theme.dart';
class LoadingData extends StatelessWidget {
  final Color color;
  final double size;
  LoadingData({
    this.color = primary,
    this.size = 30
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: new CircularProgressIndicator(
          strokeWidth: 3.0,
          valueColor: new AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
