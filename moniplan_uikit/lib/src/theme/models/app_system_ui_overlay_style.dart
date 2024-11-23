import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '_index.dart';

/// Класс для формирования [SystemUiOverlayStyle] в ui kit
class AppSystemUiOverlayStyle {
  /// Значение для [SystemUiOverlayStyle.systemNavigationBarColor]
  final Color? systemNavigationBarColor;

  /// Значение для [SystemUiOverlayStyle.systemNavigationBarDividerColor]
  final Color? systemNavigationBarDividerColor;

  /// Значение для [SystemUiOverlayStyle.systemNavigationBarIconBrightness]
  final Brightness? systemNavigationBarIconBrightness;

  /// Значение для [SystemUiOverlayStyle.systemNavigationBarContrastEnforced]
  final bool? systemNavigationBarContrastEnforced;

  /// Значение для [SystemUiOverlayStyle.statusBarColor]
  final Color? statusBarColor;

  /// Значение для [SystemUiOverlayStyle.statusBarBrightness]
  final Brightness? statusBarBrightness;

  /// Значение для [SystemUiOverlayStyle.statusBarIconBrightness]
  final Brightness? statusBarIconBrightness;

  /// Значение для [SystemUiOverlayStyle.systemStatusBarContrastEnforced]
  final bool? systemStatusBarContrastEnforced;

  /// Создаёт класс для формирования [SystemUiOverlayStyle] в ui kit
  const AppSystemUiOverlayStyle({
    this.systemNavigationBarColor,
    this.systemNavigationBarDividerColor,
    this.systemNavigationBarIconBrightness,
    this.systemNavigationBarContrastEnforced,
    this.statusBarColor,
    this.statusBarBrightness,
    this.statusBarIconBrightness,
    this.systemStatusBarContrastEnforced,
  });

  /// Метод копирования [AppSystemUiOverlayStyle]
  AppSystemUiOverlayStyle copyWith({
    Color? systemNavigationBarColor,
    Color? systemNavigationBarDividerColor,
    Brightness? systemNavigationBarIconBrightness,
    bool? systemNavigationBarContrastEnforced,
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Brightness? statusBarIconBrightness,
    bool? systemStatusBarContrastEnforced,
  }) =>
      AppSystemUiOverlayStyle(
        systemNavigationBarColor: systemNavigationBarColor ?? this.systemNavigationBarColor,
        systemNavigationBarDividerColor:
            systemNavigationBarDividerColor ?? this.systemNavigationBarDividerColor,
        systemNavigationBarIconBrightness:
            systemNavigationBarIconBrightness ?? this.systemNavigationBarIconBrightness,
        systemNavigationBarContrastEnforced:
            systemNavigationBarContrastEnforced ?? this.systemNavigationBarContrastEnforced,
        statusBarColor: statusBarColor ?? this.statusBarColor,
        statusBarBrightness: statusBarBrightness ?? this.statusBarBrightness,
        statusBarIconBrightness: statusBarIconBrightness ?? this.statusBarIconBrightness,
        systemStatusBarContrastEnforced:
            systemStatusBarContrastEnforced ?? this.systemStatusBarContrastEnforced,
      );

  /// Возвращает сконфигурированный [SystemUiOverlayStyle]
  SystemUiOverlayStyle get value => SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        systemNavigationBarColor: systemNavigationBarColor,
        statusBarBrightness: statusBarBrightness,
        statusBarIconBrightness: statusBarIconBrightness,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
        systemNavigationBarDividerColor: systemNavigationBarDividerColor,
        systemNavigationBarContrastEnforced: systemNavigationBarContrastEnforced,
        systemStatusBarContrastEnforced: systemStatusBarContrastEnforced,
      );

  /// Стиль по умолчанию для [SystemUiOverlayStyle]
  AppSystemUiOverlayStyle.get(AppColors colors)
      : statusBarColor = Colors.transparent,
        systemNavigationBarColor = colors.background.surface,
        statusBarBrightness = switch (colors.brightness) {
          Brightness.light => Brightness.light,
          _ => Brightness.dark,
        },
        statusBarIconBrightness = switch (colors.brightness) {
          Brightness.light => Brightness.dark,
          _ => Brightness.light,
        },
        systemNavigationBarIconBrightness = switch (colors.brightness) {
          Brightness.light => Brightness.dark,
          _ => Brightness.light,
        },
        systemNavigationBarDividerColor = Colors.transparent,
        systemNavigationBarContrastEnforced = false,
        systemStatusBarContrastEnforced = false;

  /// Интерполяция для анимированных переходов между [AppSystemUiOverlayStyle]
  AppSystemUiOverlayStyle lerp(AppSystemUiOverlayStyle? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppSystemUiOverlayStyle(
      statusBarColor: Color.lerp(statusBarColor, b?.statusBarColor, t),
      systemNavigationBarColor:
          Color.lerp(systemNavigationBarColor, b?.systemNavigationBarColor, t),
      systemNavigationBarDividerColor:
          Color.lerp(systemNavigationBarDividerColor, b?.systemNavigationBarDividerColor, t),
      systemNavigationBarIconBrightness:
          t < 0.5 ? systemNavigationBarIconBrightness : b?.systemNavigationBarIconBrightness,
      systemNavigationBarContrastEnforced:
          t < 0.5 ? systemNavigationBarContrastEnforced : b?.systemNavigationBarContrastEnforced,
      statusBarBrightness: t < 0.5 ? statusBarBrightness : b?.statusBarBrightness,
      statusBarIconBrightness: t < 0.5 ? statusBarIconBrightness : b?.statusBarIconBrightness,
      systemStatusBarContrastEnforced:
          t < 0.5 ? systemStatusBarContrastEnforced : b?.systemStatusBarContrastEnforced,
    );
  }
}
