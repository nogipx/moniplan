import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class ThemeChanger extends StatefulWidget {
  final void Function(Brightness)? onChangeTheme;
  final IThemeChangerStorage storage;
  final ThemeBrightness? initialBrightness;

  final Widget Function(BuildContext, Brightness) builder;

  const ThemeChanger({
    required this.builder,
    required this.storage,
    this.onChangeTheme,
    this.initialBrightness,
    super.key,
  });

  @override
  State<ThemeChanger> createState() => _ThemeChangerState();
}

class _ThemeChangerState extends State<ThemeChanger> with WidgetsBindingObserver {
  late final ValueNotifier<ThemeBrightness> _themeBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _themeBrightness = ValueNotifier(widget.initialBrightness ?? ThemeBrightness.system);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.storage.getSavedBrightness().then(changeTheme);
  }

  @override
  void dispose() {
    super.dispose();
    _themeBrightness.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (_themeBrightness.value == ThemeBrightness.system) {
      changeTheme(ThemeBrightness.system);
    }
  }

  void changeTheme(ThemeBrightness theme) {
    _persistBrightness(theme).then((value) {
      widget.onChangeTheme?.call(theme.brightness(context));
      _themeBrightness.value = theme;
    });
  }

  Future<void> _persistBrightness(ThemeBrightness brightness) async {
    await widget.storage.persistBrightness(brightness);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeBrightness>(
      valueListenable: _themeBrightness,
      builder: (context, value, _) {
        return ThemeChangerInherited(
          onChangeTheme: changeTheme,
          theme: _themeBrightness.value,
          child: widget.builder(context, value.brightness(context)),
        );
      },
    );
  }
}
