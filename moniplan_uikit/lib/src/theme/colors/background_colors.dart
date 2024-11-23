import 'package:flutter/material.dart';

/// Класс, представляющий цвета фонов для интерфейса
class BackgroundColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color appBar;
  final Color drawer;
  final Color bottomNav;

  /// Создаёт приватный класс набора цветов для фонов
  BackgroundColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.appBar,
    required this.drawer,
    required this.bottomNav,
  });

  /// Набор цветов для [Brightness.dark]
  BackgroundColors.dark()
      : primary = const Color(0xFF121212),
        secondary = const Color(0xFF1E1E1E),
        tertiary = const Color(0xFF2C2C2C),
        appBar = const Color(0xFF1F1F1F),
        drawer = const Color(0xFF2A2A2A),
        bottomNav = const Color(0xFF1E1E1E);

  /// Набор цветов для [Brightness.light]
  BackgroundColors.light()
      : primary = const Color(0xFFFFFFFF),
        secondary = const Color(0xFFF1F1F1),
        tertiary = const Color(0xFFEAEAEA),
        appBar = const Color(0xFFF8F8F8),
        drawer = const Color(0xFFF4F4F4),
        bottomNav = const Color(0xFFF1F1F1);

  /// Интерполяция для анимированных переходов между [BackgroundColors]
  BackgroundColors lerp(BackgroundColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return BackgroundColors(
      primary: Color.lerp(primary, b?.primary, t) ?? Colors.transparent,
      secondary: Color.lerp(secondary, b?.secondary, t) ?? Colors.transparent,
      tertiary: Color.lerp(tertiary, b?.tertiary, t) ?? Colors.transparent,
      appBar: Color.lerp(appBar, b?.appBar, t) ?? Colors.transparent,
      drawer: Color.lerp(drawer, b?.drawer, t) ?? Colors.transparent,
      bottomNav: Color.lerp(bottomNav, b?.bottomNav, t) ?? Colors.transparent,
    );
  }

  /// Метод копирования [BackgroundColors]
  BackgroundColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? appBar,
    Color? drawer,
    Color? bottomNav,
  }) {
    return BackgroundColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      appBar: appBar ?? this.appBar,
      drawer: drawer ?? this.drawer,
      bottomNav: bottomNav ?? this.bottomNav,
    );
  }
}
