import 'package:flutter/material.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

import '_index.dart';

enum PeriodicThemeChangerType {
  dynamic,
  rainbow,
}

class PeriodicThemeChanger extends StatelessWidget {
  const PeriodicThemeChanger({
    super.key,
    required this.type,
    required this.builder,
    this.initialTheme,
    this.isEnabled = false,
    this.changePeriod,
    this.variants = FlexSchemeVariant.values,
    this.rainbowSeedGenerator,
  });

  /* Общие параметры */
  final PeriodicThemeChangerType type;
  final Widget Function(BuildContext, AppTheme?) builder;
  final AppTheme? initialTheme;
  final bool isEnabled;
  final Duration? changePeriod;

  /* Параметры только для [PeriodicThemeChangerType.dynamic] */
  final List<FlexSchemeVariant> variants;

  /* Параметры только для [PeriodicThemeChangerType.rainbow] */
  final RainbowSeedGenerator? rainbowSeedGenerator;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return builder(context, initialTheme);
    }

    return switch (type) {
      PeriodicThemeChangerType.dynamic => PeriodicThemeDynamicChanger(
          builder: builder,
          initialTheme: initialTheme,
          themeProvider: moniplanThemeGeneratorDynamic,
          isEnabled: isEnabled,
          changePeriod: changePeriod,
          variants: variants,
        ),
      PeriodicThemeChangerType.rainbow => PeriodicThemeRainbowChanger(
          builder: builder,
          initialTheme: initialTheme,
          themeProvider: moniplanThemeGeneratorRainbow,
          isEnabled: isEnabled,
          changePeriod: changePeriod,
          rainbowSeedGenerator: rainbowSeedGenerator,
        ),
    };
  }
}
