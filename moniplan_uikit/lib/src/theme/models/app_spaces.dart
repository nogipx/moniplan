import 'dart:ui';

/// Класс набора отступов для ui kit
class AppSpaces {
  final double none;
  final double extraSmall;
  final double small;
  final double medium;
  final double mediumLarge;
  final double large;
  final double extraLarge;
  final double ultraLarge;

  /// Создаёт приватный класс набора отступов для ui kit
  const AppSpaces({
    required this.none,
    required this.extraSmall,
    required this.small,
    required this.medium,
    required this.mediumLarge,
    required this.large,
    required this.extraLarge,
    required this.ultraLarge,
  });

  /// Набор отступов
  AppSpaces.get()
      : none = 0.0,
        extraSmall = 2.0,
        small = 4.0,
        medium = 8.0,
        mediumLarge = 12.0,
        large = 16.0,
        extraLarge = 24.0,
        ultraLarge = 32.0;

  /// Интерполяция для анимированных переходов между [AppSpaces]
  AppSpaces lerp(AppSpaces? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppSpaces(
      none: lerpDouble(none, b?.none, t) ?? none,
      extraSmall: lerpDouble(extraSmall, b?.extraSmall, t) ?? extraSmall,
      small: lerpDouble(small, b?.small, t) ?? small,
      medium: lerpDouble(medium, b?.medium, t) ?? medium,
      mediumLarge: lerpDouble(mediumLarge, b?.mediumLarge, t) ?? mediumLarge,
      large: lerpDouble(large, b?.large, t) ?? large,
      extraLarge: lerpDouble(extraLarge, b?.extraLarge, t) ?? extraLarge,
      ultraLarge: lerpDouble(ultraLarge, b?.ultraLarge, t) ?? ultraLarge,
    );
  }
}
