import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '_index.dart';

/// Высота области для AppBar
const kAppAppBarHeight = 40.0;

/// Высота системного меню
const kAppSystemMenuHeight = 40.0;

/// Класс для формирования [AppBarTheme] в ui kit
class AppAppBarTheme {
  /// Значение для [AppBar.backgroundColor]
  final Color? backgroundColor;

  /// Значение для [AppBar.foregroundColor]
  final Color? foregroundColor;

  /// Значение для [AppBar.elevation]
  final double? elevation;

  /// Значение для [AppBar.scrolledUnderElevation]
  final double? scrolledUnderElevation;

  /// Значение для [AppBar.shadowColor]
  final Color? shadowColor;

  /// Значение для [AppBar.surfaceTintColor]
  final Color? surfaceTintColor;

  /// Значение для [AppBar.shape]
  final ShapeBorder? shape;

  /// Значение для [AppBar.iconTheme]
  final IconThemeData? iconTheme;

  /// Значение для [AppBar.actionsIconTheme]
  final IconThemeData? actionsIconTheme;

  /// Значение для [AppBarTheme.centerTitle]
  final bool? centerTitle;

  /// Значение для [AppBar.titleSpacing]
  final double? titleSpacing;

  /// Значение для [AppBar.toolbarHeight]
  final double? toolbarHeight;

  /// Значение для [AppBar.toolbarTextStyle]
  final TextStyle? toolbarTextStyle;

  /// Значение для [AppBar.titleTextStyle]
  final TextStyle? titleTextStyle;

  /// Значение для [AppBar.systemOverlayStyle]
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Создаёт класс для формирования [AppBarTheme] в ui kit
  const AppAppBarTheme({
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.scrolledUnderElevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.iconTheme,
    this.actionsIconTheme,
    this.centerTitle,
    this.titleSpacing,
    this.toolbarHeight,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
  });

  /// Метод копирования [AppAppBarTheme]
  AppAppBarTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    ShapeBorder? shape,
    IconThemeData? iconTheme,
    IconThemeData? actionsIconTheme,
    bool? centerTitle,
    double? titleSpacing,
    double? toolbarHeight,
    TextStyle? toolbarTextStyle,
    TextStyle? titleTextStyle,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) =>
      AppAppBarTheme(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        elevation: elevation ?? this.elevation,
        scrolledUnderElevation: scrolledUnderElevation ?? this.scrolledUnderElevation,
        shadowColor: shadowColor ?? this.shadowColor,
        surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
        shape: shape ?? this.shape,
        iconTheme: iconTheme ?? this.iconTheme,
        actionsIconTheme: actionsIconTheme ?? this.actionsIconTheme,
        centerTitle: centerTitle ?? this.centerTitle,
        titleSpacing: titleSpacing ?? this.titleSpacing,
        toolbarHeight: toolbarHeight ?? this.toolbarHeight,
        toolbarTextStyle: toolbarTextStyle ?? this.toolbarTextStyle,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        systemOverlayStyle: systemOverlayStyle ?? this.systemOverlayStyle,
      );

  /// Интерполяция для анимированных переходов между [AppAppBarTheme]
  AppAppBarTheme lerp(AppAppBarTheme? b, double t) {
    if (identical(this, b)) {
      return this;
    }
    return AppAppBarTheme(
      backgroundColor: Color.lerp(backgroundColor, b?.backgroundColor, t),
      foregroundColor: Color.lerp(foregroundColor, b?.foregroundColor, t),
      elevation: lerpDouble(elevation, b?.elevation, t),
      scrolledUnderElevation: lerpDouble(scrolledUnderElevation, b?.scrolledUnderElevation, t),
      shadowColor: Color.lerp(shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(surfaceTintColor, b?.surfaceTintColor, t),
      shape: ShapeBorder.lerp(shape, b?.shape, t),
      iconTheme: IconThemeData.lerp(iconTheme, b?.iconTheme, t),
      actionsIconTheme: IconThemeData.lerp(actionsIconTheme, b?.actionsIconTheme, t),
      centerTitle: t < 0.5 ? centerTitle : b?.centerTitle,
      titleSpacing: lerpDouble(titleSpacing, b?.titleSpacing, t),
      toolbarHeight: lerpDouble(toolbarHeight, b?.toolbarHeight, t),
      toolbarTextStyle: TextStyle.lerp(toolbarTextStyle, b?.toolbarTextStyle, t),
      titleTextStyle: TextStyle.lerp(titleTextStyle, b?.titleTextStyle, t),
      systemOverlayStyle: t < 0.5 ? systemOverlayStyle : b?.systemOverlayStyle,
    );
  }

  /// Возвращает сконфигурированный [AppBarTheme]
  AppBarTheme get value => AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        shape: shape,
        iconTheme: iconTheme,
        actionsIconTheme: actionsIconTheme,
        centerTitle: centerTitle,
        titleSpacing: titleSpacing,
        toolbarHeight: toolbarHeight,
        toolbarTextStyle: toolbarTextStyle,
        titleTextStyle: titleTextStyle,
        systemOverlayStyle: systemOverlayStyle,
      );

  /// Стиль по умолчанию для [AppBarTheme]
  AppAppBarTheme.get(AppColors appColors)
      : backgroundColor = Colors.transparent,
        foregroundColor = Colors.transparent,
        elevation = 0,
        scrolledUnderElevation = 0,
        shadowColor = Colors.transparent,
        surfaceTintColor = Colors.transparent,
        shape = null,
        iconTheme = null,
        actionsIconTheme = null,
        centerTitle = true,
        titleSpacing = 0,
        toolbarHeight = kAppAppBarHeight,
        toolbarTextStyle = AppTextTheme.get(appColors).displayLarge,
        titleTextStyle = AppTextTheme.get(appColors).displayLarge,
        systemOverlayStyle = AppSystemUiOverlayStyle.get(appColors).value;
}
