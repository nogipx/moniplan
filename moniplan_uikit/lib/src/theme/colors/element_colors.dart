import 'package:flutter/material.dart';

/// Класс, представляющий цвета для различных элементов интерфейса
class ElementColors {
  final Color background;
  final Color card;
  final Color modal;
  final Color border;
  final Color shadow;
  final Color divider;
  final Color highlight;

  /// Создаёт приватный класс набора цветов для элементов
  ElementColors({
    required this.background,
    required this.card,
    required this.modal,
    required this.border,
    required this.shadow,
    required this.divider,
    required this.highlight,
  });

  /// Набор цветов для [ThemeStyle.dark]
  ElementColors.dark()
      : background = const Color(0xFF121212),
        card = const Color(0xFF1E1E1E),
        modal = const Color(0xFF2C2C2C),
        border = const Color(0xFF4F4F4F),
        shadow = const Color(0xFF000000).withOpacity(0.7),
        divider = const Color(0xFF373737),
        highlight = const Color(0xFF424242);

  /// Набор цветов для [ThemeStyle.light]
  ElementColors.light()
      : background = const Color(0xFFFFFFFF),
        card = const Color(0xFFF1F1F1),
        modal = const Color(0xFFEAEAEA),
        border = const Color(0xFFD3D3D3),
        shadow = const Color(0xFF000000).withOpacity(0.1),
        divider = const Color(0xFFE0E0E0),
        highlight = const Color(0xFFF5F5F5);

  /// Интерполяция для анимированных переходов между [ElementColors]
  ElementColors lerp(ElementColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return ElementColors(
      background: Color.lerp(background, b?.background, t) ?? Colors.transparent,
      card: Color.lerp(card, b?.card, t) ?? Colors.transparent,
      modal: Color.lerp(modal, b?.modal, t) ?? Colors.transparent,
      border: Color.lerp(border, b?.border, t) ?? Colors.transparent,
      shadow: Color.lerp(shadow, b?.shadow, t) ?? Colors.transparent,
      divider: Color.lerp(divider, b?.divider, t) ?? Colors.transparent,
      highlight: Color.lerp(highlight, b?.highlight, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [ElementColors]
  ElementColors copyWith({
    Color? background,
    Color? card,
    Color? modal,
    Color? border,
    Color? shadow,
    Color? divider,
    Color? highlight,
  }) {
    return ElementColors(
      background: background ?? this.background,
      card: card ?? this.card,
      modal: modal ?? this.modal,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      divider: divider ?? this.divider,
      highlight: highlight ?? this.highlight,
    );
  }
}
