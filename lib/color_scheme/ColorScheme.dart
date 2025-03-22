import 'package:flutter/material.dart';

final ThemeData mainTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xfff26724),
  colorScheme: ColorScheme.light(
    primary: Color(0xfff26724),
    secondary: Color(0xfff1d1934),
    tertiary: Color(0xfffffffff),
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 25, color: Color(0xfff26724), fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
    titleMedium: TextStyle(fontSize: 20, color: Color(0xfffffffff), fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
    titleSmall: TextStyle(fontSize: 14, color: Color(0xfff26724), fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
    labelMedium: TextStyle(fontSize: 14, color: Color(0xfffffffff), fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
    bodyLarge: TextStyle(fontSize: 18, color: Color(0xfff1d1934), fontFamily: 'Roboto'),
    bodyMedium: TextStyle(fontSize: 16, color: Color(0xfff1d1934), fontFamily: 'Roboto'),
    bodySmall: TextStyle(fontSize: 14, color: Color(0xfff1d1934), fontFamily: 'Roboto'),
  ),
);
