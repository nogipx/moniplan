import 'package:flutter/material.dart';
import 'package:moniplan_uikit/src/app/_index.dart';

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
      color: AppColorTokens.inactiveTextColor,
      fontWeight: FontWeight.normal,
    ),
    labelStyle: baseTextTheme.bodyMedium?.copyWith(
      color: AppColorTokens.inactiveTextColor,
      fontWeight: FontWeight.normal,
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: AppColorTokens.inactiveTextColor,
      ),
    ),
  ),
);
