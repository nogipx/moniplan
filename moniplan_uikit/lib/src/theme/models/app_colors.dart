import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppColors {
  final ColorScheme scheme;

  Brightness get brightness => scheme.brightness;

  AppColors({
    required this.scheme,
  });

  /// Набор цветов для [Brightness.dark]
  AppColors.dark() : scheme = ColorScheme.dark();

  /// Набор цветов для [Brightness.light]
  AppColors.light() : scheme = ColorScheme.light();

  static AppColors get(Brightness _) => switch (_) {
        Brightness.light => AppColors.light(),
        _ => AppColors.dark(),
      };

  /// Интерполяция для анимированных переходов между [AppColors]
  AppColors lerp(AppColors? b, double t) {
    if (identical(this, b)) {
      return this;
    }

    return AppColors(
      scheme: ColorSchemeLerp(scheme).lerp(b?.scheme, t),
    );
  }

  /// Метод копирования [AppColors]
  AppColors copyWith({
    ColorScheme? scheme,
  }) {
    return AppColors(
      scheme: scheme ?? this.scheme,
    );
  }

  static AppColors fromSeedColor({
    required Color seedColor,
    required bool isDarkTheme,
  }) {
    final int seedColorArgb = seedColor.value;

    // Генерация палитры через CorePalette
    final CorePalette corePalette = CorePalette.of(seedColorArgb);
    final brightness = isDarkTheme ? Brightness.dark : Brightness.light;

    // Тональные палитры
    final TonalPalette primaryPalette = corePalette.primary;
    final TonalPalette secondaryPalette = corePalette.secondary;
    final TonalPalette tertiaryPalette = corePalette.tertiary;
    final TonalPalette neutralPalette = corePalette.neutral;
    final TonalPalette neutralVariantPalette = corePalette.neutralVariant;
    final TonalPalette errorPalette = corePalette.error;

    // Определение тонов
    final bool isLight = brightness == Brightness.light;
    final int primaryTone = isLight ? 40 : 80;
    final int onPrimaryTone = isLight ? 100 : 20;
    final int primaryContainerTone = isLight ? 90 : 30;
    final int onPrimaryContainerTone = isLight ? 10 : 90;

    final int surfaceTone = isLight ? 99 : 10;
    final int onSurfaceTone = isLight ? 10 : 90;

    final int outlineTone = isLight ? 50 : 60;
    final int backgroundTone = isLight ? 98 : 8;
    final int surfaceVariantTone = isLight ? 90 : 30;
    final int inversePrimaryTone = isLight ? 20 : 80;

    // Создание ColorScheme
    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: Color(primaryPalette.get(primaryTone)),
      onPrimary: Color(primaryPalette.get(onPrimaryTone)),
      primaryContainer: Color(primaryPalette.get(primaryContainerTone)),
      onPrimaryContainer: Color(primaryPalette.get(onPrimaryContainerTone)),
      secondary: Color(secondaryPalette.get(primaryTone)),
      onSecondary: Color(secondaryPalette.get(onPrimaryTone)),
      secondaryContainer: Color(secondaryPalette.get(primaryContainerTone)),
      onSecondaryContainer: Color(secondaryPalette.get(onPrimaryContainerTone)),
      tertiary: Color(tertiaryPalette.get(primaryTone)),
      onTertiary: Color(tertiaryPalette.get(onPrimaryTone)),
      tertiaryContainer: Color(tertiaryPalette.get(primaryContainerTone)),
      onTertiaryContainer: Color(tertiaryPalette.get(onPrimaryContainerTone)),
      error: Color(errorPalette.get(primaryTone)),
      onError: Color(errorPalette.get(onPrimaryTone)),
      errorContainer: Color(errorPalette.get(primaryContainerTone)),
      onErrorContainer: Color(errorPalette.get(onPrimaryContainerTone)),
      surface: Color(neutralPalette.get(surfaceTone)),
      onSurface: Color(neutralPalette.get(onSurfaceTone)),
      outline: Color(neutralVariantPalette.get(outlineTone)),
      shadow: Colors.black, // Ограниченное использование для теней
      inverseSurface: Color(neutralPalette.get(onSurfaceTone)),
      onInverseSurface: Color(neutralPalette.get(surfaceTone)),
      inversePrimary: Color(primaryPalette.get(inversePrimaryTone)),
      surfaceTint: Color(primaryPalette.get(primaryTone)), // Используется для tint
      outlineVariant: Color(neutralVariantPalette.get(outlineTone)),
      scrim: Colors.black.withOpacity(0.5), // Для модальных затемнений
      background: Color(neutralPalette.get(backgroundTone)),
      surfaceVariant: Color(neutralVariantPalette.get(surfaceVariantTone)),
    );

    return AppColors(
      scheme: colorScheme,
    );
  }
}
