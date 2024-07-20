import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:moniplan_uikit/src/app/colors.dart';

abstract class MoniplanConst {
  static const tinkoffCardShadow = BoxShadow(
    offset: Offset(0, 5),
    color: Colors.black,
    blurRadius: 20,
  );

  static final lightSystemUIOverlay = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarDividerColor: AppColorTokens.navigationBarColor,
    statusBarColor: const Color(0x00FFFFFF),
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );

  static const double pageTitleTopPadding = 24;

  static const borderRadius50 = BorderRadius.all(Radius.circular(50));
}
