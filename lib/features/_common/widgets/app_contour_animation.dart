import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppContourAnimation extends StatelessWidget {
  const AppContourAnimation({
    required this.child,
    super.key,
    this.customColor,
    this.isAnimated = true,
    this.useRainbowColor = false,
  });

  final Widget child;
  final bool isAnimated;
  final bool useRainbowColor;

  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    final themeColor = context.color.scheme.surfaceTint;
    final effectiveColor = customColor ?? themeColor;

    return ContourAnimationWidget(
      edgeOffsets: const EdgeInsets.all(4),
      color: effectiveColor,
      colorGenerator:
          useRainbowColor ? (p) => generateRainbowColor(p, offset: gaussianFunction(p) / 2) : null,
      visibleFractionGenerator: (p) {
        return scaleToRange(sinusoidalFunction(p), .05, .125);
      },
      isAnimated: isAnimated,
      cornerRadius: 12,
      visibleFraction: 1,
      duration: const Duration(milliseconds: 6000),
      strokeWidth: 5,
      child: child,
    );
  }
}
