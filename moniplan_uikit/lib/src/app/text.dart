import 'package:flutter/material.dart';

import 'package:moniplan_uikit/src/app/colors.dart';

final baseTextTheme = TextTheme(
  displayMedium: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'TTFirsText',
    fontSize: 30,
    color: AppColorTokens.primaryTextColor,
  ),
  headlineMedium: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'TTFirsText',
    fontSize: 22,
    color: AppColorTokens.primaryTextColor,
  ),
  titleMedium: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'TTFirsText',
    fontSize: 20,
    color: AppColorTokens.primaryTextColor,
  ),
  bodyMedium: TextStyle(
    // letterSpacing: -0.41,
    fontFamily: 'SfProText',
    fontSize: 17,
    color: AppColorTokens.primaryTextColor,
    fontWeight: FontWeight.normal,
  ),
  labelMedium: TextStyle(
    // letterSpacing: -0.24,
    fontFamily: 'SfProText',
    fontSize: 14,
    color: AppColorTokens.secondaryTextColor,
  ),
);
