import 'package:flutter/material.dart';
import 'package:moniplan_uikit/src/theme/models/_index.dart';

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

    return generateThemeDataFromAppColors(
      brightness: themeStyle == ThemeStyle.dark ? Brightness.dark : Brightness.light,
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
  required Brightness brightness,
  AppButtonStyle? buttonStyle,
  AppShadowTheme? shadow,
  AppBorderRadiuses? radius,
  AppSpaces? space,
  AppTextTheme? textTheme,
  bool? useMaterial3,
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

  final defaultIconThemeData = IconThemeData(color: colors.text.primary, size: 28);
  final defaultOutlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(effectiveSpaces.mediumLarge),
    borderSide: BorderSide.none,
  );

  return ThemeData(
    useMaterial3: useMaterial3,
    fontFamily: AppTextTheme.baseTextStyle.fontFamily,
    textTheme: effectiveTextTheme.value,
    primaryTextTheme: effectiveTextTheme.value,
    scaffoldBackgroundColor: colors.background.primary,
    canvasColor: colors.background.primary,
    hintColor: colors.text.secondary,
    primaryColor: colors.text.primary,
    splashColor: colors.button.pressed,
    hoverColor: colors.button.hovered,
    dialogBackgroundColor: colors.background.secondary,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.palette.primary,
      onPrimary: colors.text.primary,
      secondary: colors.background.secondary,
      onSecondary: colors.text.secondary,
      error: colors.background.secondary,
      onError: colors.text.primary,
      surface: colors.background.tertiary,
      onSurface: colors.text.primary,
      errorContainer: colors.background.tertiary,
      onErrorContainer: colors.text.primary,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: colors.text.error),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background.appBar,
      foregroundColor: colors.text.primary,
      iconTheme: IconThemeData(color: colors.text.primary),
      titleTextStyle: effectiveTextTheme.titleLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: effectiveTextTheme.bodyLarge?.copyWith(
        color: colors.text.primary,
        backgroundColor: Colors.transparent,
      ),
      labelStyle: effectiveTextTheme.bodyLarge?.copyWith(color: colors.text.primary),
      hintStyle: effectiveTextTheme.bodyLarge?.copyWith(color: colors.text.secondary),
      errorStyle: effectiveTextTheme.bodyLarge?.copyWith(color: colors.text.error),
      helperStyle: effectiveTextTheme.bodyLarge?.copyWith(color: colors.text.secondary),
      prefixStyle: effectiveTextTheme.bodyLarge,
      errorMaxLines: 3,
      fillColor: colors.background.secondary,
      focusColor: colors.text.error,
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: effectiveSpaces.medium),
      border: defaultOutlineInputBorder,
      disabledBorder: defaultOutlineInputBorder,
      enabledBorder: defaultOutlineInputBorder,
      errorBorder: defaultOutlineInputBorder,
      focusedBorder: defaultOutlineInputBorder,
      focusedErrorBorder: defaultOutlineInputBorder,
      prefixIconColor: colors.text.primary,
      suffixIconColor: colors.text.primary,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.background.tertiary,
      modalBarrierColor: colors.background.primary.withOpacity(0.6),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: colors.background.secondary,
      selectedIconTheme: defaultIconThemeData,
      selectedItemColor: colors.text.primary,
      unselectedItemColor: colors.text.secondary,
      selectedLabelStyle: effectiveTextTheme.titleSmall,
      unselectedLabelStyle: effectiveTextTheme.titleSmall,
      unselectedIconTheme: defaultIconThemeData.copyWith(color: colors.text.secondary),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colors.background.primary,
      alignment: Alignment.center,
      actionsPadding: EdgeInsets.symmetric(horizontal: effectiveSpaces.medium),
      titleTextStyle: effectiveTextTheme.displaySmall,
      contentTextStyle: effectiveTextTheme.bodyMedium,
      iconColor: colors.text.primary,
      surfaceTintColor: colors.background.secondary,
    ),
    timePickerTheme: TimePickerThemeData(
      dialBackgroundColor: colors.background.primary,
    ),
    iconTheme: defaultIconThemeData,
    primaryIconTheme: defaultIconThemeData,
    extensions: [themeExtension],
  );
}
