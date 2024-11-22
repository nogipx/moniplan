import 'package:flutter/material.dart';

/// Класс набора цветов для элементов в ui kit
class ElementColors {
  final Color primary;
  final Color secondary;
  final Color third;
  final Color accent;
  final Color red;
  final Color yellow;
  final Color green;
  final Color pressed;
  final Color highlight;
  final Color blue;
  final Color scarlet;

  /// Создаёт приватный класс набора цветов для элементов в ui kit
  ElementColors._({
    required this.primary,
    required this.secondary,
    required this.third,
    required this.accent,
    required this.red,
    required this.yellow,
    required this.green,
    required this.pressed,
    required this.highlight,
    required this.blue,
    required this.scarlet,
  });

  /// Набор цветов для [ThemeStyle.dark]
  ElementColors.dark()
      : primary = const Color(0xFF4E4E4E),
        secondary = const Color(0xFF787878),
        third = const Color(0xFFF8F8F8),
        accent = const Color(0xFFE31C23),
        red = const Color(0xFFC75256),
        yellow = const Color(0xFFE4B305),
        green = const Color(0xFF6FBB63),
        pressed = const Color(0xFFC51117),
        highlight = const Color(0xff09372E),
        blue = const Color(0xFF0986F9),
        scarlet = const Color(0xFFE31E60);

  /// Набор цветов для [ThemeStyle.light]
  ElementColors.light()
      : primary = const Color(0xFF4E4E4E),
        secondary = const Color(0xFF787878),
        third = const Color(0xFFFFFFFF),
        accent = const Color(0xFFE31C23),
        red = const Color(0xFFF59094),
        yellow = const Color(0xFFE4B305),
        green = const Color(0xFFAAF09F),
        pressed = const Color(0xFFC51117),
        highlight = const Color(0xFF43CBCB),
        blue = const Color(0xFF0986F9),
        scarlet = const Color(0xFFE31E60);

  /// Интерполяция для анимированных переходов между [ElementColors]
  ElementColors lerp(ElementColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return ElementColors._(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      third: Color.lerp(third, b?.third, t) ?? Colors.transparent,
      accent: Color.lerp(accent, b?.accent, t) ?? Colors.transparent,
      red: Color.lerp(red, b?.red, t) ?? Colors.transparent,
      yellow: Color.lerp(yellow, b?.yellow, t) ?? Colors.transparent,
      green: Color.lerp(green, b?.green, t) ?? Colors.transparent,
      pressed: Color.lerp(pressed, b?.pressed, t) ?? Colors.transparent,
      highlight: Color.lerp(highlight, b?.highlight, t) ?? Colors.transparent,
      blue: Color.lerp(blue, b?.blue, t) ?? Colors.transparent,
      scarlet: Color.lerp(scarlet, b?.scarlet, t) ?? Colors.transparent,
    );
  }
}
