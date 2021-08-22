import 'package:flutter/material.dart';

const primaryTextColor = Color(0xff333333);
const secondaryTextColor = Color(0xff9299A2);
const inactiveTextColor = Color(0xffC7C9CC);

final lightTheme = ThemeData.light().copyWith(
  textTheme: const TextTheme(
    caption: TextStyle(
      fontSize: 11,
      color: secondaryTextColor,
    ),
  ),
);
