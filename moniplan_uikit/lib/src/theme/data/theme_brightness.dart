import 'package:flutter/material.dart';

enum ThemeBrightness {
  light,
  dark,
  system;

  Brightness brightness(BuildContext context) {
    switch (this) {
      case ThemeBrightness.light:
        return Brightness.light;
      case ThemeBrightness.dark:
        return Brightness.dark;
      case ThemeBrightness.system:
        return MediaQueryData.fromView(View.of(context)).platformBrightness;
    }
  }

  factory ThemeBrightness.fromName(String name) => values.firstWhere((e) => e.name == name);
}
