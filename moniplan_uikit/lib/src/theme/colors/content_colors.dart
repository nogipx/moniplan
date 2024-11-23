import 'package:flutter/material.dart';

/// Класс, представляющий цвета для контентных элементов интерфейса
class ContentColors {
  final Color onBackground;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color onInverseSurface;
  final Color onPrimary;
  final Color onSecondary;
  final Color onTertiary;
  final Color onError;

  /// Создаёт приватный класс набора цветов для контентных элементов
  ContentColors({
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onInverseSurface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onTertiary,
    required this.onError,
  });

  /// Набор цветов для [Brightness.dark]
  ContentColors.dark()
      : onBackground = const Color(0xFFFFFFFF),
        onSurface = const Color(0xFFE0E0E0),
        onSurfaceVariant = const Color(0xFFB0B0B0),
        onInverseSurface = const Color(0xFF121212),
        onPrimary = const Color(0xFF000000),
        onSecondary = const Color(0xFF000000),
        onTertiary = const Color(0xFF000000),
        onError = const Color(0xFFFFFFFF);

  /// Набор цветов для [Brightness.light]
  ContentColors.light()
      : onBackground = const Color(0xFF000000),
        onSurface = const Color(0xFF121212),
        onSurfaceVariant = const Color(0xFF2C2C2C),
        onInverseSurface = const Color(0xFFFFFFFF),
        onPrimary = const Color(0xFFFFFFFF),
        onSecondary = const Color(0xFFFFFFFF),
        onTertiary = const Color(0xFFFFFFFF),
        onError = const Color(0xFF000000);

  /// Интерполяция для анимированных переходов между [ContentColors]
  ContentColors lerp(ContentColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return ContentColors(
      onBackground: Color.lerp(onBackground, b?.onBackground, t) ?? Colors.transparent,
      onSurface: Color.lerp(onSurface, b?.onSurface, t) ?? Colors.transparent,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, b?.onSurfaceVariant, t) ?? Colors.transparent,
      onInverseSurface: Color.lerp(onInverseSurface, b?.onInverseSurface, t) ?? Colors.transparent,
      onPrimary: Color.lerp(onPrimary, b?.onPrimary, t) ?? Colors.transparent,
      onSecondary: Color.lerp(onSecondary, b?.onSecondary, t) ?? Colors.transparent,
      onTertiary: Color.lerp(onTertiary, b?.onTertiary, t) ?? Colors.transparent,
      onError: Color.lerp(onError, b?.onError, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [ContentColors]
  ContentColors copyWith({
    Color? onBackground,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? onInverseSurface,
    Color? onPrimary,
    Color? onSecondary,
    Color? onTertiary,
    Color? onError,
  }) {
    return ContentColors(
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onTertiary: onTertiary ?? this.onTertiary,
      onError: onError ?? this.onError,
    );
  }
}
