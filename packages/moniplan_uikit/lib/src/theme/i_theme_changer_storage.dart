import 'dart:async';

import '_index.dart';

abstract interface class IThemeChangerStorage {
  Future<void> persistBrightness(ThemeBrightness brightness);

  Future<ThemeBrightness> getSavedBrightness();
}
