import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class Grayscale extends StatelessWidget {
  final Widget child;
  final bool grayscale;
  final Color? color;

  const Grayscale({
    required this.child,
    this.grayscale = false,
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!grayscale) {
      return child;
    }

    final targetColor = color ?? context.color.outline;
    // Нормализуем значения цветовых каналов (0.0 - 1.0)
    final r = targetColor.red / 255;
    final g = targetColor.green / 255;
    final b = targetColor.blue / 255;

    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        0, 0, 0, 0, r * 255, // Красный канал
        0, 0, 0, 0, g * 255, // Зелёный канал
        0, 0, 0, 0, b * 255, // Синий канал
        0, 0, 0, 1, 0, // Альфа канал
      ]),
      child: child,
    );
  }
}
