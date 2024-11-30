import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

AppTheme moniplanTheme({
  required Brightness brightness,
  FlexSchemeVariant? variant,
  ColorScheme? seedScheme,
  double contrast = 0,
  ThemeDataGenerator? themeDataGenerator,
  bool rainbow = false,
  int? rainbowSeed,
  Color? rainbowColor,
  bool respectMonochromeSeed = true,
  bool useExpressiveOnLightContainerColors = true,
}) {
  if (themeDataGenerator != null) {
    ThemeDataExtension.generator = themeDataGenerator;
  } else {
    ThemeDataExtension.generator = null;
  }

  ColorScheme? effectiveScheme = seedScheme;

  if (rainbow) {
    final random = rainbowSeed != null ? Random(rainbowSeed) : Random.secure();
    final targetRainbowColor = rainbowColor ?? generateRainbowColor(random.nextDouble());

    final effectiveRainbowColor = changeColorSaturation(targetRainbowColor, 1);

    final baseScheme = brightness == Brightness.dark ? ColorScheme.dark() : ColorScheme.light();

    effectiveScheme = (seedScheme ?? baseScheme).copyWith(
      primary: effectiveRainbowColor,
      secondary: effectiveRainbowColor,
      tertiary: effectiveRainbowColor,
      error: effectiveRainbowColor,
      surface: effectiveRainbowColor,
      onSurfaceVariant: effectiveRainbowColor,
    );
  }

  final scheme = SeedColorScheme.fromSeeds(
    brightness: brightness,
    variant: variant,
    primaryKey: effectiveScheme?.primary ?? ExperimentColor.moniplanBrand,
    secondaryKey: effectiveScheme?.secondary,
    tertiaryKey: effectiveScheme?.tertiary,
    errorKey: effectiveScheme?.error,
    neutralKey: effectiveScheme?.surface,
    neutralVariantKey: effectiveScheme?.onSurfaceVariant,
    contrastLevel: contrast,
    useExpressiveOnContainerColors: useExpressiveOnLightContainerColors,
    respectMonochromeSeed: respectMonochromeSeed,
  );

  var themeData = AppThemeData.fromStyles(
    customColors: AppColors(scheme: scheme),
    baseTextStyle: TextStyle(
      overflow: TextOverflow.visible,
      fontFamily: 'TTNeoris',
    ),
  );

  return (
    appThemeData: themeData,
    themeData: ThemeDataExtension.fromData(
      themeData,
      useMaterial3: true,
      extensions: [
        MoniplanExtraColors.from(brightness),
      ],
    ),
  );
}
