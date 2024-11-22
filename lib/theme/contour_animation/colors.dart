import 'package:flutter/cupertino.dart';

Color generateRainbowColor(double value, {double offset = 0}) {
  if (value < 0 || value > 1) {
    throw ArgumentError('Value must be between 0 and 1');
  }
  if (offset < 0 || offset > 1) {
    throw ArgumentError('Offset must be between 0 and 1');
  }

  // Переводим значение из диапазона [0, 1] в угол оттенка [0, 360]
  double hue = (value + offset) * 360 % 360;

  // Насыщенность и яркость устанавливаем в максимальное значение (полный цветовой круг)
  double saturation = 1.0;
  double brightness = 1.0;

  return HSVColor.fromAHSV(1, hue, saturation, brightness).toColor();
}

Color changeColorSaturation(Color color, double value) =>
    HSLColor.fromColor(color).withSaturation(value).toColor();

Color changeColorLightness(Color color, double value) =>
    HSLColor.fromColor(color).withLightness(value).toColor();
