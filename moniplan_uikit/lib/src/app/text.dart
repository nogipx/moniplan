import 'package:flutter/material.dart';

import 'package:moniplan_uikit/src/app/colors.dart';

final baseTextTheme = TextTheme(
  displayMedium: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'TTFirsText',
    fontSize: 30,
    color: MoniplanColors.primaryTextColor,
  ),
  headlineMedium: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'TTFirsText',
    fontSize: 22,
    color: MoniplanColors.primaryTextColor,
  ),
  titleMedium: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'TTFirsText',
    fontSize: 20,
    color: MoniplanColors.primaryTextColor,
  ),
  bodyMedium: TextStyle(
    // letterSpacing: -0.41,
    fontFamily: 'SfProText',
    fontSize: 17,
    color: MoniplanColors.primaryTextColor,
    fontWeight: FontWeight.normal,
  ),
  labelMedium: TextStyle(
    // letterSpacing: -0.24,
    fontFamily: 'SfProText',
    fontSize: 14,
    color: MoniplanColors.secondaryTextColor,
  ),
);
