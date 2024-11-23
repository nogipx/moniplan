import 'package:flutter/material.dart';

import '_index.dart';

/// Функция, генерирующая [ThemeData] из [AppColors], [AppButtonStyle],
/// [AppShadowTheme], [AppBorderRadiuses], и [AppSpaces]
/// для Flutter версии с поддержкой Material 3
ThemeData composeThemeData({
  required AppColors colors,
  required Brightness brightness,
  required AppButtonStyle buttonStyle,
  required AppShadowTheme shadow,
  required AppBorderRadiuses radius,
  required AppSpaces space,
  required AppTextTheme textTheme,
  ThemeStyle defaultThemeStyle = ThemeStyle.dark,
  bool? useMaterial3,
}) {
  final themeExtension = AppThemeData(
    colors: colors,
    buttonStyle: buttonStyle,
    shadow: shadow,
    radius: radius,
    space: space,
  );

  final defaultIconThemeData = IconThemeData(color: colors.text.primary, size: 28);
  final defaultOutlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(space.mediumLarge),
    borderSide: BorderSide.none,
  );

  return ThemeData(
    useMaterial3: useMaterial3,
    extensions: [themeExtension],
    fontFamily: AppTextTheme.baseTextStyle.fontFamily,
    textTheme: textTheme.value,
    primaryTextTheme: textTheme.value,
    scaffoldBackgroundColor: colors.background.primary,
    canvasColor: colors.background.primary,
    hintColor: colors.text.secondary,
    primaryColor: colors.text.primary,
    splashColor: colors.button.pressed,
    hoverColor: colors.button.hovered,
    dialogBackgroundColor: colors.background.secondary,
    textButtonTheme: TextButtonThemeData(style: buttonStyle.value),
    colorScheme: colors.scheme,
    textSelectionTheme: TextSelectionThemeData(cursorColor: colors.text.error),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background.appBar,
      foregroundColor: colors.text.primary,
      iconTheme: IconThemeData(color: colors.text.primary),
      titleTextStyle: textTheme.titleLarge,
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: textTheme.bodyLarge?.copyWith(
        color: colors.text.primary,
        backgroundColor: Colors.transparent,
      ),
      labelStyle: textTheme.bodyLarge?.copyWith(color: colors.text.primary),
      hintStyle: textTheme.bodyLarge?.copyWith(color: colors.text.secondary),
      errorStyle: textTheme.bodyLarge?.copyWith(color: colors.text.error),
      helperStyle: textTheme.bodyLarge?.copyWith(color: colors.text.secondary),
      prefixStyle: textTheme.bodyLarge,
      errorMaxLines: 3,
      fillColor: colors.background.secondary,
      focusColor: colors.text.error,
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: space.medium),
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
      selectedLabelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
      unselectedIconTheme: defaultIconThemeData.copyWith(color: colors.text.secondary),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colors.background.primary,
      alignment: Alignment.center,
      actionsPadding: EdgeInsets.symmetric(horizontal: space.medium),
      titleTextStyle: textTheme.displaySmall,
      contentTextStyle: textTheme.bodyMedium,
      iconColor: colors.text.primary,
      surfaceTintColor: colors.background.secondary,
    ),
    timePickerTheme: TimePickerThemeData(
      dialBackgroundColor: colors.background.primary,
    ),
    iconTheme: defaultIconThemeData,
    primaryIconTheme: defaultIconThemeData,
  );
}
