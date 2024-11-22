import 'package:flutter/material.dart';

/// Класс набора цветов для кнопок в ui kit
class ButtonColors {
  final Color red;
  final Color green;
  final Color primary;
  final Color secondary;
  final Color third;
  final Color overlay;
  final Color pressed;
  final Color disabled;
  final Color overlayBlack;
  final Color pressedBlack;

  /// Создаёт приватный класс набора цветов для кнопок в ui kit
  ButtonColors._({
    required this.red,
    required this.green,
    required this.primary,
    required this.secondary,
    required this.third,
    required this.overlay,
    required this.pressed,
    required this.disabled,
    required this.overlayBlack,
    required this.pressedBlack,
  });

  /// Набор цветов для [ThemeStyle.dark]
  ButtonColors.dark()
      : red = const Color(0xFFE31C23),
        green = const Color(0xFF6FBB63),
        primary = const Color(0xFF4E4E4E),
        secondary = const Color(0xFF787878),
        third = const Color(0xFFF8F8F8),
        overlay = const Color(0xFFB4080E).withOpacity(0.5),
        pressed = const Color(0xFFB4080E).withOpacity(0.7),
        disabled = const Color(0xFFBDBDBD),
        overlayBlack = const Color(0xFF292828).withOpacity(0.5),
        pressedBlack = const Color(0xFF292828).withOpacity(0.7);

  /// Набор цветов для [ThemeStyle.light]
  ButtonColors.light()
      : red = const Color(0xFFE31C23),
        green = const Color(0xFFFFFFFF),
        primary = const Color(0xFFFFFFFF),
        secondary = const Color(0xFFFFFFFF),
        third = const Color(0xFFFFFFFF),
        overlay = const Color(0xFFB4080E).withOpacity(0.5),
        pressed = const Color(0xFFFFFFFF),
        disabled = const Color(0xFFBDBDBD),
        overlayBlack = const Color(0xFF2F2E2E).withOpacity(0.5),
        pressedBlack = const Color(0xFF2F2E2E).withOpacity(0.7);

  /// Интерполяция для анимированных переходов между [ButtonColors]
  ButtonColors lerp(ButtonColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return ButtonColors._(
      red: Color.lerp(red, b?.red, t) ?? Colors.transparent,
      green: Color.lerp(green, b?.green, t) ?? Colors.transparent,
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      third: Color.lerp(third, b?.third, t) ?? Colors.transparent,
      overlay: Color.lerp(overlay, b?.overlay, t) ?? Colors.transparent,
      pressed: Color.lerp(pressed, b?.pressed, t) ?? Colors.transparent,
      disabled: Color.lerp(disabled, b?.disabled, t) ?? Colors.transparent,
      overlayBlack: Color.lerp(overlayBlack, b?.overlayBlack, t) ?? Colors.transparent,
      pressedBlack: Color.lerp(pressedBlack, b?.pressedBlack, t) ?? Colors.transparent,
    );
  }
}
