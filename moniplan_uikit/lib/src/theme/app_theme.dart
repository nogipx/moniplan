import 'package:flutter/material.dart';

import 'models/_index.dart';

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
    AppTextTheme.baseTextStyle = baseTextStyle ?? TextStyle();

    return generateThemeDataFromAppColors(
      appColors: customColors ?? AppColors.get(themeStyle),
      textTheme: customTextTheme ?? AppTextTheme.get(themeStyle),
      buttonStyle: customButtonStyle ?? AppButtonStyle.get(themeStyle),
      shadow: customShadow ?? AppShadowTheme.get(),
      radius: customRadius ?? AppBorderRadiuses.get(),
      space: customSpace ?? AppSpaces.get(),
    );
  }
}

/// Функция, генерирующая [ThemeData] из [AppColors], [AppButtonStyle], [AppShadowTheme], [AppBorderRadiuses], и [AppSpaces] для Flutter версии с поддержкой Material 3
ThemeData generateThemeDataFromAppColors({
  required AppColors appColors,
  AppButtonStyle? buttonStyle,
  AppShadowTheme? shadow,
  AppBorderRadiuses? radius,
  AppSpaces? space,
  AppTextTheme? textTheme,
}) {
  final effectiveButtonStyle = buttonStyle ?? AppButtonStyle.get(ThemeStyle.dark);
  final effectiveShadowTheme = shadow ?? AppShadowTheme.get();
  final effectiveBorderRadiuses = radius ?? AppBorderRadiuses.get();
  final effectiveSpaces = space ?? AppSpaces.get();
  final effectiveTextTheme = textTheme ?? AppTextTheme.get(ThemeStyle.dark);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness:
          appColors.palette.primary.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark,
      primary: appColors.palette.primary,
      onPrimary: appColors.text.primary,
      secondary: appColors.palette.secondary,
      onSecondary: appColors.text.secondary,
      surface: appColors.element.card,
      onSurface: appColors.text.primary,
      error: appColors.state.error,
      onError: appColors.text.primary,
    ),
    primaryColor: appColors.palette.primary,
    canvasColor: appColors.background.primary,
    scaffoldBackgroundColor: appColors.background.primary,
    cardColor: appColors.element.card,
    dividerColor: appColors.element.divider,
    highlightColor: appColors.state.active.withOpacity(0.2),
    splashColor: appColors.button.overlay,
    textTheme: effectiveTextTheme.value, // Используем AppTextTheme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: effectiveButtonStyle.value, // Используем AppButtonStyle
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: appColors.button.primary,
      foregroundColor: appColors.text.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.palette.primary,
      foregroundColor: appColors.text.primary,
      iconTheme: IconThemeData(color: appColors.text.primary),
      titleTextStyle: effectiveTextTheme.titleLarge, // Используем AppTextTheme
    ),
    iconTheme: IconThemeData(color: appColors.text.primary),
    cardTheme: CardTheme(
      color: appColors.element.card,
      shadowColor: appColors.element.shadow,
      elevation:
          effectiveShadowTheme.darkShadow1?.first.blurRadius ?? 4, // Используем AppShadowTheme
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appColors.element.modal,
      focusColor: appColors.palette.primary,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: appColors.element.border),
        borderRadius: effectiveBorderRadiuses.small, // Используем AppBorderRadiuses
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: appColors.palette.primary, width: 2.0),
        borderRadius: effectiveBorderRadiuses.medium, // Используем AppBorderRadiuses
      ),
      labelStyle: effectiveTextTheme.bodySmall, // Используем AppTextTheme
      hintStyle: effectiveTextTheme.bodySmall, // Используем AppTextTheme
    ),
    buttonTheme: ButtonThemeData(
      padding: EdgeInsets.all(effectiveSpaces.medium), // Используем AppSpaces
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadiuses.medium,
      ),
    ),
  );
}
