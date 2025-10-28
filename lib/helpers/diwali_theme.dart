import 'package:flutter/material.dart';

class DiwaliTheme {
  static const Color primaryColor = Color(0xFFFFC107);
  static const Color accentColor = Color(0xFFE91E63);
  static const Color backgroundColor = Color(0xFFFFF8E1);
  static const Color cardColor = Color(0xFFFFE0B2);

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    hintColor: accentColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(
        color: Colors.black87,
      ),
    ),
  );
}