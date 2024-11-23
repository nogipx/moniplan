import 'package:flutter/material.dart';

import '_index.dart';
import 'compose_theme_data.dart';

ThemeData theme({
  required ThemeStyle themeStyle,
  TextStyle? baseTextStyle,
  AppColors? customColors,
  AppButtonStyle? customButtonStyle,
  AppShadowTheme? customShadow,
  AppBorderRadiuses? customRadius,
  AppSpaces? customSpace,
  AppTextTheme? customTextTheme,
}) {
  AppTextTheme.baseTextStyle = baseTextStyle ?? const TextStyle();

  final effectiveColors = customColors ?? AppColors.get(themeStyle);
  final effectiveTextTheme = customTextTheme?.copyWith(colors: effectiveColors) ??
      AppTextTheme.get(themeStyle, effectiveColors);
  final effectiveButtonStyle = customButtonStyle?.copyWith(colors: effectiveColors) ??
      AppButtonStyle.get(themeStyle, effectiveColors);

  return composeThemeData(
    brightness: themeStyle == ThemeStyle.dark ? Brightness.dark : Brightness.light,
    colors: effectiveColors,
    textTheme: effectiveTextTheme,
    buttonStyle: effectiveButtonStyle,
    shadow: customShadow ?? AppShadowTheme.get(),
    radius: customRadius ?? AppBorderRadiuses.get(),
    space: customSpace ?? AppSpaces.get(),
  );
}
