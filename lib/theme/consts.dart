import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

import 'package:flutter/material.dart';

abstract class MoniplanShadows {
  static const tinkoffCardShadow = BoxDecoration(
    boxShadow: [
      BoxShadow(
        offset: Offset(0, 5),
        color: Colors.black,
        blurRadius: 20,
      ),
    ],
  );

  static const lightSystemUIOverlay = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarDividerColor: MoniplanColors.navigationBarColor,
    statusBarColor: Color(0x00FFFFFF),
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );

  static const double pageTitleTopPadding = 24;
}
