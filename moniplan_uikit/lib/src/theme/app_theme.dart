import 'package:flutter/material.dart';

import '_index.dart';
import 'compose_theme_data.dart';

ThemeData theme({
  Brightness? brightness,
  TextStyle? baseTextStyle,
  AppColors? customColors,
  AppButtonStyle? customButtonStyle,
  AppShadowTheme? customShadow,
  AppBorderRadiuses? customRadius,
  AppSpaces? customSpace,
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

  return composeThemeData(
    colors: effectiveColors,
    text: effectiveTextTheme,
    appBar: effectiveAppBarTheme,
    button: effectiveButtonStyle,
    shadow: customShadow ?? AppShadowTheme.get(),
    radius: customRadius ?? AppBorderRadiuses.get(),
    space: customSpace ?? AppSpaces.get(),
  );
}
