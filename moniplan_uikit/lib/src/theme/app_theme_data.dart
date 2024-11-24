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

  /// Текстовые стили
  final AppTextTheme text;

  /// Создаёт класс с данными для темы
  const AppThemeData({
    required this.colors,
    required this.buttonStyle,
    required this.shadow,
    required this.radius,
    required this.space,
    required this.text,
  });

  @override
  ThemeExtension<AppThemeData> copyWith({
    AppColors? colors,
    AppButtonStyle? buttonStyle,
    AppShadowTheme? shadow,
    AppBorderRadiuses? radius,
    AppSpaces? space,
    AppTextTheme? text,
  }) =>
      AppThemeData(
        colors: colors ?? this.colors,
        buttonStyle: buttonStyle ?? this.buttonStyle,
        shadow: shadow ?? this.shadow,
        radius: radius ?? this.radius,
        space: space ?? this.space,
        text: text ?? this.text,
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
      text: text.lerp(other.text, t),
    );
  }
}
