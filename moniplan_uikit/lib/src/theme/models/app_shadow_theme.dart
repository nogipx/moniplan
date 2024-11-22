import 'package:flutter/material.dart';
import 'package:moniplan_uikit/src/theme/_index.dart';

/// Класс для формирования темы с тенями в ui kit
class AppShadowTheme {
  final List<BoxShadow>? darkShadow1;
  final List<BoxShadow>? darkShadow2;
  final List<BoxShadow>? darkShadow3;
  final List<BoxShadow>? darkShadow4;
  final List<BoxShadow>? darkShadow1Up;
  final List<BoxShadow>? darkShadow2Up;

  /// Создаёт класс для формирования темы с тенями в ui kit
  const AppShadowTheme({
    this.darkShadow1,
    this.darkShadow2,
    this.darkShadow3,
    this.darkShadow4,
    this.darkShadow1Up,
    this.darkShadow2Up,
  });

  /// Метод копирования [AppShadowTheme]
  AppShadowTheme copyWith({
    List<BoxShadow>? darkShadow1,
    List<BoxShadow>? darkShadow2,
    List<BoxShadow>? darkShadow3,
    List<BoxShadow>? darkShadow4,
    List<BoxShadow>? darkShadow1Up,
    List<BoxShadow>? darkShadow2Up,
  }) =>
      AppShadowTheme(
        darkShadow1: darkShadow1 ?? this.darkShadow1,
        darkShadow2: darkShadow2 ?? this.darkShadow2,
        darkShadow3: darkShadow3 ?? this.darkShadow3,
        darkShadow4: darkShadow4 ?? this.darkShadow4,
        darkShadow1Up: darkShadow1Up ?? this.darkShadow1Up,
        darkShadow2Up: darkShadow2Up ?? this.darkShadow2Up,
      );

  /// Стиль по умолчанию для [AppShadowTheme]
  AppShadowTheme.get()
      : darkShadow1 = [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 6),
            blurRadius: 10,
            spreadRadius: 4,
          ),
        ],
        darkShadow2 = [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
        darkShadow3 = [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
        darkShadow4 = [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
        darkShadow1Up = [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -4),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
        darkShadow2Up = [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, -2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ];

  /// Интерполяция для анимированных переходов между [AppShadowTheme]
  AppShadowTheme lerp(AppShadowTheme? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppShadowTheme(
      darkShadow1: lerpBoxShadow(darkShadow1, b?.darkShadow1, t),
      darkShadow2: lerpBoxShadow(darkShadow2, b?.darkShadow2, t),
      darkShadow3: lerpBoxShadow(darkShadow3, b?.darkShadow3, t),
      darkShadow4: lerpBoxShadow(darkShadow4, b?.darkShadow4, t),
      darkShadow1Up: lerpBoxShadow(darkShadow1Up, b?.darkShadow1Up, t),
      darkShadow2Up: lerpBoxShadow(darkShadow2Up, b?.darkShadow2Up, t),
    );
  }
}
