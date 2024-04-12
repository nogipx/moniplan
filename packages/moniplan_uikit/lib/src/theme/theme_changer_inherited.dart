import 'package:flutter/material.dart';

import '_index.dart';

typedef ChangeThemeCallback = void Function(ThemeBrightness);

class ThemeChangerInherited extends InheritedWidget {
  final ThemeBrightness theme;
  final ChangeThemeCallback? onChangeTheme;
  final bool persist;

  const ThemeChangerInherited({
    super.key,
    required this.theme,
    required super.child,
    this.onChangeTheme,
    this.persist = true,
  });

  static ThemeChangerInherited? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeChangerInherited>();

  void changeTheme(ThemeBrightness theme) {
    if (theme != this.theme) {
      onChangeTheme?.call(theme);
    }
  }

  void toggleTheme(BuildContext context) {
    if (theme == ThemeBrightness.system) {
      final brightness = theme.brightness(context);
      brightness == Brightness.dark
          ? _toggleTheme(ThemeBrightness.dark)
          : _toggleTheme(ThemeBrightness.light);
    } else {
      _toggleTheme(theme);
    }
  }

  void _toggleTheme(ThemeBrightness theme) {
    if (theme == ThemeBrightness.dark) {
      changeTheme(ThemeBrightness.light);
    } else if (theme == ThemeBrightness.light) {
      changeTheme(ThemeBrightness.dark);
    }
  }

  @override
  bool updateShouldNotify(covariant ThemeChangerInherited oldWidget) =>
      oldWidget.theme != theme;
}
