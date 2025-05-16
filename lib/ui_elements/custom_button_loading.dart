import 'package:flutter/material.dart';
import 'package:tezapp/helpers/theme.dart';

class CustomButtonLoading extends StatelessWidget {
  final Color? color;

  const CustomButtonLoading({ Key? key, this.color = white }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2,
                  ),
                ),
    );
  }
}