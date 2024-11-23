import 'package:flutter/material.dart';

import '_index.dart';

/// Функция, генерирующая [ThemeData] из [AppColors], [AppButtonStyle],
/// [AppShadowTheme], [AppBorderRadiuses], и [AppSpaces]
/// для Flutter версии с поддержкой Material 3
ThemeData composeThemeData({
  required AppColors colors,
  required AppButtonStyle buttonStyle,
  required AppShadowTheme shadow,
  required AppBorderRadiuses radius,
  required AppSpaces space,
  required AppTextTheme textTheme,
  bool? useMaterial3,
}) {
  final themeExtension = AppThemeData(
    colors: colors,
    buttonStyle: buttonStyle,
    shadow: shadow,
    radius: radius,
    space: space,
  );

  final defaultIconThemeData = IconThemeData(color: colors.content.onPrimary, size: 28);
  final defaultOutlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(space.mediumLarge),
    borderSide: BorderSide(color: colors.content.onSurfaceVariant, width: 1),
  );

  return ThemeData(
    useMaterial3: useMaterial3,
    brightness: colors.brightness,
    extensions: [themeExtension],
    fontFamily: AppTextTheme.baseTextStyle.fontFamily,
    textTheme: textTheme.value,
    primaryTextTheme: textTheme.value,
    scaffoldBackgroundColor: colors.background.surface,
    canvasColor: colors.background.surface,
    hintColor: colors.content.onSecondary,
    primaryColor: colors.accent.primary,
    splashColor: colors.accent.primary.withOpacity(0.12), // Обновлено для Material 3
    hoverColor: colors.accent.primary.withOpacity(0.08), // Обновлено для Material 3
    dialogBackgroundColor: colors.background.surface,
    textButtonTheme: TextButtonThemeData(style: buttonStyle.value),
    colorScheme: colors.scheme,
    textSelectionTheme: TextSelectionThemeData(cursorColor: colors.content.onPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background.surfaceVariant, // Используется для Material 3
      foregroundColor: colors.content.onSurface,
      iconTheme: IconThemeData(color: colors.content.onSurface),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: colors.content.onSurface),
      elevation: 0,
      surfaceTintColor: colors.accent.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: textTheme.bodyLarge?.copyWith(
        color: colors.content.onPrimary,
        backgroundColor: Colors.transparent,
      ),
      labelStyle: textTheme.bodyLarge?.copyWith(color: colors.content.onSurface),
      hintStyle: textTheme.bodyLarge?.copyWith(color: colors.content.onSecondary),
      errorStyle: textTheme.bodyLarge?.copyWith(color: colors.content.onError),
      helperStyle: textTheme.bodyLarge?.copyWith(color: colors.content.onSecondary),
      prefixStyle: textTheme.bodyLarge,
      errorMaxLines: 3,
      fillColor: colors.background.surface,
      focusColor: colors.content.onPrimary,
      filled: true,
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: space.medium),
      border: defaultOutlineInputBorder,
      disabledBorder: defaultOutlineInputBorder.copyWith(
        borderSide: BorderSide(color: colors.content.onSurface.withOpacity(0.12)),
      ),
      enabledBorder: defaultOutlineInputBorder,
      errorBorder: defaultOutlineInputBorder.copyWith(
        borderSide: BorderSide(color: colors.content.onError, width: 1),
      ),
      focusedBorder: defaultOutlineInputBorder.copyWith(
        borderSide: BorderSide(color: colors.content.onError, width: 1.5),
      ),
      focusedErrorBorder: defaultOutlineInputBorder.copyWith(
        borderSide: BorderSide(color: colors.content.onError, width: 1.5),
      ),
      prefixIconColor: colors.content.onSurface,
      suffixIconColor: colors.content.onSurface,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.background.surface,
      modalBarrierColor: colors.background.surface.withOpacity(0.6),
      surfaceTintColor: colors.accent.primary,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: colors.background.surface,
      selectedIconTheme: defaultIconThemeData,
      selectedItemColor: colors.accent.primary,
      unselectedItemColor: colors.content.onSecondary,
      selectedLabelStyle: textTheme.titleSmall?.copyWith(color: colors.accent.primary),
      unselectedLabelStyle: textTheme.titleSmall?.copyWith(color: colors.content.onSecondary),
      unselectedIconTheme: defaultIconThemeData.copyWith(color: colors.content.onSecondary),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colors.background.surface,
      alignment: Alignment.center,
      actionsPadding: EdgeInsets.symmetric(horizontal: space.medium),
      titleTextStyle: textTheme.displaySmall?.copyWith(color: colors.content.onSurface),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: colors.content.onSurfaceVariant),
      iconColor: colors.accent.primary,
      surfaceTintColor: colors.util.surfaceTint,
    ),
    timePickerTheme: TimePickerThemeData(
      dialBackgroundColor: colors.background.surface,
      helpTextStyle: textTheme.bodyMedium?.copyWith(color: colors.content.onSurface),
      entryModeIconColor: colors.accent.primary,
    ),
    iconTheme: defaultIconThemeData,
    primaryIconTheme: defaultIconThemeData,
  );
}
