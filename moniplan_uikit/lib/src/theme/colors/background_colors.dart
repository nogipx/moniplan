import 'package:flutter/material.dart';

/// Класс набора цветов для фона в ui kit
class BackgroundColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color elementAct;
  final Color third;

  /// Создаёт приватный класс набора цветов для фона в ui kit
  BackgroundColors._({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.elementAct,
    required this.third,
  });

  /// Набор цветов для [ThemeStyle.dark]
  BackgroundColors.dark()
      : primary = const Color(0xFF252525),
        secondary = const Color(0xFF4E4E4E),
        accent = const Color(0xFFE31C23),
        surface = const Color(0xFFFFFFFF),
        elementAct = const Color(0xFFBBBBBB),
        third = const Color(0xFF787878);

  /// Набор цветов для [ThemeStyle.light]
  BackgroundColors.light()
      : primary = const Color(0xFFFEFEFE),
        secondary = const Color(0xFFE9E9E9),
        accent = const Color(0xFFE31C23),
        surface = const Color(0xFF252525),
        elementAct = const Color(0xFFBBBBBB),
        third = const Color(0xFF787878);

  /// Интерполяция для анимированных переходов между [BackgroundColors]
  BackgroundColors lerp(BackgroundColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return BackgroundColors._(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      accent: Color.lerp(accent, b?.accent, t) ?? Colors.transparent,
      surface: Color.lerp(surface, b?.surface, t) ?? Colors.transparent,
      elementAct: Color.lerp(elementAct, b?.elementAct, t) ?? Colors.transparent,
      third: Color.lerp(third, b?.third, t) ?? Colors.transparent,
    );
  }
}
