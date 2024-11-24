import 'package:flutter/material.dart';

import 'models/_index.dart';

/// Класс с данными для темы
class AppThemeData extends ThemeExtension<AppThemeData> {
  /// Цвета
  final AppColors colors;

  /// Тени
  final AppShadowTheme shadow;

  /// Радиусы
  final AppBorderRadiuses radius;

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
    required this.radius,
    required this.text,
    required this.appBar,
  });

  @override
  AppThemeData copyWith({
    AppColors? colors,
    AppButtonStyle? button,
    AppShadowTheme? shadow,
    AppBorderRadiuses? radius,
    AppTextTheme? text,
    AppAppBarTheme? appBar,
  }) =>
      AppThemeData(
        colors: colors ?? this.colors,
        button: button ?? this.button,
        shadow: shadow ?? this.shadow,
        radius: radius ?? this.radius,
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
      radius: radius.lerp(other.radius, t),
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
    AppBorderRadiuses? customRadius,
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
      radius: customRadius ?? AppBorderRadiuses.get(),
    );
  }
}
