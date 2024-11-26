import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

final _random = Random();

typedef CustomTheme = ({ThemeData themeData, AppThemeData appThemeData});

CustomTheme moniplanTheme({
  required Brightness brightness,
  FlexSchemeVariant? variant,
  ColorScheme? seedScheme,
  // ColorScheme? baseScheme,
  double contrast = 0,
  bool monochrome = true,
  bool expressive = false,
  ThemeDataGenerator? themeDataGenerator,
  bool rainbow = false,
}) {
  if (themeDataGenerator != null) {
    ThemeDataExtension.generator = themeDataGenerator;
  } else {
    ThemeDataExtension.generator = null;
  }

  Color? rainbowColor;
  if (rainbow) {
    rainbowColor = generateRainbowColor(_random.nextDouble());
  }

  final scheme = SeedColorScheme.fromSeeds(
    brightness: brightness,
    primaryKey: rainbowColor ?? seedScheme?.primary ?? ExperimentColor.moniplanBrand,
    secondaryKey: seedScheme?.secondary ?? ExperimentColor.lightBrandColor,
    tertiaryKey: seedScheme?.tertiary ?? ExperimentColor.paynesGray,
    errorKey: seedScheme?.error ?? ExperimentColor.negativeMoneyColor,
    neutralKey: seedScheme?.surface ?? ExperimentColor.jet,
    neutralVariantKey: seedScheme?.onSurfaceVariant ?? ExperimentColor.darkBackgroundColor,
    variant: variant,
    useExpressiveOnContainerColors: expressive,
    respectMonochromeSeed: monochrome,
    contrastLevel: contrast,
    // primary: baseScheme?.primary,
    // onPrimary: baseScheme?.onPrimary,
    // primaryContainer: baseScheme?.primaryContainer,
    // onPrimaryContainer: baseScheme?.onPrimaryContainer,
    // primaryFixed: baseScheme?.primaryFixed,
    // primaryFixedDim: baseScheme?.primaryFixedDim,
    // onPrimaryFixedVariant: baseScheme?.onPrimaryFixedVariant,
    // secondary: baseScheme?.secondary,
    // onSecondary: baseScheme?.onSecondary,
    // secondaryContainer: baseScheme?.secondaryContainer,
    // onSecondaryContainer: baseScheme?.onSecondaryContainer,
    // secondaryFixed: baseScheme?.secondaryFixed,
    // secondaryFixedDim: baseScheme?.secondaryFixedDim,
    // onSecondaryFixed: baseScheme?.onSecondaryFixed,
    // onSecondaryFixedVariant: baseScheme?.onSecondaryFixedVariant,
    // tertiary: baseScheme?.tertiary,
    // onTertiary: baseScheme?.onTertiary,
    // tertiaryContainer: baseScheme?.tertiaryContainer,
    // onTertiaryContainer: baseScheme?.onTertiaryContainer,
    // tertiaryFixed: baseScheme?.tertiaryFixed,
    // tertiaryFixedDim: baseScheme?.tertiaryFixedDim,
    // onTertiaryFixed: baseScheme?.onTertiaryFixed,
    // onTertiaryFixedVariant: baseScheme?.onTertiaryFixedVariant,
    // error: baseScheme?.error,
    // onError: baseScheme?.onError,
    // errorContainer: baseScheme?.errorContainer,
    // onErrorContainer: baseScheme?.onErrorContainer,
    // surface: baseScheme?.surface,
    // surfaceDim: baseScheme?.surfaceDim,
    // surfaceBright: baseScheme?.surfaceBright,
    // surfaceContainerLowest: baseScheme?.surfaceContainerLowest,
    // surfaceContainerLow: baseScheme?.surfaceContainerLow,
    // surfaceContainer: baseScheme?.surfaceContainer,
    // surfaceContainerHigh: baseScheme?.surfaceContainerHigh,
    // surfaceContainerHighest: baseScheme?.surfaceContainerHighest,
    // onSurface: baseScheme?.onSurface,
    // onSurfaceVariant: baseScheme?.onSurfaceVariant,
    // outline: baseScheme?.outline,
    // outlineVariant: baseScheme?.outlineVariant,
    // shadow: baseScheme?.shadow,
    // scrim: baseScheme?.scrim,
    // inverseSurface: baseScheme?.inverseSurface,
    // onInverseSurface: baseScheme?.onInverseSurface,
    // inversePrimary: baseScheme?.inversePrimary,
    // surfaceTint: baseScheme?.surfaceTint,
    // background: baseScheme?.background,
    // onBackground: baseScheme?.onBackground,
    // surfaceVariant: baseScheme?.surfaceVariant,
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
