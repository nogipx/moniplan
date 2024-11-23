import 'package:flutter/material.dart';

/// Класс, представляющий цвета текста для интерфейса
class TextColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color disabled;
  final Color hint;
  final Color inverse;
  final Color error;

  /// Создаёт приватный класс набора цветов для текста
  TextColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.disabled,
    required this.hint,
    required this.inverse,
    required this.error,
  });

  /// Набор цветов для [Brightness.dark]
  TextColors.dark()
      : primary = const Color(0xFFFFFFFF),
        secondary = const Color(0xFFB0BEC5),
        accent = const Color(0xFFBB86FC),
        disabled = const Color(0xFF757575),
        hint = const Color(0xFFBDBDBD),
        inverse = const Color(0xFF000000),
        error = const Color(0xFFCF6679);

  /// Набор цветов для [Brightness.light]
  TextColors.light()
      : primary = const Color(0xFF000000),
        secondary = const Color(0xFF757575),
        accent = const Color(0xFF6200EE),
        disabled = const Color(0xFFBDBDBD),
        hint = const Color(0xFF9E9E9E),
        inverse = const Color(0xFFFFFFFF),
        error = const Color(0xFFB00020);

  /// Интерполяция для анимированных переходов между [TextColors]
  TextColors lerp(TextColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return TextColors(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      accent: Color.lerp(accent, b?.accent, t) ?? Colors.transparent,
      disabled: Color.lerp(disabled, b?.disabled, t) ?? Colors.transparent,
      hint: Color.lerp(hint, b?.hint, t) ?? Colors.transparent,
      inverse: Color.lerp(inverse, b?.inverse, t) ?? Colors.transparent,
      error: Color.lerp(error, b?.error, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [TextColors]
  TextColors copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? disabled,
    Color? hint,
    Color? inverse,
    Color? error,
  }) {
    return TextColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      disabled: disabled ?? this.disabled,
      hint: hint ?? this.hint,
      inverse: inverse ?? this.inverse,
      error: error ?? this.error,
    );
  }
}
