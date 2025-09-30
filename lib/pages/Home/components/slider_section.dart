import 'package:flutter/material.dart';
import 'package:tezchal/ui_elements/slider_widget.dart';

class SliderSection extends StatelessWidget {
  final List ads;

  const SliderSection({
    Key? key,
    required this.ads,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: SliderWidget(items: ads),
    );
  }
}