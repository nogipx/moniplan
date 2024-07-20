import 'dart:ui';

import 'package:flutter/foundation.dart';

enum ColorExtra {
  foreground,
  disabledForeground,
  background,
  disabledBackground,
  buttonForeground,
}

typedef ColorTokenFactory = ColorToken Function({
  required Color light,
  Color? dark,
  Map<ColorExtra, Color>? lightExtra,
  Map<ColorExtra, Color>? darkExtra,
});

ColorTokenFactory colorTokenFactory(
  ValueListenable<Brightness>? brightness,
) =>
    ({
      required light,
      dark,
      lightExtra,
      darkExtra,
    }) {
      return ColorToken(
        brightness: brightness,
        light: light,
        dark: dark,
        lightExtra: lightExtra ?? {},
        darkExtra: darkExtra ?? {},
      );
    };

class ColorToken implements Color {
  final Color light;
  final Color? dark;
  final ValueListenable<Brightness>? brightness;
  final Map<ColorExtra, Color> lightExtra;
  final Map<ColorExtra, Color> darkExtra;

  const ColorToken({
    required this.light,
    this.dark,
    this.brightness,
    this.lightExtra = const {},
    this.darkExtra = const {},
  });

  operator [](ColorExtra key) {
    final extra = _extra;
    if (extra.containsKey(key)) {
      return extra[key];
    }
    throw Exception(
      '"${key.name}" is not defined for this'
      '${brightness != null ? ' "${brightness!.value.name}"' : ''} color. ',
    );
  }

  Map<ColorExtra, Color> get _extra {
    var result = lightExtra;
    if (brightness != null) {
      if (brightness!.value == Brightness.light) {
        result = lightExtra;
      } else if (darkExtra.isEmpty) {
        result = lightExtra;
      } else {
        result = darkExtra.isNotEmpty ? darkExtra : lightExtra;
      }
    }
    return result;
  }

  Color get _color {
    if (brightness != null) {
      return brightness!.value == Brightness.light ? light : (dark ?? light);
    }
    return light;
  }

  @override
  int get alpha => _color.alpha;

  @override
  int get blue => _color.blue;

  @override
  double computeLuminance() => _color.computeLuminance();

  @override
  int get green => _color.green;

  @override
  double get opacity => _color.opacity;

  @override
  int get red => _color.red;

  @override
  int get value => _color.value;

  @override
  Color withAlpha(int a) => _color.withAlpha(a);

  @override
  Color withBlue(int b) => _color.withBlue(b);

  @override
  Color withGreen(int g) => _color.withGreen(g);

  @override
  Color withOpacity(double opacity) => _color.withOpacity(opacity);

  @override
  Color withRed(int r) => _color.withRed(r);
}
