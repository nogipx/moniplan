import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

extension TextColor on Color {
  static Color Function(Color) luminanceDyer({
    Color light = Colors.white,
    Color dark = Colors.black,
  }) =>
      (color) => color.computeLuminance() > 0.5 ? dark : light;

  Color dye(Color Function(Color) dyer) => dyer(this);

  Color luminance({
    Color light = Colors.white,
    Color dark = Colors.black,
  }) =>
      TextColor.luminanceDyer(light: light, dark: dark).call(this);
}

final textDyer =
    TextColor.luminanceDyer(light: Colors.white, dark: Colors.black87);
