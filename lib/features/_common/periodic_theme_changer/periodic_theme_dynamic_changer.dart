import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PeriodicThemeDynamicChanger extends StatefulWidget {
  const PeriodicThemeDynamicChanger({
    super.key,
    required this.themeProvider,
    required this.builder,
    this.initialTheme,
    this.isEnabled = false,
    this.changePeriod = const Duration(seconds: 2),
    this.variants = FlexSchemeVariant.values,
  });

  /// Билдер нижележещих виджетов
  final Widget Function(BuildContext, AppTheme?) builder;

  /// Изначальная неизмененная тема
  final AppTheme? initialTheme;

  /// Генератор новой темы
  final MoniplanThemeGenerator themeProvider;

  final bool isEnabled;
  final Duration changePeriod;

  final List<FlexSchemeVariant> variants;

  @override
  State<PeriodicThemeDynamicChanger> createState() => _PeriodicThemeChangerState();
}

class _PeriodicThemeChangerState extends State<PeriodicThemeDynamicChanger> {
  late final ValueNotifier<AppTheme?> _theme;
  late final Timer? _ticker;
  int counter = 0;

  @override
  void initState() {
    _theme = ValueNotifier(widget.initialTheme);
    _ticker = widget.isEnabled && widget.variants.isNotEmpty
        ? Timer.periodic(
            widget.changePeriod,
            (timer) async {
              _theme.value = await widget.themeProvider(
                variant: widget.variants[counter % widget.variants.length],
              );
              counter++;
            },
          )
        : null;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    widget.themeProvider().then((value) {
      _theme.value = value;
    });
    super.didChangeDependencies();
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
