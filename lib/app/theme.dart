import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppTheme {
  AppTheme._();

  static const blueColor = Color(0xff0C82D8);
  static const lightBlueColor = Color(0xff58A9E4);

  static const disabledColor = Color(0xff9299A2);
  static const positiveMoneyColor = Color(0xff3C8900);
  static const negativeMoneyColor = Color(0xffDF0000);

  static const primaryTextColor = Color(0xff333333);
  static const secondaryTextColor = Color(0xff9299A2);
  static const inactiveBackgroundColor = Color(0xffF4F4F4);
  static const inactiveTextColor = Color(0xffC7C9CC);
}

const tinkoffColor = Color(0xffFFDD2D);
const secondaryColor = Color(0xfff7f7f7);
const closeColor = Color(0xffF52222);
const darkBlueColor = Color(0xff1B79F2);
const lightBlueColor = Color(0xff428BF9);
const primaryTextColor = Color(0xff333333);
const secondaryTextColor = Color(0xff9299A2);
const inactiveTextColor = Color(0xffC7C9CC);
const lightInactiveColor = Color(0xffDBDBDB);
const darkInactiveColor = Color(0xffC4C4C4);
const splashColor = Color(0xff127847);
const inactiveColor = Color(0xffC1C1C1);
const navigationBarColor = Color(0xffF6F7F8);

const lightSystemUIOverlay = SystemUiOverlayStyle(
  systemNavigationBarColor: navigationBarColor,
  systemNavigationBarDividerColor: navigationBarColor,
  statusBarColor: Color(0x00FFFFFF),
  statusBarBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarIconBrightness: Brightness.dark,
);

const baseTextTheme = TextTheme(
  headline5: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'SfProDisplay',
    fontSize: 30,
    color: primaryTextColor,
  ),
  headline6: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'SfProDisplay',
    fontSize: 22,
    color: primaryTextColor,
  ),
  subtitle1: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'SfProDisplay',
    fontSize: 20,
    color: primaryTextColor,
  ),
  subtitle2: TextStyle(
    fontWeight: FontWeight.bold,
    // letterSpacing: 0.38,
    fontFamily: 'SfProDisplay',
    fontSize: 20,
    color: primaryTextColor,
  ),
  bodyText1: TextStyle(
    // letterSpacing: -0.41,
    fontFamily: 'SfProText',
    fontSize: 17,
    color: primaryTextColor,
    fontWeight: FontWeight.normal,
  ),
  bodyText2: TextStyle(
    // letterSpacing: -0.41,
    fontFamily: 'SfProText',
    fontSize: 17,
    color: primaryTextColor,
    fontWeight: FontWeight.normal,
  ),
  caption: TextStyle(
    // letterSpacing: -0.24,
    fontFamily: 'SfProText',
    fontSize: 14,
    color: secondaryTextColor,
  ),
);

final lightTheme = ThemeData(
  fontFamily: 'SfProText',
  textTheme: baseTextTheme,
  scaffoldBackgroundColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.only(
      bottom: 12,
      top: 30,
    ),
    hintStyle: baseTextTheme.bodyText1?.copyWith(
      color: lightInactiveColor,
      fontWeight: FontWeight.normal,
    ),
    labelStyle: baseTextTheme.bodyText1?.copyWith(
      color: lightInactiveColor,
      fontWeight: FontWeight.normal,
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: lightInactiveColor,
      ),
    ),
  ),
);

final tinkoffCardShadow = BoxDecoration(
  boxShadow: [
    BoxShadow(
      offset: Offset(0, 5),
      color: Colors.black.withOpacity(.1),
      blurRadius: 20,
    )
  ],
);

final bottomSheetRadius = BorderRadius.only(
  topLeft: Radius.circular(20),
  topRight: Radius.circular(20),
);

const double pageTitleTopPadding = 24;
