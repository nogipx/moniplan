import 'package:flutter/material.dart';
import 'package:moniplan/_run/theme.dart';
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
    required this.themeProvider,
    required this.builder,
    this.initialTheme,
    this.isEnabled = false,
    this.changePeriod = const Duration(seconds: 3),
    this.variants = FlexSchemeVariant.values,
    this.rainbowSeed,
    this.rainbowColor,
    this.rainbowAngleOffset,
  });

  /* Общие параметры */
  final PeriodicThemeChangerType type;
  final Widget Function(BuildContext, AppTheme?) builder;
  final AppTheme? initialTheme;
  final MoniplanThemeGenerator themeProvider;
  final bool isEnabled;

  /* Параметры только для [PeriodicThemeChangerType.dynamic] */
  final Duration changePeriod;
  final List<FlexSchemeVariant> variants;

  /* Параметры только для [PeriodicThemeChangerType.rainbow] */
  final int? rainbowSeed;
  final Color? rainbowColor;
  final double? rainbowAngleOffset;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      PeriodicThemeChangerType.dynamic => PeriodicThemeDynamicChanger(
          builder: builder,
          initialTheme: initialTheme,
          themeProvider: themeProvider,
          isEnabled: isEnabled,
          changePeriod: changePeriod,
          variants: variants,
        ),
      PeriodicThemeChangerType.rainbow => PeriodicThemeRainbowChanger(
          themeProvider: themeProvider,
          builder: builder,
        ),
    };
  }
}
