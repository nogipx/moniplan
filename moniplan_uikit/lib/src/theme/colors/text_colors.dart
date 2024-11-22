import 'package:flutter/material.dart';

/// Класс набора цветов для текста в ui kit
class TextColors {
  final Color primary;
  final Color secondary;
  final Color black;
  final Color error;
  final Color success;
  final Color red;
  final Color yellow;

  /// Создаёт приватный класс набора цветов для текста в ui kit
  TextColors._({
    required this.primary,
    required this.secondary,
    required this.black,
    required this.error,
    required this.success,
    required this.red,
    required this.yellow,
  });

  /// Набор цветов для [ThemeStyle.dark]
  TextColors.dark()
      : primary = const Color(0xFFF8F8F8),
        secondary = const Color(0xFF9F9F9F),
        black = const Color(0xFF252525),
        error = const Color(0xFFE31C23),
        success = const Color(0xFF6FBB63),
        red = const Color(0xFFC75256),
        yellow = const Color(0xFFE4B305);

  /// Набор цветов для [ThemeStyle.light]
  TextColors.light()
      : primary = const Color(0xFF222222),
        secondary = const Color(0xFF9F9F9F),
        black = const Color(0xFF222222),
        error = const Color(0xFFE31C23),
        success = const Color(0xFF6FBB63),
        red = const Color(0xFFC75256),
        yellow = const Color(0xFFE4B305);

  /// Интерполяция для анимированных переходов между [TextColors]
  TextColors lerp(TextColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return TextColors._(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      black: Color.lerp(black, b?.black, t) ?? Colors.transparent,
      error: Color.lerp(error, b?.error, t) ?? Colors.transparent,
      success: Color.lerp(success, b?.success, t) ?? Colors.transparent,
      red: Color.lerp(red, b?.red, t) ?? Colors.transparent,
      yellow: Color.lerp(yellow, b?.yellow, t) ?? Colors.transparent,
    );
  }
}
