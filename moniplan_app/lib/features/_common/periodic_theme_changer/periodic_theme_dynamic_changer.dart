// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniplan_app/_run/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PeriodicThemeDynamicChanger extends StatefulWidget {
  const PeriodicThemeDynamicChanger({
    super.key,
    required this.themeProvider,
    required this.builder,
    this.changePeriod,
    this.initialTheme,
    this.isEnabled = false,
    this.variants = FlexSchemeVariant.values,
  });

  final Widget Function(BuildContext, AppTheme?) builder;
  final AppTheme? initialTheme;
  final MoniplanThemeGeneratorDynamic themeProvider;

  final bool isEnabled;
  final Duration? changePeriod;

  final List<FlexSchemeVariant> variants;

  @override
  State<PeriodicThemeDynamicChanger> createState() => _PeriodicThemeChangerState();
}

class _PeriodicThemeChangerState extends State<PeriodicThemeDynamicChanger> {
  late final ValueNotifier<AppTheme?> _theme;
  late final Timer? _ticker;
  int counter = 0;

  static const _defaultPeriod = Duration(seconds: 3);

  @override
  void initState() {
    final period = widget.changePeriod ?? _defaultPeriod;

    _theme = ValueNotifier(widget.initialTheme);
    _ticker = widget.isEnabled && widget.variants.isNotEmpty
        ? Timer.periodic(
            period,
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
    if (!widget.isEnabled) {
      return widget.builder(context, widget.initialTheme);
    }

    return ValueListenableBuilder(
      valueListenable: _theme,
      builder: (context, theme, _) {
        return widget.builder(context, theme);
      },
    );
  }
}
