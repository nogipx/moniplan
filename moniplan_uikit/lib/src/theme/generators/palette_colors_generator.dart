import 'package:flutter/material.dart';
import '../_index.dart';
// Импорт для генерации палитры

/// Функция, генерирующая [PaletteColors] из одного цвета с возможностью добавления разнообразия
PaletteColors generatePaletteColors({
  required Color primary,
  Color? accentColor,
  Color? backgroundColor,
  bool isDarkTheme = false,
  double diversityFactor = 0.3, // Параметр для управления разнообразием цветов
}) {
  // Генерация дополнительных цветов на основе одного основного цвета для лучшей гармонии
  final secondary = _generateComplementaryColor(primary, 0.8, isDarkTheme, diversityFactor);
  final tertiary = _generateSplitComplementaryColor(primary, 30, isDarkTheme, diversityFactor);
  final background =
      backgroundColor ?? _adjustColorBrightness(primary, 0.9, isDarkTheme, diversityFactor);
  final accent =
      accentColor ?? _generateSplitComplementaryColor(primary, -30, isDarkTheme, diversityFactor);

  final ColorPalette palette = ColorPalette.generate(
    primary: primary,
    secondary: secondary,
    tertiary: tertiary,
    background: background,
    isDarkTheme: isDarkTheme,
  );

  return PaletteColors(
    primary: palette.primary,
    secondary: palette.secondary,
    accent: accent, // Используем акцентный цвет
    background: palette.background,
    surface: palette.surface,
    error: Colors.redAccent,
    onPrimary: palette.onPrimary ?? Colors.white,
    onSecondary: palette.onSecondary ?? Colors.white,
    onBackground: palette.onBackground ?? Colors.black,
    onSurface: palette.onSurface ?? Colors.black,
  );
}

Color _generateComplementaryColor(
    Color color, double factor, bool isDarkTheme, double diversityFactor) {
  final hsl = HSLColor.fromColor(color);
  final complementaryHue = (hsl.hue + 180 * diversityFactor) % 360;
  final adjustedSaturation = (hsl.saturation * factor).clamp(0.0, 1.0);
  final adjustedLightness = isDarkTheme ? (hsl.lightness * 0.7) : (hsl.lightness * 1.2);
  return HSLColor.fromAHSL(
          hsl.alpha, complementaryHue, adjustedSaturation, adjustedLightness.clamp(0.0, 1.0))
      .toColor();
}

Color _generateSplitComplementaryColor(
    Color color, double angle, bool isDarkTheme, double diversityFactor) {
  final hsl = HSLColor.fromColor(color);
  final splitComplementaryHue = (hsl.hue + angle * diversityFactor) % 360;
  final adjustedSaturation = (hsl.saturation * 0.9).clamp(0.0, 1.0);
  final adjustedLightness = isDarkTheme ? (hsl.lightness * 0.75) : (hsl.lightness * 1.25);
  return HSLColor.fromAHSL(
          hsl.alpha, splitComplementaryHue, adjustedSaturation, adjustedLightness.clamp(0.0, 1.0))
      .toColor();
}

Color _adjustColorBrightness(Color color, double factor, bool isDarkTheme, double diversityFactor) {
  final hsl = HSLColor.fromColor(color);
  final adjustedLightness = isDarkTheme
      ? (hsl.lightness * (1 - factor * diversityFactor)).clamp(0.0, 1.0)
      : (hsl.lightness * (1 + factor * diversityFactor)).clamp(0.0, 1.0);
  return HSLColor.fromAHSL(hsl.alpha, hsl.hue, hsl.saturation, adjustedLightness).toColor();
}
