import 'dart:ui';

import 'package:flutter/material.dart';

import '../_index.dart';

const kButtonMinimumSize = Size.square(40); // Увеличено для улучшения удобства нажатия

/// Класс для формирования [ButtonStyle] ui kit
class AppButtonStyle {
  // final AppColors colors;

  /// [WidgetStateProperty] для [ButtonStyle.textStyle]
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// [WidgetStateProperty] для [ButtonStyle.backgroundColor]
  final WidgetStateProperty<Color?>? backgroundColor;

  /// [WidgetStateProperty] для [ButtonStyle.foregroundColor]
  final WidgetStateProperty<Color?>? foregroundColor;

  /// [WidgetStateProperty] для [ButtonStyle.overlayColor]
  final WidgetStateProperty<Color?>? overlayColor;

  /// [WidgetStateProperty] для [ButtonStyle.shadowColor]
  final WidgetStateProperty<Color?>? shadowColor;

  /// [WidgetStateProperty] для [ButtonStyle.surfaceTintColor]
  final WidgetStateProperty<Color?>? surfaceTintColor;

  /// [WidgetStateProperty] для [ButtonStyle.elevation]
  final WidgetStateProperty<double?>? elevation;

  /// [WidgetStateProperty] для [ButtonStyle.padding]
  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;

  /// [WidgetStateProperty] для [ButtonStyle.minimumSize]
  final WidgetStateProperty<Size?>? minimumSize;

  /// [WidgetStateProperty] для [ButtonStyle.fixedSize]
  final WidgetStateProperty<Size?>? fixedSize;

  /// [WidgetStateProperty] для [ButtonStyle.maximumSize]
  final WidgetStateProperty<Size?>? maximumSize;

  /// [WidgetStateProperty] для [ButtonStyle.iconColor]
  final WidgetStateProperty<Color?>? iconColor;

  /// [WidgetStateProperty] для [ButtonStyle.iconSize]
  final WidgetStateProperty<double?>? iconSize;

  /// [WidgetStateProperty] для [ButtonStyle.side]
  final WidgetStateProperty<BorderSide?>? side;

  /// [WidgetStateProperty] для [ButtonStyle.shape]
  final WidgetStateProperty<OutlinedBorder?>? shape;

  /// [WidgetStateProperty] для [ButtonStyle.mouseCursor]
  final WidgetStateProperty<MouseCursor?>? mouseCursor;

  /// [WidgetStateProperty] для [ButtonStyle.visualDensity]
  final VisualDensity? visualDensity;

  /// [WidgetStateProperty] для [ButtonStyle.tapTargetSize]
  final MaterialTapTargetSize? tapTargetSize;

  /// [WidgetStateProperty] для [ButtonStyle.animationDuration]
  final Duration? animationDuration;

  /// [WidgetStateProperty] для [ButtonStyle.enableFeedback]
  final bool? enableFeedback;

  /// [WidgetStateProperty] для [ButtonStyle.alignment]
  final AlignmentGeometry? alignment;

  /// [WidgetStateProperty] для [ButtonStyle.splashFactory]
  final InteractiveInkFeatureFactory? splashFactory;

  /// Создаёт класс для формирования [ButtonStyle] ui kit
  const AppButtonStyle({
    // required this.colors,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.padding,
    this.minimumSize,
    this.fixedSize,
    this.maximumSize,
    this.iconColor,
    this.iconSize,
    this.side,
    this.shape,
    this.mouseCursor,
    this.visualDensity,
    this.tapTargetSize,
    this.animationDuration,
    this.enableFeedback,
    this.alignment,
    this.splashFactory,
  });

  /// Метод копирования [AppButtonStyle]
  AppButtonStyle copyWith({
    // AppColors? colors,
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<Color?>? shadowColor,
    WidgetStateProperty<Color?>? surfaceTintColor,
    WidgetStateProperty<double?>? elevation,
    WidgetStateProperty<EdgeInsetsGeometry?>? padding,
    WidgetStateProperty<Size?>? minimumSize,
    WidgetStateProperty<Size?>? fixedSize,
    WidgetStateProperty<Size?>? maximumSize,
    WidgetStateProperty<Color?>? iconColor,
    WidgetStateProperty<double?>? iconSize,
    WidgetStateProperty<BorderSide?>? side,
    WidgetStateProperty<OutlinedBorder?>? shape,
    WidgetStateProperty<MouseCursor?>? mouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) =>
      AppButtonStyle(
        // colors: colors ?? this.colors,
        textStyle: textStyle ?? this.textStyle,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        foregroundColor: foregroundColor ?? this.foregroundColor,
        overlayColor: overlayColor ?? this.overlayColor,
        shadowColor: shadowColor ?? this.shadowColor,
        surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
        elevation: elevation ?? this.elevation,
        padding: padding ?? this.padding,
        minimumSize: minimumSize ?? this.minimumSize,
        fixedSize: fixedSize ?? this.fixedSize,
        maximumSize: maximumSize ?? this.maximumSize,
        iconColor: iconColor ?? this.iconColor,
        iconSize: iconSize ?? this.iconSize,
        side: side ?? this.side,
        shape: shape ?? this.shape,
        mouseCursor: mouseCursor ?? this.mouseCursor,
        visualDensity: visualDensity ?? this.visualDensity,
        tapTargetSize: tapTargetSize ?? this.tapTargetSize,
        animationDuration: animationDuration ?? this.animationDuration,
        enableFeedback: enableFeedback ?? this.enableFeedback,
        alignment: alignment ?? this.alignment,
        splashFactory: splashFactory ?? this.splashFactory,
      );

  /// Интерполяция для анимированных переходов между [ButtonStyle]
  AppButtonStyle lerp(AppButtonStyle? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppButtonStyle(
      textStyle: WidgetStateProperty.lerp<TextStyle?>(textStyle, b?.textStyle, t, TextStyle.lerp),
      backgroundColor:
          WidgetStateProperty.lerp<Color?>(backgroundColor, b?.backgroundColor, t, Color.lerp),
      foregroundColor:
          WidgetStateProperty.lerp<Color?>(foregroundColor, b?.foregroundColor, t, Color.lerp),
      overlayColor: WidgetStateProperty.lerp<Color?>(overlayColor, b?.overlayColor, t, Color.lerp),
      shadowColor: WidgetStateProperty.lerp<Color?>(shadowColor, b?.shadowColor, t, Color.lerp),
      surfaceTintColor:
          WidgetStateProperty.lerp<Color?>(surfaceTintColor, b?.surfaceTintColor, t, Color.lerp),
      elevation: WidgetStateProperty.lerp<double?>(elevation, b?.elevation, t, lerpDouble),
      padding: WidgetStateProperty.lerp<EdgeInsetsGeometry?>(
        padding,
        b?.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      minimumSize: WidgetStateProperty.lerp<Size?>(minimumSize, b?.minimumSize, t, Size.lerp),
      fixedSize: WidgetStateProperty.lerp<Size?>(fixedSize, b?.fixedSize, t, Size.lerp),
      maximumSize: WidgetStateProperty.lerp<Size?>(maximumSize, b?.maximumSize, t, Size.lerp),
      iconColor: WidgetStateProperty.lerp<Color?>(iconColor, b?.iconColor, t, Color.lerp),
      iconSize: WidgetStateProperty.lerp<double?>(iconSize, b?.iconSize, t, lerpDouble),
      side: lerpSides(side, b?.side, t),
      shape: WidgetStateProperty.lerp<OutlinedBorder?>(shape, b?.shape, t, OutlinedBorder.lerp),
      mouseCursor: t < 0.5 ? mouseCursor : b?.mouseCursor,
      visualDensity: t < 0.5 ? visualDensity : b?.visualDensity,
      tapTargetSize: t < 0.5 ? tapTargetSize : b?.tapTargetSize,
      animationDuration: t < 0.5 ? animationDuration : b?.animationDuration,
      enableFeedback: t < 0.5 ? enableFeedback : b?.enableFeedback,
      alignment: AlignmentGeometry.lerp(alignment, b?.alignment, t),
      splashFactory: t < 0.5 ? splashFactory : b?.splashFactory,
    );
  }

  /// Возвращает сконфигурированный [ButtonStyle]
  ButtonStyle get value => ButtonStyle(
        textStyle: textStyle,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        overlayColor: overlayColor,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation ?? WidgetStateProperty.all(4),
        // Добавлено значение для поднятия кнопки
        padding: padding ??
            WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        // Улучшено для удобства
        minimumSize: minimumSize,
        fixedSize: fixedSize,
        maximumSize: maximumSize,
        iconColor: iconColor,
        iconSize: iconSize ?? WidgetStateProperty.all(24),
        // Добавлен размер иконки по умолчанию
        side: side ?? WidgetStateProperty.all(BorderSide(color: Colors.grey.shade400, width: 1)),
        // Добавлена граница по умолчанию
        shape: shape ??
            WidgetStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)), // Увеличен радиус закругления
            ),
        mouseCursor: mouseCursor ?? WidgetStateProperty.all(SystemMouseCursors.click),
        visualDensity: visualDensity,
        tapTargetSize: tapTargetSize,
        animationDuration: animationDuration ?? const Duration(milliseconds: 200),
        // Добавлена анимация на 200 мс
        enableFeedback: enableFeedback ?? true,
        alignment: alignment ?? Alignment.center,
        splashFactory: splashFactory ?? InkRipple.splashFactory,
      );

  /// Получение темы кнопки по [themeStyle]
  AppButtonStyle.get(ThemeStyle themeStyle, AppColors appColors)
      : textStyle = WidgetStateProperty.resolveWith((states) {
          final textTheme = AppTextTheme.get(themeStyle, appColors).value;
          final colors = AppColors.get(themeStyle);

          if (states.contains(WidgetState.disabled)) {
            return textTheme.labelLarge?.copyWith(color: colors.button.disabled);
          } else {
            return textTheme.labelLarge;
          }
        }),
        backgroundColor = WidgetStateProperty.all(Colors.transparent),
        foregroundColor = WidgetStateProperty.resolveWith(
          (states) {
            final colors = AppColors.get(themeStyle);
            if (states.contains(WidgetState.disabled)) {
              return colors.button.disabled;
            } else {
              return colors.text.primary;
            }
          },
        ),
        overlayColor = WidgetStateColor.resolveWith(
          (states) {
            final colors = AppColors.get(themeStyle);
            if (states.contains(WidgetState.pressed)) {
              return colors.button.pressed;
            }

            return colors.button.overlay;
          },
        ),
        shadowColor = WidgetStateProperty.all(Colors.black.withOpacity(0.15)),
        surfaceTintColor = null,
        elevation = WidgetStateProperty.all(4),
        padding = WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        minimumSize = WidgetStateProperty.all(kButtonMinimumSize),
        fixedSize = null,
        maximumSize = null,
        iconColor = WidgetStateProperty.resolveWith(
          (states) {
            final colors = AppColors.get(themeStyle);
            if (states.contains(WidgetState.disabled)) {
              return colors.button.disabled;
            } else {
              return colors.text.primary;
            }
          },
        ),
        iconSize = WidgetStateProperty.all(24),
        side = WidgetStateProperty.all(BorderSide(color: Colors.grey.shade400, width: 1)),
        shape = WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        mouseCursor = WidgetStateProperty.all(SystemMouseCursors.click),
        visualDensity = VisualDensity.adaptivePlatformDensity,
        tapTargetSize = MaterialTapTargetSize.shrinkWrap,
        animationDuration = const Duration(milliseconds: 200),
        enableFeedback = true,
        alignment = Alignment.center,
        splashFactory = null;
}
