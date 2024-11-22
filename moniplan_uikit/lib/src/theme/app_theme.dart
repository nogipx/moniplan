import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:moniplan_uikit/src/theme/models/_index.dart';

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

    return generateThemeDataFromAppColors(
      colors: customColors ?? AppColors.get(themeStyle),
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
  required AppColors colors,
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
  final themeExtension = AppThemeData(
    colors: colors,
    buttonStyle: effectiveButtonStyle,
    shadow: effectiveShadowTheme,
    radius: effectiveBorderRadiuses,
    space: effectiveSpaces,
  );

  return ThemeData(
    useMaterial3: true,
    extensions: [themeExtension],
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.palette.primary,
      brightness:
          colors.palette.primary.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark,
      primary: colors.palette.primary,
      secondary: colors.palette.secondary,
      error: colors.state.error,
      background: colors.background.primary,
      surface: colors.element.card,
    ),
    primaryColor: colors.palette.primary,
    canvasColor: colors.background.primary,
    scaffoldBackgroundColor: colors.background.primary,
    cardColor: colors.element.card,
    dividerColor: colors.element.divider,
    highlightColor: colors.state.active.withOpacity(0.2),
    splashColor: colors.button.overlay,
    textTheme: effectiveTextTheme.value,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: effectiveButtonStyle.value,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.button.primary,
      foregroundColor: colors.text.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.palette.primary,
      foregroundColor: colors.text.primary,
      iconTheme: IconThemeData(color: colors.text.primary),
      titleTextStyle: effectiveTextTheme.titleLarge,
    ),
    iconTheme: IconThemeData(color: colors.text.primary),
    cardTheme: CardTheme(
      color: colors.element.card,
      shadowColor: effectiveShadowTheme.darkShadow1?.first.color ?? colors.element.shadow,
      elevation: effectiveShadowTheme.darkShadow1?.first.blurRadius ?? 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.element.modal,
      focusColor: colors.palette.primary,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.element.border),
        borderRadius: effectiveBorderRadiuses.small,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.palette.primary, width: 2.0),
        borderRadius: effectiveBorderRadiuses.medium,
      ),
      labelStyle: effectiveTextTheme.bodySmall,
      hintStyle: effectiveTextTheme.bodySmall,
    ),
    buttonTheme: ButtonThemeData(
      padding: EdgeInsets.all(effectiveSpaces.medium),
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadiuses.medium,
      ),
    ),
  );
}
