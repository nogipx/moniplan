import 'package:flutter/material.dart';
import '_index.dart';

final lightTheme = ThemeData(
  fontFamily: 'SfProText',
  textTheme: baseTextTheme,
  scaffoldBackgroundColor: Colors.white,
  splashFactory: NoSplash.splashFactory,
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.only(
      bottom: 12,
      top: 30,
    ),
    hintStyle: baseTextTheme.bodyMedium?.copyWith(
      color: MoniplanColors.inactiveTextColor,
      fontWeight: FontWeight.normal,
    ),
    labelStyle: baseTextTheme.bodyMedium?.copyWith(
      color: MoniplanColors.inactiveTextColor,
      fontWeight: FontWeight.normal,
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: MoniplanColors.inactiveTextColor,
      ),
    ),
  ),
);
