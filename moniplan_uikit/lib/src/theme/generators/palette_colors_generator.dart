import 'package:flutter/material.dart';
import '../_index.dart';
// Импорт для генерации палитры

/// Функция, генерирующая [PaletteColors] из одного цвета с учетом оптимального разнообразия для приятного восприятия
PaletteColors generatePaletteColors({
  required Color primary,
  Color? accentColor,
  Color? backgroundColor,
  bool isDarkTheme = false,
  double diversityFactor = 0.4, // Параметр для управления разнообразием цветов
}) {
  // Определение базовых цветов на основе основного цвета
  final primaryAdjusted = _adjustToReadable(primary);
  final background = backgroundColor != null
      ? _adjustToReadable(backgroundColor)
      : _generateBackgroundColor(primaryAdjusted, isDarkTheme, diversityFactor);
  final accent = accentColor != null
      ? _adjustToReadable(accentColor)
      : _generateAccentColor(primaryAdjusted, isDarkTheme, diversityFactor);
  final secondary = _generateHarmoniousColor(primaryAdjusted, diversityFactor, isDarkTheme);
  final surface = _generateSurfaceColor(background, isDarkTheme, diversityFactor);

  return PaletteColors(
    primary: primaryAdjusted,
    secondary: _adjustToReadable(secondary),
    accent: _adjustToReadable(accent),
    background: _adjustToReadable(background),
    surface: _adjustToReadable(surface),
    error: Colors.redAccent,
    onPrimary: _getOnColor(primaryAdjusted),
    onSecondary: _getOnColor(secondary),
    onBackground: _getOnColor(background),
    onSurface: _getOnColor(surface),
  );
}

Color _generateHarmoniousColor(Color color, double diversityFactor, bool isDarkTheme) {
  final hsl = HSLColor.fromColor(color);
  final harmoniousHue = (hsl.hue + 150 * diversityFactor) % 360;
  final adjustedSaturation =
      (hsl.saturation * (isDarkTheme ? 0.8 : 1.2 * diversityFactor)).clamp(0.0, 1.0);
  final adjustedLightness = isDarkTheme
      ? (hsl.lightness * (0.7 + (diversityFactor * 0.3)))
      : (hsl.lightness * (1.1 - (diversityFactor * 0.2)));
  return HSLColor.fromAHSL(
          hsl.alpha, harmoniousHue, adjustedSaturation, adjustedLightness.clamp(0.0, 1.0))
      .toColor();
}

Color _generateAccentColor(Color color, bool isDarkTheme, double diversityFactor) {
  final hsl = HSLColor.fromColor(color);
  final accentHue = (hsl.hue + 45 * diversityFactor) % 360;
  final adjustedSaturation = (hsl.saturation * (1.5 - diversityFactor)).clamp(0.0, 1.0);
  final adjustedLightness = isDarkTheme
      ? (hsl.lightness * (0.6 + diversityFactor * 0.2))
      : (hsl.lightness * (1.3 - diversityFactor * 0.3));
  return HSLColor.fromAHSL(
          hsl.alpha, accentHue, adjustedSaturation, adjustedLightness.clamp(0.0, 1.0))
      .toColor();
}

Color _generateBackgroundColor(Color color, bool isDarkTheme, double diversityFactor) {
  final hsl = HSLColor.fromColor(color);
  final adjustedHue =
      (hsl.hue + 20 * diversityFactor) % 360; // Добавляем разнообразие в цветовой тон для фона
  final adjustedLightness = isDarkTheme
      ? (hsl.lightness * (0.1 + diversityFactor * 0.1))
      : (hsl.lightness * (0.95 - diversityFactor * 0.1));
  return HSLColor.fromAHSL(
          hsl.alpha,
          adjustedHue,
          (hsl.saturation * (0.3 + diversityFactor * 0.1)).clamp(0.0, 1.0),
          adjustedLightness.clamp(0.0, 1.0))
      .toColor();
}

Color _generateAnalogousColor(Color color, double angle, bool isDarkTheme) {
  final hsl = HSLColor.fromColor(color);
  final analogousHue = (hsl.hue + angle) % 360;
  final adjustedSaturation = hsl.saturation;
  final adjustedLightness = isDarkTheme ? (hsl.lightness * 0.8) : (hsl.lightness * 1.1);
  return HSLColor.fromAHSL(
          hsl.alpha, analogousHue, adjustedSaturation, adjustedLightness.clamp(0.0, 1.0))
      .toColor();
}

Color _generateSurfaceColor(Color background, bool isDarkTheme, double diversityFactor) {
  final hsl = HSLColor.fromColor(background);
  final adjustedLightness = isDarkTheme
      ? (hsl.lightness * (1.2 - diversityFactor * 0.2)).clamp(0.0, 1.0)
      : (hsl.lightness * (0.9 + diversityFactor * 0.1)).clamp(0.0, 1.0);
  return HSLColor.fromAHSL(hsl.alpha, hsl.hue, hsl.saturation, adjustedLightness).toColor();
}

Color _getOnColor(Color color) {
  // Простая логика для определения цвета текста на основе яркости
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

Color _adjustToReadable(Color color) {
  // Корректируем цвет для обеспечения хорошей читабельности
  final hsl = HSLColor.fromColor(color);
  final adjustedLightness = hsl.lightness < 0.2 ? 0.2 : (hsl.lightness > 0.8 ? 0.8 : hsl.lightness);
  final adjustedSaturation =
      hsl.saturation < 0.2 ? 0.3 : (hsl.saturation > 0.9 ? 0.9 : hsl.saturation);
  return HSLColor.fromAHSL(hsl.alpha, hsl.hue, adjustedSaturation, adjustedLightness).toColor();
}
