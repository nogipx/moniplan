import 'package:flutter/material.dart';

import '_index.dart';

/// Класс для формирования [ThemeData] в ui kit
class AppTheme {
  /// Создаёт [ThemeData] в ui kit
  static ThemeData theme({
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

    return generateThemeDataFromAppColors(
      brightness: themeStyle == ThemeStyle.dark ? Brightness.dark : Brightness.light,
      colors: effectiveColors,
      textTheme: customTextTheme ?? AppTextTheme.get(themeStyle, effectiveColors),
      buttonStyle: customButtonStyle ?? AppButtonStyle.get(themeStyle, effectiveColors),
      shadow: customShadow ?? AppShadowTheme.get(),
      radius: customRadius ?? AppBorderRadiuses.get(),
      space: customSpace ?? AppSpaces.get(),
    );
  }
}
