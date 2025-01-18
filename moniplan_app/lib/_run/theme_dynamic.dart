// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

typedef MoniplanThemeGeneratorDynamic = Future<AppTheme> Function({
  Brightness? brightness,
  FlexSchemeVariant? variant,
});

Future<AppTheme> moniplanThemeGeneratorDynamic({
  Brightness? brightness,
  FlexSchemeVariant? variant,
}) async {
  final effectiveBrightness =
      brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness;

  return moniplanTheme(
    seedScheme: await _getDynamicScheme(
      effectiveBrightness,
      debug: true,
    ),
    brightness: effectiveBrightness,
    variant: variant ?? FlexSchemeVariant.vivid,
    rainbow: false,
    contrast: 0,
  );
}

AppTheme moniplanThemeGeneratorDynamicSync({
  Brightness? brightness,
  FlexSchemeVariant? variant,
  ColorScheme? dark,
  ColorScheme? light,
}) {
  final effectiveBrightness =
      brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness;

  return moniplanTheme(
    seedScheme: brightness == Brightness.dark ? dark : light,
    brightness: effectiveBrightness,
    variant: variant ?? FlexSchemeVariant.vivid,
    rainbow: false,
    contrast: 0,
  );
}

Future<ColorScheme?> _getDynamicScheme(Brightness brightness, {bool debug = false}) async {
  void trace(String msg) => debug ? debugPrint(msg) : null;

  try {
    final corePalette = await DynamicColorPlugin.getCorePalette();

    if (corePalette != null) {
      trace('dynamic_color: Core palette detected.');
      final scheme = corePalette.toColorScheme(brightness: brightness);
      return scheme;
    }
  } on PlatformException {
    trace('dynamic_color: Failed to obtain core palette.');
  }

  try {
    final Color? accentColor = await DynamicColorPlugin.getAccentColor();

    if (accentColor != null) {
      trace('dynamic_color: Accent color detected.');
      final scheme = ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: brightness,
      );
      return scheme;
    }
  } on PlatformException {
    trace('dynamic_color: Failed to obtain accent color.');
  }

  trace('dynamic_color: Dynamic color not detected on this device.');
  return null;
}
