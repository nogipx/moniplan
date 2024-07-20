import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

abstract interface class AppColors {
  static const moniplanBrand = Color(0xff0C82D8);
  static const paynesGray = Color(0xff4F5D75);
  static const eerieBlack = Color(0xff1E1B18);
  static const night = Color(0xff12130F);
  static const platinum = Color(0xffEAE6E5);
  static const jet = Color(0xff333333);
  static const antiFlashWhite = Color(0xffEFF1F3);
}

abstract interface class AppColorTokens {
  static final _brightness = ValueNotifier<Brightness>(Brightness.light);
  static final _token = colorTokenFactory(_brightness);

  static get brightnessListenable => _brightness;
  static set brightness(Brightness brightness) {
    _brightness.value = brightness;
  }

  static final white = _token(
    light: AppColors.platinum,
    dark: AppColors.jet,
    // dark: const Color(0xff454545),
  );

  static final brandColor = _token(
    light: AppColors.moniplanBrand,
    lightExtra: {
      ColorExtra.foreground: AppColors.platinum,
    },
    dark: AppColors.moniplanBrand,
    darkExtra: {
      ColorExtra.foreground: AppColors.platinum,
    },
  );
  static final lightBrandColor = _token(
    light: const Color(0xff58A9E4),
  );

  static final orangeColor = _token(
    light: const Color(0xffD9860D),
  );
  static final lightOrangeColor = _token(
    light: const Color(0xffE3AB59),
  );

  static final disabledColor = _token(
    light: const Color(0xff9299A2),
  );
  static final positiveMoneyColor = _token(
    light: const Color(0xff3C8900),
  );
  static final negativeMoneyColor = _token(
    light: const Color(0xffDF0000),
  );
  static final darkBackgroundColor = _token(
    light: const Color(0xff5b5a5a),
  );

  static final daySeparatorBackground = _token(
    light: AppColors.eerieBlack,
    lightExtra: {
      ColorExtra.foreground: AppColors.platinum,
    },
    dark: AppColors.platinum,
    darkExtra: {
      ColorExtra.foreground: AppColors.eerieBlack,
    },
  );

  static final primaryTextColor = _token(
    light: const Color(0xff454545),
    dark: const Color(0xffffffff),
  );
  static final secondaryTextColor = _token(
    light: const Color(0xff9299A2),
  );
  static final inactiveBackgroundColor = _token(
    light: const Color(0xffF4F4F4),
  );
  static final inactiveTextColor = _token(
    light: const Color(0xffC7C9CC),
  );
  static final navigationBarColor = _token(
    light: const Color(0xffC7C9CC),
  );
}
