import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

typedef MoniplanThemeGeneratorRainbow = AppTheme Function({
  Brightness? brightness,
  int? rainbowSeed,
  Color? rainbowColor,
});

/// ### Logical Behavior Description
///
/// - **Seed Provided: Yes**
///   - **Color Provided: Yes** — Uses the provided color.
///   - **Color Provided: No** — Uses the provided seed to generate a color.
///
/// - **Seed Provided: No**
///   - **Color Provided: Yes** — Uses the provided color.
///   - **Color Provided: No** — Generates a random color.
AppTheme moniplanThemeGeneratorRainbow({
  Brightness? brightness,
  int? rainbowSeed,
  Color? rainbowColor,
}) {
  final effectiveBrightness =
      brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness;

  return moniplanTheme(
    brightness: effectiveBrightness,
    rainbow: true,
    rainbowColor: rainbowColor,
    rainbowSeed: rainbowSeed,
    contrast: 0,
  );
}
