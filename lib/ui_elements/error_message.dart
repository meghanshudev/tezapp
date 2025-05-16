import 'package:flutter/material.dart';
import 'package:tezapp/helpers/theme.dart';

class ErrorMessage extends StatelessWidget {
  final bool isError;
  final String? message;
  
  const ErrorMessage({
    Key? key, 
    required this.isError,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isError 
      ? Padding(
          padding: const EdgeInsets.only(top: 15, left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              message!,
              style: TextStyle(color: primary),
            ),
          ),
        ) 
      : SizedBox();
  }
}