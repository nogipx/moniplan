import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

const moniplanThemeRandomRainbow = -1;

typedef MoniplanThemeGenerator = Future<AppTheme> Function({
  Brightness? brightness,
  FlexSchemeVariant? variant,
  int? rainbowSeed,
  Color? rainbowColor,
});

/// Provides a dynamically generated Moniplan theme.
///
/// This function generates an [AppTheme] based on the provided parameters and
/// the current platform settings. It supports dynamic color schemes, customizable
/// brightness, and optional rainbow effects.
///
/// Parameters:
/// - [variant]: The color scheme variant to use. Defaults to [FlexSchemeVariant.vivid].
/// - [rainbowSeed]: An optional seed value for generating a rainbow-themed color scheme.
///   If provided and greater than 0, it will enable the rainbow theme.
/// - [brightness]: The desired brightness (light or dark). If not provided, the
///   current platform brightness is used.
///
/// Returns:
/// A [Future<AppTheme>] that resolves to the generated theme.
Future<AppTheme> moniplanThemeGeneratorDynamic({
  Brightness? brightness,
  FlexSchemeVariant? variant,
  int? rainbowSeed,
  Color? rainbowColor,
}) async {
  // Determine the effective brightness. If not specified, use the platform brightness.
  final effectiveBrightness =
      brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness;

  // Generate and return the Moniplan theme based on the provided settings.
  return moniplanTheme(
    seedScheme: await _getDynamicScheme(
      effectiveBrightness,
    ), // Fetch a dynamic color scheme.
    brightness: effectiveBrightness, // Apply the specified brightness.
    variant: variant ?? FlexSchemeVariant.vivid, // Default to the 'vivid' color scheme.
    monochrome: false, // Disable monochrome styling.
    expressive: true, // Enable expressive styling.
    rainbowColor: rainbowColor,
    rainbow: rainbowSeed != null, // Enable rainbow mode if a seed is provided.
    rainbowSeed: rainbowSeed != null && rainbowSeed > 0
        ? rainbowSeed
        : null, // Apply the rainbow seed if valid.
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
