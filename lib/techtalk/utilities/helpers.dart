import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 57, 57, 57),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 51, 51, 51),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.green.shade400,
    ),
  );
}
