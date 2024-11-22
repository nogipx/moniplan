import 'package:flutter/material.dart';

import '_index.dart';

/// Класс набора радиусов для ui kit
class AppBorderRadiuses {
  final BorderRadius none;
  final BorderRadius extraSmall;
  final BorderRadius small;
  final BorderRadius medium;
  final BorderRadius mediumLarge;
  final BorderRadius large;
  final BorderRadius extraLarge;
  final BorderRadius ultraLarge;
  final BorderRadius round;

  /// Создаёт приватный класс набора радиусов для ui kit
  const AppBorderRadiuses({
    required this.none,
    required this.extraSmall,
    required this.small,
    required this.medium,
    required this.mediumLarge,
    required this.large,
    required this.extraLarge,
    required this.ultraLarge,
    required this.round,
  });

  /// Набор радиусов для [ThemeStyle.light]
  AppBorderRadiuses.get()
      : none = BorderRadius.zero,
        extraSmall = BorderRadius.circular(2.0),
        small = BorderRadius.circular(4.0),
        medium = BorderRadius.circular(8.0),
        mediumLarge = BorderRadius.circular(12.0),
        large = BorderRadius.circular(16.0),
        extraLarge = BorderRadius.circular(24.0),
        ultraLarge = BorderRadius.circular(32.0),
        round = BorderRadius.circular(50.0);

  /// Интерполяция для анимированных переходов между [AppBorderRadiuses]
  AppBorderRadiuses lerp(AppBorderRadiuses? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppBorderRadiuses(
      none: BorderRadius.lerp(none, b?.none, t) ?? none,
      extraSmall: BorderRadius.lerp(extraSmall, b?.extraSmall, t) ?? extraSmall,
      small: BorderRadius.lerp(small, b?.small, t) ?? small,
      medium: BorderRadius.lerp(medium, b?.medium, t) ?? medium,
      mediumLarge: BorderRadius.lerp(mediumLarge, b?.mediumLarge, t) ?? mediumLarge,
      large: BorderRadius.lerp(large, b?.large, t) ?? large,
      extraLarge: BorderRadius.lerp(extraLarge, b?.extraLarge, t) ?? extraLarge,
      ultraLarge: BorderRadius.lerp(ultraLarge, b?.ultraLarge, t) ?? ultraLarge,
      round: BorderRadius.lerp(round, b?.round, t) ?? round,
    );
  }
}
