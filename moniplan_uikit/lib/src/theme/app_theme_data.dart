// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import 'models/_index.dart';

typedef AppTheme = ({ThemeData themeData, AppThemeData appThemeData});

/// Класс с данными для темы
class AppThemeData extends ThemeExtension<AppThemeData> {
  /// Цвета
  final AppColors colors;

  /// Тени
  final AppShadowTheme shadow;

  /// Текстовые стили
  final AppTextTheme text;

  /// Стиль кнопки
  final AppButtonStyle button;

  /// Стиль аппбара
  final AppAppBarTheme appBar;

  Brightness get brightness => colors.brightness;

  /// Создаёт класс с данными для темы
  const AppThemeData({
    required this.colors,
    required this.button,
    required this.shadow,
    required this.text,
    required this.appBar,
  });

  @override
  AppThemeData copyWith({
    AppColors? colors,
    AppButtonStyle? button,
    AppShadowTheme? shadow,
    AppTextTheme? text,
    AppAppBarTheme? appBar,
  }) =>
      AppThemeData(
        colors: colors ?? this.colors,
        button: button ?? this.button,
        shadow: shadow ?? this.shadow,
        text: text ?? this.text,
        appBar: appBar ?? this.appBar,
      );

  @override
  ThemeExtension<AppThemeData> lerp(
    covariant ThemeExtension<AppThemeData>? other,
    double t,
  ) {
    if (other is! AppThemeData) {
      return this;
    }

    return AppThemeData(
      colors: colors.lerp(other.colors, t),
      button: button.lerp(other.button, t),
      shadow: shadow.lerp(other.shadow, t),
      text: text.lerp(other.text, t),
      appBar: appBar.lerp(other.appBar, t),
    );
  }

  factory AppThemeData.fromStyles({
    Brightness? brightness,
    AppColors? customColors,
    TextStyle? baseTextStyle,
    AppButtonStyle? customButtonStyle,
    AppShadowTheme? customShadow,
    AppRadius? customRadius,
    AppTextTheme? customTextTheme,
    AppAppBarTheme? customAppBar,
  }) {
    final effectiveBrightness = customColors != null ? customColors.brightness : brightness;

    final effectiveColors = customColors ??
        AppColors.get(
          effectiveBrightness ?? Brightness.light,
        );

    final effectiveTextTheme = customTextTheme?.copyWith(
          colors: effectiveColors,
        ) ??
        AppTextTheme.get(
          colors: effectiveColors,
          baseTextStyle: baseTextStyle ?? TextStyle(),
        );

    final effectiveButtonStyle = customButtonStyle?.copyWith(
          colors: effectiveColors,
        ) ??
        AppButtonStyle(
          colors: effectiveColors,
        );

    final effectiveAppBarTheme = customAppBar?.copyWith() ??
        AppAppBarTheme.get(
          appColors: effectiveColors,
          textTheme: effectiveTextTheme,
          systemUiOverlay: AppSystemUiOverlayStyle.get(effectiveColors),
        );

    return AppThemeData(
      colors: effectiveColors,
      text: effectiveTextTheme,
      button: effectiveButtonStyle,
      appBar: effectiveAppBarTheme,
      shadow: customShadow ?? AppShadowTheme.get(),
    );
  }
}
