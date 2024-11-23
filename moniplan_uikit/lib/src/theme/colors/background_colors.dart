import 'package:flutter/material.dart';

/// Класс, представляющий цвета фонов для интерфейса
class BackgroundColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color inverseSurface;

  /// Создаёт приватный класс набора цветов для фонов
  BackgroundColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.inverseSurface,
  });

  /// Набор цветов для [Brightness.dark]
  BackgroundColors.dark()
      : background = const Color(0xFF121212),
        surface = const Color(0xFF1E1E1E),
        surfaceVariant = const Color(0xFF2C2C2C),
        inverseSurface = const Color(0xFFF1F1F1);

  /// Набор цветов для [Brightness.light]
  BackgroundColors.light()
      : background = const Color(0xFFFFFFFF),
        surface = const Color(0xFFF1F1F1),
        surfaceVariant = const Color(0xFFEAEAEA),
        inverseSurface = const Color(0xFF2C2C2C);

  /// Интерполяция для анимированных переходов между [BackgroundColors]
  BackgroundColors lerp(BackgroundColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return BackgroundColors(
      background: Color.lerp(background, b?.background, t) ?? Colors.transparent,
      surface: Color.lerp(surface, b?.surface, t) ?? Colors.transparent,
      surfaceVariant: Color.lerp(surfaceVariant, b?.surfaceVariant, t) ?? Colors.transparent,
      inverseSurface: Color.lerp(inverseSurface, b?.inverseSurface, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [BackgroundColors]
  BackgroundColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? inverseSurface,
  }) {
    return BackgroundColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
    );
  }
}
