import 'package:flutter/material.dart';

class ColorPalette {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color? onPrimary;
  final Color? onSecondary;
  final Color? onTertiary;
  final Color? onBackground;
  final Color? onSurface;

  ColorPalette({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    this.onPrimary,
    this.onSecondary,
    this.onTertiary,
    this.onBackground,
    this.onSurface,
  });

  static ColorPalette generate({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Color? background,
    bool isDarkTheme = false,
  }) {
    // Конвертируем цвета в формат HSL для удобной работы
    final primaryHsl = HSLColor.fromColor(primary);

    // Генерация гармоничной палитры на основе цветовой теории (например, триадная палитра)
    final generatedSecondary = secondary ?? _getTriadicColor(primaryHsl, 120, isDarkTheme);
    final generatedTertiary = tertiary ?? _getTriadicColor(primaryHsl, -120, isDarkTheme);
    final generatedBackground =
        background ?? (isDarkTheme ? _darkenColor(primary, 0.8) : _lightenColor(primary, 0.9));
    final generatedSurface = isDarkTheme
        ? _darkenColor(generatedBackground, 0.2)
        : _lightenColor(generatedBackground, 0.1);

    return ColorPalette(
      primary: primary,
      secondary: generatedSecondary,
      tertiary: generatedTertiary,
      background: generatedBackground,
      surface: generatedSurface,
      onPrimary: _getOnColor(primary),
      onSecondary: _getOnColor(generatedSecondary),
      onTertiary: _getOnColor(generatedTertiary),
      onBackground: _getOnColor(generatedBackground),
      onSurface: _getOnColor(generatedSurface),
    );
  }

  static Color _getOnColor(Color color) {
    // Простая логика для определения цвета текста на основе яркости
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  static Color _getTriadicColor(HSLColor hslColor, double angle, bool isDarkTheme) {
    // Используем триадную цветовую схему для генерации гармоничных цветов
    final newHue = (hslColor.hue + angle) % 360;
    final adjustedLightness = isDarkTheme ? (hslColor.lightness * 0.7) : (hslColor.lightness * 1.3);
    final triadicColor = HSLColor.fromAHSL(
      hslColor.alpha,
      newHue,
      hslColor.saturation,
      adjustedLightness.clamp(0.0, 1.0),
    );
    return triadicColor.toColor();
  }

  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkenedHsl = HSLColor.fromAHSL(
      hsl.alpha,
      hsl.hue,
      hsl.saturation,
      (hsl.lightness * (1 - amount)).clamp(0.0, 1.0),
    );
    return darkenedHsl.toColor();
  }

  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightenedHsl = HSLColor.fromAHSL(
      hsl.alpha,
      hsl.hue,
      hsl.saturation,
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightenedHsl.toColor();
  }
}
