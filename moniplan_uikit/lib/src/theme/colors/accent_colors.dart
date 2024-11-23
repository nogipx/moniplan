import 'package:flutter/material.dart';

/// Класс, представляющий цвета для акцентных элементов интерфейса
class AccentColors {
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color tertiary;
  final Color tertiaryContainer;

  /// Создаёт приватный класс набора акцентных цветов
  AccentColors({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
  });

  /// Набор акцентных цветов для [Brightness.dark]
  AccentColors.dark()
      : primary = const Color(0xFFBB86FC),
        primaryContainer = const Color(0xFF3700B3),
        secondary = const Color(0xFF03DAC6),
        secondaryContainer = const Color(0xFF018786),
        tertiary = const Color(0xFFCF6679),
        tertiaryContainer = const Color(0xFFB00020);

  /// Набор акцентных цветов для [Brightness.light]
  AccentColors.light()
      : primary = const Color(0xFF6200EE),
        primaryContainer = const Color(0xFFBB86FC),
        secondary = const Color(0xFF03DAC6),
        secondaryContainer = const Color(0xFF018786),
        tertiary = const Color(0xFFB00020),
        tertiaryContainer = const Color(0xFFCF6679);

  /// Интерполяция для анимированных переходов между [AccentColors]
  AccentColors lerp(AccentColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AccentColors(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      primaryContainer: Color.lerp(primaryContainer, b?.primaryContainer, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      secondaryContainer:
          Color.lerp(secondaryContainer, b?.secondaryContainer, t) ?? Colors.transparent,
      tertiary: Color.lerp(tertiary, b?.tertiary, t) ?? Colors.transparent,
      tertiaryContainer:
          Color.lerp(tertiaryContainer, b?.tertiaryContainer, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [AccentColors]
  AccentColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? tertiary,
    Color? tertiaryContainer,
  }) {
    return AccentColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
    );
  }
}
