import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

abstract class MoniplanColors {
  MoniplanColors._();

  static final _brightness = ValueNotifier(Brightness.light);
  static get brightnessListenable => _brightness;
  static set brightness(Brightness brightness) {
    _brightness.value = brightness;
  }

  static final white = ColorToken(
    brightness: _brightness,
    light: const Color(0xffffffff),
    dark: const Color(0xff454545),
  );

  static final blueColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xff0C82D8),
  );
  static final lightBlueColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xff58A9E4),
  );

  static final disabledColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xff9299A2),
  );
  static final positiveMoneyColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xff3C8900),
  );
  static final negativeMoneyColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xffDF0000),
  );
  static final darkBackgroundColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xff5b5a5a),
  );

  static final primaryTextColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xff454545),
  );
  static final secondaryTextColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xff9299A2),
  );
  static final inactiveBackgroundColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xffF4F4F4),
  );
  static final inactiveTextColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xffC7C9CC),
  );
  static final navigationBarColor = ColorToken(
    brightness: _brightness,
    light: const Color(0xffC7C9CC),
  );
}
