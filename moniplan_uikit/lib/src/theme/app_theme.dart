import 'package:flutter/material.dart';
import 'package:moniplan_uikit/src/theme/_index.dart';

import 'models/_index.dart';

/// Класс для формирования [ThemeData] в ui kit
class AppTheme {
  /// Создаёт [ThemeData] в ui kit
  static ThemeData theme({
    required ThemeStyle themeStyle,
    String? fontFamily,
    AppColors? customColors,
    AppButtonStyle? customButtonStyle,
    AppShadowTheme? customShadow,
    AppBorderRadiuses? customRadius,
    AppSpaces? customSpace,
  }) {
    AppTextTheme.baseTextStyle = TextStyle(
      overflow: TextOverflow.ellipsis,
      fontFamily: fontFamily,
    );

    final textTheme = AppTextTheme.get(themeStyle);
    final data = AppThemeData(
      colors: customColors ?? AppColors.get(themeStyle),
      buttonStyle: customButtonStyle ?? AppButtonStyle.get(themeStyle),
      shadow: customShadow ?? AppShadowTheme.get(),
      radius: customRadius ?? AppBorderRadiuses.get(),
      space: customSpace ?? AppSpaces.get(),
    );

    final defaultIconThemeData = IconThemeData(color: data.colors.text.primary, size: 28);
    final defaultOutlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      textTheme: textTheme.value,
      primaryTextTheme: textTheme.value,
      scaffoldBackgroundColor: data.colors.background.primary,
      canvasColor: data.colors.background.primary,
      hintColor: data.colors.text.hint,
      primaryColor: data.colors.palette.primary,
      splashColor: data.colors.button.overlay,
      hoverColor: data.colors.button.hovered,
      dialogBackgroundColor: data.colors.background.secondary,
      colorScheme: ColorScheme(
        brightness: themeStyle == ThemeStyle.dark ? Brightness.dark : Brightness.light,
        primary: data.colors.palette.primary,
        onPrimary: data.colors.text.primary,
        secondary: data.colors.palette.secondary,
        onSecondary: data.colors.text.secondary,
        error: data.colors.state.error,
        onError: data.colors.text.primary,
        surface: data.colors.background.secondary,
        onSurface: data.colors.text.primary,
      ),
      primarySwatch: getMaterialColor(data.colors.palette.primary),
      textSelectionTheme: TextSelectionThemeData(cursorColor: data.colors.text.primary),
      appBarTheme: AppAppBarTheme.get(themeStyle).value,
      textButtonTheme: TextButtonThemeData(style: data.buttonStyle.value),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: textTheme.bodyLarge?.copyWith(
          color: data.colors.text.primary,
          backgroundColor: Colors.transparent,
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.primary),
        hintStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.hint),
        errorStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.error),
        helperStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.secondary),
        prefixStyle: textTheme.bodyLarge,
        errorMaxLines: 3,
        fillColor: data.colors.background.secondary,
        focusColor: data.colors.state.active,
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: data.space.small,
          horizontal: data.space.large,
        ),
        border: defaultOutlineInputBorder,
        disabledBorder: defaultOutlineInputBorder,
        enabledBorder: defaultOutlineInputBorder,
        errorBorder: defaultOutlineInputBorder,
        focusedBorder: defaultOutlineInputBorder,
        focusedErrorBorder: defaultOutlineInputBorder,
        prefixIconColor: data.colors.text.primary,
        suffixIconColor: data.colors.text.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: data.colors.background.secondary,
        modalBarrierColor: data.colors.background.primary.withOpacity(0.6),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: data.colors.background.secondary,
        selectedIconTheme: defaultIconThemeData,
        selectedItemColor: data.colors.text.primary,
        unselectedItemColor: data.colors.text.secondary,
        unselectedIconTheme: defaultIconThemeData.copyWith(color: data.colors.text.secondary),
        selectedLabelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: data.colors.background.primary,
        alignment: Alignment.center,
        actionsPadding: EdgeInsets.symmetric(
          horizontal: data.space.large,
        ),
        titleTextStyle: textTheme.displaySmall,
        contentTextStyle: textTheme.bodyMedium,
        iconColor: data.colors.text.primary,
        surfaceTintColor: data.colors.background.secondary,
      ),
      datePickerTheme: DatePickerThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: data.colors.background.tertiary,
        rangePickerHeaderBackgroundColor: data.colors.palette.accent,
        rangePickerHeaderForegroundColor: data.colors.text.primary,
        headerBackgroundColor: data.colors.palette.accent,
        headerForegroundColor: data.colors.text.primary,
        rangePickerBackgroundColor: data.colors.background.tertiary,
        dayStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.primary),
        weekdayStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.primary),
        headerHeadlineStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.primary),
        headerHelpStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.secondary),
        yearStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.primary),
        rangePickerHeaderHeadlineStyle:
            textTheme.displayMedium?.copyWith(color: data.colors.text.primary),
        rangePickerHeaderHelpStyle:
            textTheme.displaySmall?.copyWith(color: data.colors.text.secondary),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return data.colors.palette.accent;
          }

          return Colors.transparent;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return data.colors.text.primary;
          } else if (states.contains(WidgetState.disabled)) {
            return data.colors.text.secondary;
          }

          return data.colors.text.primary;
        }),
        rangeSelectionBackgroundColor: data.colors.palette.accent.withOpacity(0.5),
        rangeSelectionOverlayColor: WidgetStateProperty.all(data.colors.button.overlay),
        rangePickerSurfaceTintColor: data.colors.text.primary,
        dayOverlayColor: WidgetStateProperty.all(data.colors.button.overlay),
      ),
      timePickerTheme: TimePickerThemeData(
        dialBackgroundColor: data.colors.background.primary,
      ),
      iconTheme: defaultIconThemeData,
      primaryIconTheme: defaultIconThemeData,
      extensions: [data],
    );
  }
}

/// Функция, генерирующая [ThemeData] из [AppColors] для Flutter версии с поддержкой Material 3
ThemeData generateThemeDataFromAppColors(AppColors appColors) {
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
    textTheme: TextTheme(
      displayLarge:
          TextStyle(color: appColors.text.primary, fontSize: 96.0, fontWeight: FontWeight.bold),
      displayMedium:
          TextStyle(color: appColors.text.primary, fontSize: 60.0, fontWeight: FontWeight.bold),
      displaySmall:
          TextStyle(color: appColors.text.primary, fontSize: 48.0, fontWeight: FontWeight.normal),
      headlineMedium:
          TextStyle(color: appColors.text.primary, fontSize: 34.0, fontWeight: FontWeight.normal),
      headlineSmall:
          TextStyle(color: appColors.text.primary, fontSize: 24.0, fontWeight: FontWeight.normal),
      titleLarge:
          TextStyle(color: appColors.text.primary, fontSize: 20.0, fontWeight: FontWeight.bold),
      titleMedium:
          TextStyle(color: appColors.text.secondary, fontSize: 16.0, fontWeight: FontWeight.normal),
      titleSmall:
          TextStyle(color: appColors.text.secondary, fontSize: 14.0, fontWeight: FontWeight.normal),
      bodyLarge:
          TextStyle(color: appColors.text.primary, fontSize: 16.0, fontWeight: FontWeight.normal),
      bodyMedium:
          TextStyle(color: appColors.text.secondary, fontSize: 14.0, fontWeight: FontWeight.normal),
      labelLarge:
          TextStyle(color: appColors.text.primary, fontSize: 14.0, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: appColors.text.hint, fontSize: 12.0),
      labelSmall: TextStyle(color: appColors.text.hint, fontSize: 10.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(appColors.button.primary),
        foregroundColor: MaterialStateProperty.all(appColors.text.primary),
        overlayColor: MaterialStateProperty.all(appColors.button.overlay),
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: appColors.button.primary,
      foregroundColor: appColors.text.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.palette.primary,
      foregroundColor: appColors.text.primary,
      iconTheme: IconThemeData(color: appColors.text.primary),
      titleTextStyle: TextStyle(
        color: appColors.text.primary,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(color: appColors.text.primary),
    cardTheme: CardTheme(
      color: appColors.element.card,
      shadowColor: appColors.element.shadow,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appColors.element.modal,
      focusColor: appColors.palette.primary,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: appColors.element.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: appColors.palette.primary, width: 2.0),
      ),
      labelStyle: TextStyle(color: appColors.text.hint),
      hintStyle: TextStyle(color: appColors.text.hint),
    ),
  );
}
