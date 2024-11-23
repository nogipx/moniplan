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
}) {
  AppTextTheme.baseTextStyle = baseTextStyle ?? const TextStyle();

  final effectiveBrightness = customColors != null ? customColors.brightness : brightness;
  final effectiveColors =
      customColors != null ? customColors : AppColors.get(effectiveBrightness ?? Brightness.light);
  final effectiveTextTheme =
      customTextTheme?.copyWith(colors: effectiveColors) ?? AppTextTheme.get(effectiveColors);
  final effectiveButtonStyle =
      customButtonStyle?.copyWith(colors: effectiveColors) ?? AppButtonStyle.get(effectiveColors);

  return composeThemeData(
    colors: effectiveColors,
    textTheme: effectiveTextTheme,
    buttonStyle: effectiveButtonStyle,
    shadow: customShadow ?? AppShadowTheme.get(),
    radius: customRadius ?? AppBorderRadiuses.get(),
    space: customSpace ?? AppSpaces.get(),
  );
}
