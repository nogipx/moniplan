import 'package:flutter/material.dart';

import 'models/_index.dart';

/// Класс с данными для темы
class AppThemeData extends ThemeExtension<AppThemeData> {
  /// Цвета
  final AppColors colors;

  /// Стиль кнопки
  final AppButtonStyle buttonStyle;

  /// Тени
  final AppShadowTheme shadow;

  /// Радиусы
  final AppBorderRadiuses radius;

  /// Отступы
  final AppSpaces space;

  /// Создаёт класс с данными для темы
  const AppThemeData({
    required this.colors,
    required this.buttonStyle,
    required this.shadow,
    required this.radius,
    required this.space,
  });

  @override
  ThemeExtension<AppThemeData> copyWith({
    AppColors? colors,
    AppTextTheme? textTheme,
    AppButtonStyle? buttonStyle,
    AppShadowTheme? shadow,
    AppBorderRadiuses? radius,
    AppSpaces? space,
  }) =>
      AppThemeData(
        colors: colors ?? this.colors,
        buttonStyle: buttonStyle ?? this.buttonStyle,
        shadow: shadow ?? this.shadow,
        radius: radius ?? this.radius,
        space: space ?? this.space,
      );

  @override
  ThemeExtension<AppThemeData> lerp(
    covariant ThemeExtension<AppThemeData>? other,
    double t,
  ) {
    if (other is! AppThemeData) {
      return this;
    }

    return AppThemeData(
      colors: colors.lerp(other.colors, t),
      buttonStyle: buttonStyle.lerp(other.buttonStyle, t),
      shadow: shadow.lerp(other.shadow, t),
      radius: radius.lerp(other.radius, t),
      space: space.lerp(other.space, t),
    );
  }
}
