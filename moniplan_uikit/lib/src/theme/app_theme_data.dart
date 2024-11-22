import 'package:flutter/material.dart';
import 'package:moniplan_uikit/src/theme/models/app_border_radius.dart';

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

  /// Создаёт класс с данными для темы
  const AppThemeData({
    required this.colors,
    required this.buttonStyle,
    required this.shadow,
    required this.radius,
  });

  @override
  ThemeExtension<AppThemeData> copyWith({
    AppColors? colors,
    AppTextTheme? textTheme,
    AppButtonStyle? buttonStyle,
    AppShadowTheme? shadow,
    AppBorderRadiuses? radius,
  }) =>
      AppThemeData(
        colors: colors ?? this.colors,
        buttonStyle: buttonStyle ?? this.buttonStyle,
        shadow: shadow ?? this.shadow,
        radius: radius ?? this.radius,
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
    );
  }
}
