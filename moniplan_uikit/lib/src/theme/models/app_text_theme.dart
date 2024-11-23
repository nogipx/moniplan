import 'package:flutter/material.dart';

import '../_index.dart';

/// Класс для формирования стилей текста для [TextTheme] в ui kit

class AppTextTheme {
  /// Базовый стиль для текста
  static TextStyle baseTextStyle = TextStyle();

  final AppColors colors;

  /// Стиль текста для [TextTheme.displayLarge]
  final TextStyle? displayLarge;

  /// Стиль текста для [TextTheme.displayMedium]
  final TextStyle? displayMedium;

  /// Стиль текста для [TextTheme.displaySmall]
  final TextStyle? displaySmall;

  /// Стиль текста для [TextTheme.bodyLarge]
  final TextStyle? bodyLarge;

  /// Стиль текста для [TextTheme.bodyMedium]
  final TextStyle? bodyMedium;

  /// Стиль текста для [TextTheme.bodySmall]
  final TextStyle? bodySmall;

  /// Стиль текста для [TextTheme.headlineLarge]
  final TextStyle? headlineLarge;

  /// Стиль текста для [TextTheme.headlineMedium]
  final TextStyle? headlineMedium;

  /// Стиль текста для [TextTheme.headlineSmall]
  final TextStyle? headlineSmall;

  /// Стиль текста для [TextTheme.titleLarge]
  final TextStyle? titleLarge;

  /// Стиль текста для [TextTheme.titleMedium]
  final TextStyle? titleMedium;

  /// Стиль текста для [TextTheme.titleSmall]
  final TextStyle? titleSmall;

  /// Стиль текста для [TextTheme.labelLarge]
  final TextStyle? labelLarge;

  /// Стиль текста для [TextTheme.labelMedium]
  final TextStyle? labelMedium;

  /// Стиль текста для [TextTheme.labelSmall]
  final TextStyle? labelSmall;

  /// Создаёт класс для формирования стилей текста для [TextTheme] в ui kit
  const AppTextTheme({
    required this.colors,
    this.displayLarge,
    this.displayMedium,
    this.displaySmall,
    this.bodyLarge,
    this.bodyMedium,
    this.bodySmall,
    this.headlineLarge,
    this.headlineMedium,
    this.headlineSmall,
    this.titleLarge,
    this.titleMedium,
    this.titleSmall,
    this.labelLarge,
    this.labelMedium,
    this.labelSmall,
  });

  /// Получение текстовой темы по [themeStyle]
  AppTextTheme.get(ThemeStyle themeStyle, this.colors)
      : displayLarge = baseTextStyle.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 28,
          height: 1.3,
          color: colors.text.primary,
        ),
        displayMedium = baseTextStyle.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          height: 1.25,
          color: colors.text.primary,
        ),
        displaySmall = baseTextStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.2,
          color: colors.text.primary,
        ),
        bodyLarge = baseTextStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 1.5,
          color: colors.text.primary,
        ),
        bodyMedium = baseTextStyle.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.4,
          color: colors.text.primary,
        ),
        bodySmall = baseTextStyle.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.3,
          color: colors.text.secondary,
        ),
        headlineLarge = baseTextStyle.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          height: 1.3,
          color: colors.text.primary,
        ),
        headlineMedium = baseTextStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.25,
          color: colors.text.primary,
        ),
        headlineSmall = baseTextStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 1.2,
          color: colors.text.primary,
        ),
        titleLarge = baseTextStyle.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          height: 1.4,
          color: colors.text.primary,
        ),
        titleMedium = baseTextStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 1.3,
          color: colors.text.primary,
        ),
        titleSmall = baseTextStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 1.3,
          color: colors.text.secondary,
        ),
        labelLarge = baseTextStyle.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          height: 1.5,
          color: colors.text.primary,
        ),
        labelMedium = baseTextStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.4,
          color: colors.text.primary,
        ),
        labelSmall = baseTextStyle.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 1.4,
          color: colors.text.secondary,
        );

  /// Получение [TextTheme]
  TextTheme get value => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  /// Метод копирования [AppTextTheme]
  AppTextTheme copyWith({
    AppColors? colors,
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) =>
      AppTextTheme(
        colors: colors ?? this.colors,
        displayLarge: displayLarge ?? this.displayLarge,
        displayMedium: displayMedium ?? this.displayMedium,
        displaySmall: displaySmall ?? this.displaySmall,
        bodyLarge: bodyLarge ?? this.bodyLarge,
        bodyMedium: bodyMedium ?? this.bodyMedium,
        bodySmall: bodySmall ?? this.bodySmall,
        headlineLarge: headlineLarge ?? this.headlineLarge,
        headlineMedium: headlineMedium ?? this.headlineMedium,
        headlineSmall: headlineSmall ?? this.headlineSmall,
        titleLarge: titleLarge ?? this.titleLarge,
        titleMedium: titleMedium ?? this.titleMedium,
        titleSmall: titleSmall ?? this.titleSmall,
        labelLarge: labelLarge ?? this.labelLarge,
        labelMedium: labelMedium ?? this.labelMedium,
        labelSmall: labelSmall ?? this.labelSmall,
      );

  /// Интерполяция для анимированных переходов между [AppTextTheme]
  AppTextTheme lerp(AppTextTheme? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppTextTheme(
      colors: colors.lerp(colors, t),
      displayLarge: TextStyle.lerp(displayLarge, b?.displayLarge, t),
      displayMedium: TextStyle.lerp(displayMedium, b?.displayMedium, t),
      displaySmall: TextStyle.lerp(displaySmall, b?.displaySmall, t),
      bodyLarge: TextStyle.lerp(bodyLarge, b?.bodyLarge, t),
      bodyMedium: TextStyle.lerp(bodyMedium, b?.bodyMedium, t),
      bodySmall: TextStyle.lerp(bodySmall, b?.bodySmall, t),
      headlineLarge: TextStyle.lerp(headlineLarge, b?.headlineLarge, t),
      headlineMedium: TextStyle.lerp(headlineMedium, b?.headlineMedium, t),
      headlineSmall: TextStyle.lerp(headlineSmall, b?.headlineSmall, t),
      titleLarge: TextStyle.lerp(titleLarge, b?.titleLarge, t),
      titleMedium: TextStyle.lerp(titleMedium, b?.titleMedium, t),
      titleSmall: TextStyle.lerp(titleSmall, b?.titleSmall, t),
      labelLarge: TextStyle.lerp(labelLarge, b?.labelLarge, t),
      labelMedium: TextStyle.lerp(labelMedium, b?.labelMedium, t),
      labelSmall: TextStyle.lerp(labelSmall, b?.labelSmall, t),
    );
  }
}
