import 'dart:async';

import 'package:moniplan_uikit/src/theme/_index.dart';

abstract interface class IThemeChangerStorage {
  Future<void> persistBrightness(ThemeBrightness brightness);

  Future<ThemeBrightness> getSavedBrightness();
}
