import 'package:flutter/material.dart';

/// Класс, представляющий цвета для утилитарных элементов интерфейса
class UtilityColors {
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color surfaceTint;

  /// Создаёт приватный класс набора цветов для утилитарных элементов
  UtilityColors({
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.surfaceTint,
  });

  /// Набор цветов для [Brightness.dark]
  UtilityColors.dark()
      : outline = const Color(0xFFB0BEC5),
        outlineVariant = const Color(0xFF8C9EAF),
        shadow = const Color(0xFF000000),
        scrim = const Color(0xFF121212),
        surfaceTint = const Color(0xFFBB86FC);

  /// Набор цветов для [Brightness.light]
  UtilityColors.light()
      : outline = const Color(0xFF757575),
        outlineVariant = const Color(0xFFB0BEC5),
        shadow = const Color(0xFF000000),
        scrim = const Color(0xFF000000),
        surfaceTint = const Color(0xFF6200EE);

  /// Интерполяция для анимированных переходов между [UtilityColors]
  UtilityColors lerp(UtilityColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return UtilityColors(
      outline: Color.lerp(outline, b?.outline, t) ?? Colors.transparent,
      outlineVariant: Color.lerp(outlineVariant, b?.outlineVariant, t) ?? Colors.transparent,
      shadow: Color.lerp(shadow, b?.shadow, t) ?? Colors.transparent,
      scrim: Color.lerp(scrim, b?.scrim, t) ?? Colors.transparent,
      surfaceTint: Color.lerp(surfaceTint, b?.surfaceTint, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [UtilityColors]
  UtilityColors copyWith({
    Color? outline,
    Color? outlineVariant,
    Color? shadow,
    Color? scrim,
    Color? surfaceTint,
  }) {
    return UtilityColors(
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
      surfaceTint: surfaceTint ?? this.surfaceTint,
    );
  }
}
