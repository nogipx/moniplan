import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

CustomTheme moniplanThemeForDynamicColor({
  required BuildContext context,
  required ColorScheme? dark,
  required ColorScheme? light,
  FlexSchemeVariant? variant,
}) {
  final brightness = MediaQuery.of(context).platformBrightness;
  final scheme = brightness == Brightness.dark ? dark : light;
  final theme = moniplanTheme(
    seedScheme: scheme,
    brightness: brightness,
    variant: variant ?? FlexSchemeVariant.vivid,
    monochrome: false,
  );

  return theme;
}

class PeriodicThemeChanger extends StatefulWidget {
  const PeriodicThemeChanger({
    super.key,
    required this.builder,
    required this.themeProvider,
    this.isEnabled = false,
    this.changePeriod = const Duration(seconds: 2),
  });

  final Widget Function(BuildContext, CustomTheme) builder;
  final bool isEnabled;
  final Duration changePeriod;
  final CustomTheme Function([FlexSchemeVariant? variant]) themeProvider;

  @override
  State<PeriodicThemeChanger> createState() => _PeriodicThemeChangerState();
}

class _PeriodicThemeChangerState extends State<PeriodicThemeChanger> {
  final variants = [
    FlexSchemeVariant.material3Legacy,
    FlexSchemeVariant.material,
    FlexSchemeVariant.expressive,
    FlexSchemeVariant.rainbow,
    FlexSchemeVariant.content,
    FlexSchemeVariant.candyPop,
    FlexSchemeVariant.chroma,
    FlexSchemeVariant.fidelity,
    FlexSchemeVariant.fruitSalad,
    FlexSchemeVariant.jolly,
    FlexSchemeVariant.monochrome,
    FlexSchemeVariant.neutral,
    FlexSchemeVariant.oneHue,
    FlexSchemeVariant.soft,
    FlexSchemeVariant.tonalSpot,
    FlexSchemeVariant.highContrast,
    FlexSchemeVariant.ultraContrast,
    FlexSchemeVariant.vibrant,
    FlexSchemeVariant.vivid,
    FlexSchemeVariant.vividBackground,
    FlexSchemeVariant.vividSurfaces,
  ];

  late final ValueNotifier<CustomTheme> _theme;
  late final Timer? _ticker;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _theme = ValueNotifier(widget.themeProvider());
    _ticker = widget.isEnabled
        ? Timer.periodic(
            widget.changePeriod,
            (timer) {
              setState(() {
                counter++;
                final index = counter % variants.length;
                print(index);
                _theme.value = widget.themeProvider(variants[index]);
              });
            },
          )
        : null;
  }

  @override
  void dispose() {
    _theme.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _theme,
      builder: (context, theme, _) {
        return widget.builder(context, theme);
      },
    );
  }
}
