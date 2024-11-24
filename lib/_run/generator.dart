import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

ThemeDataGenerator _generator() => (data, useMaterial3) {
      final colors = data.colors;
      final button = data.button;
      final shadow = data.shadow;
      final text = data.text;

      final defaultIconThemeData = IconThemeData(color: colors.scheme.onPrimary, size: 28);
      final defaultOutlineInputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpace.s16),
        borderSide: BorderSide(color: colors.scheme.onSurfaceVariant, width: 1),
      );

      return ThemeData(
        useMaterial3: useMaterial3,
        brightness: colors.brightness,
        extensions: [data],
        fontFamily: text.baseTextStyle.fontFamily,
        textTheme: text.value,
        primaryTextTheme: text.value,
        scaffoldBackgroundColor: colors.scheme.surface,
        canvasColor: colors.scheme.surface,
        hintColor: colors.scheme.onSecondary,
        primaryColor: colors.scheme.primary,
        splashColor: colors.scheme.primary.withOpacity(0.12), // Обновлено для Material 3
        hoverColor: colors.scheme.primary.withOpacity(0.08), // Обновлено для Material 3
        dialogBackgroundColor: colors.scheme.surface,
        textButtonTheme: TextButtonThemeData(style: button.value),
        colorScheme: colors.scheme,
        textSelectionTheme: TextSelectionThemeData(cursorColor: colors.scheme.onPrimary),
        appBarTheme: data.appBar.value,
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: text.bodyLarge,
          labelStyle: text.bodyLarge,
          hintStyle: text.bodyLarge,
          errorStyle: text.bodyLarge,
          helperStyle: text.bodyLarge,
          prefixStyle: text.bodyLarge,
          errorMaxLines: 3,
          fillColor: colors.scheme.surface,
          focusColor: colors.scheme.onPrimary,
          filled: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: AppSpace.s4,
            horizontal: AppSpace.s8,
          ),
          border: defaultOutlineInputBorder,
          disabledBorder: defaultOutlineInputBorder.copyWith(
            borderSide: BorderSide(color: colors.scheme.onSurface.withOpacity(0.12)),
          ),
          enabledBorder: defaultOutlineInputBorder,
          errorBorder: defaultOutlineInputBorder.copyWith(
            borderSide: BorderSide(color: colors.scheme.onError, width: 1),
          ),
          focusedBorder: defaultOutlineInputBorder.copyWith(
            borderSide: BorderSide(color: colors.scheme.onError, width: 1.5),
          ),
          focusedErrorBorder: defaultOutlineInputBorder.copyWith(
            borderSide: BorderSide(color: colors.scheme.onError, width: 1.5),
          ),
          prefixIconColor: colors.scheme.onSurface,
          suffixIconColor: colors.scheme.onSurface,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: colors.scheme.surface,
          modalBarrierColor: colors.scheme.surface.withOpacity(0.6),
          surfaceTintColor: colors.scheme.primary,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: colors.scheme.surface,
          selectedIconTheme: defaultIconThemeData,
          selectedItemColor: colors.scheme.primary,
          unselectedItemColor: colors.scheme.onSecondary,
          selectedLabelStyle: text.titleSmall,
          unselectedLabelStyle: text.titleSmall,
          unselectedIconTheme: defaultIconThemeData,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: colors.scheme.surface,
          alignment: Alignment.center,
          actionsPadding: EdgeInsets.symmetric(
            horizontal: AppSpace.s8,
          ),
          titleTextStyle: text.displaySmall,
          contentTextStyle: text.bodyMedium,
          iconColor: colors.scheme.primary,
          surfaceTintColor: colors.scheme.surfaceTint,
        ),
        timePickerTheme: TimePickerThemeData(
          dialBackgroundColor: colors.scheme.surface,
          helpTextStyle: text.bodyMedium,
          entryModeIconColor: colors.scheme.primary,
        ),
        iconTheme: defaultIconThemeData,
        primaryIconTheme: defaultIconThemeData,
      );
    };
