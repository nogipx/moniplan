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
      hintColor: data.colors.text.secondary,
      primaryColor: data.colors.text.primary,
      splashColor: data.colors.button.pressed,
      hoverColor: data.colors.element.secondary,
      dialogBackgroundColor: data.colors.background.secondary,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: data.colors.element.red,
        onPrimary: data.colors.text.primary,
        secondary: data.colors.background.secondary,
        onSecondary: data.colors.text.secondary,
        error: data.colors.background.secondary,
        onError: data.colors.text.primary,
        surface: data.colors.background.surface,
        onSurface: data.colors.text.black,
        errorContainer: data.colors.background.surface,
        onErrorContainer: data.colors.text.black,
      ),
      primarySwatch: getMaterialColor(data.colors.text.primary),
      textSelectionTheme: TextSelectionThemeData(cursorColor: data.colors.text.error),
      appBarTheme: AppAppBarTheme.get(themeStyle).value,
      textButtonTheme: TextButtonThemeData(style: data.buttonStyle.value),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: textTheme.bodyLarge?.copyWith(
          color: data.colors.text.primary,
          backgroundColor: Colors.transparent,
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.primary),
        hintStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.secondary),
        errorStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.error),
        helperStyle: textTheme.bodyLarge?.copyWith(color: data.colors.text.secondary),
        prefixStyle: textTheme.bodyLarge,
        errorMaxLines: 3,
        fillColor: data.colors.background.secondary,
        focusColor: data.colors.text.error,
        // isDense: true,
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
        backgroundColor: data.colors.element.primary,
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
        backgroundColor: data.colors.background.surface,
        rangePickerHeaderBackgroundColor: data.colors.background.accent,
        rangePickerHeaderForegroundColor: data.colors.text.primary,
        headerBackgroundColor: data.colors.background.accent,
        headerForegroundColor: data.colors.text.primary,
        rangePickerBackgroundColor: data.colors.background.surface,
        dayStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.black),
        weekdayStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.black),
        headerHeadlineStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.black),
        headerHelpStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.black),
        yearStyle: textTheme.bodyMedium?.copyWith(color: data.colors.text.black),
        rangePickerHeaderHeadlineStyle:
            textTheme.displayMedium?.copyWith(color: data.colors.text.black),
        rangePickerHeaderHelpStyle: textTheme.displaySmall?.copyWith(color: data.colors.text.black),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return data.colors.background.accent;
          }

          return Colors.transparent;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return data.colors.text.primary;
          } else if (states.contains(WidgetState.disabled)) {
            return data.colors.text.secondary;
          }

          return data.colors.text.black;
        }),
        rangeSelectionBackgroundColor: data.colors.background.accent.withOpacity(0.5),
        rangeSelectionOverlayColor: WidgetStateProperty.all(data.colors.background.accent),
        rangePickerSurfaceTintColor: data.colors.text.black,
        dayOverlayColor: WidgetStateProperty.all(data.colors.button.red),
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
