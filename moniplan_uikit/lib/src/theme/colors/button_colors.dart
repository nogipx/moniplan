import 'package:flutter/material.dart';

/// Класс, представляющий цвета кнопок для интерфейса
class ButtonColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color disabled;
  final Color pressed;
  final Color hovered;
  final Color overlay;

  /// Создаёт приватный класс набора цветов для кнопок
  ButtonColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.disabled,
    required this.pressed,
    required this.hovered,
    required this.overlay,
  });

  /// Набор цветов для [ThemeStyle.dark]
  ButtonColors.dark()
      : primary = const Color(0xFFBB86FC),
        secondary = const Color(0xFF03DAC6),
        tertiary = const Color(0xFF3700B3),
        disabled = const Color(0xFF757575),
        pressed = const Color(0xFF6200EE),
        hovered = const Color(0xFF1F1F1F),
        overlay = const Color(0xFF6200EE).withOpacity(0.1);

  /// Набор цветов для [ThemeStyle.light]
  ButtonColors.light()
      : primary = const Color(0xFF6200EE),
        secondary = const Color(0xFF018786),
        tertiary = const Color(0xFF03DAC6),
        disabled = const Color(0xFFBDBDBD),
        pressed = const Color(0xFF3700B3),
        hovered = const Color(0xFFF1F1F1),
        overlay = const Color(0xFF6200EE).withOpacity(0.1);

  /// Интерполяция для анимированных переходов между [ButtonColors]
  ButtonColors lerp(ButtonColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return ButtonColors(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      tertiary: Color.lerp(tertiary, b?.tertiary, t) ?? Colors.transparent,
      disabled: Color.lerp(disabled, b?.disabled, t) ?? Colors.transparent,
      pressed: Color.lerp(pressed, b?.pressed, t) ?? Colors.transparent,
      hovered: Color.lerp(hovered, b?.hovered, t) ?? Colors.transparent,
      overlay: Color.lerp(overlay, b?.overlay, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [ButtonColors]
  ButtonColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? disabled,
    Color? pressed,
    Color? hovered,
    Color? overlay,
  }) {
    return ButtonColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      disabled: disabled ?? this.disabled,
      pressed: pressed ?? this.pressed,
      hovered: hovered ?? this.hovered,
      overlay: overlay ?? this.overlay,
    );
  }
}
