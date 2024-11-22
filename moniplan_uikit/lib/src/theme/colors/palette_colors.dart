import 'package:flutter/material.dart';

/// Класс, представляющий основные цвета темы интерфейса
class PaletteColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSurface;
  final Color onBackground;

  /// Создаёт приватный класс набора цветов для темы
  PaletteColors._({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSurface,
    required this.onBackground,
  });

  /// Набор цветов для [ThemeStyle.dark]
  PaletteColors.dark()
      : primary = const Color(0xFFBB86FC),
        secondary = const Color(0xFF03DAC6),
        accent = const Color(0xFF3700B3),
        background = const Color(0xFF121212),
        surface = const Color(0xFF1E1E1E),
        error = const Color(0xFFCF6679),
        onPrimary = const Color(0xFFFFFFFF),
        onSecondary = const Color(0xFF000000),
        onSurface = const Color(0xFFFFFFFF),
        onBackground = const Color(0xFFFFFFFF);

  /// Набор цветов для [ThemeStyle.light]
  PaletteColors.light()
      : primary = const Color(0xFF6200EE),
        secondary = const Color(0xFF018786),
        accent = const Color(0xFF03DAC6),
        background = const Color(0xFFFFFFFF),
        surface = const Color(0xFFF1F1F1),
        error = const Color(0xFFB00020),
        onPrimary = const Color(0xFFFFFFFF),
        onSecondary = const Color(0xFFFFFFFF),
        onSurface = const Color(0xFF000000),
        onBackground = const Color(0xFF000000);

  /// Интерполяция для анимированных переходов между [PaletteColors]
  PaletteColors lerp(PaletteColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return PaletteColors._(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      accent: Color.lerp(accent, b?.accent, t) ?? Colors.transparent,
      background: Color.lerp(background, b?.background, t) ?? Colors.transparent,
      surface: Color.lerp(surface, b?.surface, t) ?? Colors.transparent,
      error: Color.lerp(error, b?.error, t) ?? Colors.transparent,
      onPrimary: Color.lerp(onPrimary, b?.onPrimary, t) ?? Colors.transparent,
      onSecondary: Color.lerp(onSecondary, b?.onSecondary, t) ?? Colors.transparent,
      onSurface: Color.lerp(onSurface, b?.onSurface, t) ?? Colors.transparent,
      onBackground: Color.lerp(onBackground, b?.onBackground, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [PaletteColors]
  PaletteColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? error,
    Color? onPrimary,
    Color? onSecondary,
    Color? onSurface,
    Color? onBackground,
  }) {
    return PaletteColors._(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onSurface: onSurface ?? this.onSurface,
      onBackground: onBackground ?? this.onBackground,
    );
  }
}
