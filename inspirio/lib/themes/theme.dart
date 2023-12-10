import 'package:flutter/material.dart';

ThemeData kAmoledTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background: Color(0xFF000000),
      primary: Colors.grey,
      secondary: Colors.white,
      tertiary: Colors.grey,
    ),
    iconTheme: const IconThemeData(color: Colors.white));

ThemeData kLightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      background: Color(0xFFE6EDFF),
      primary: Color.fromARGB(255, 184, 193, 231),
      secondary: Color(0xFF131321),
      tertiary: Color.fromARGB(255, 184, 193, 231),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF131321),
    ));

ThemeData kColouredTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background: Color(0xFF131321),
      primary: Color(0xFFFE5163),
      secondary: Colors.white,
      tertiary: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white));
