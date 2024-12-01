import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppContourAnimation extends StatelessWidget {
  const AppContourAnimation({
    required this.child,
    super.key,
    this.customColor,
    this.isAnimated = true,
    this.useRainbowColor = false,
    this.borderRadius = 0,
    this.edgeInsets = const EdgeInsets.all(0),
    this.duration = Duration.zero,
    this.maxFraction = .3,
    this.minFraction = .1,
  });

  final Widget child;
  final bool isAnimated;
  final bool useRainbowColor;
  final Duration duration;

  final double borderRadius;
  final EdgeInsets edgeInsets;

  final Color? customColor;

  final double maxFraction;
  final double minFraction;

  @override
  Widget build(BuildContext context) {
    final themeColor = context.color.surfaceTint;
    final effectiveColor = customColor ?? themeColor;

    return ContourAnimationWidget(
      edgeOffsets: edgeInsets,
      color: effectiveColor,
      colorGenerator:
          useRainbowColor ? (p) => generateRainbowColor(p, offset: gaussianFunction(p) / 2) : null,
      visibleFractionGenerator: (p) {
        return scaleToRange(sinusoidalFunction(p), minFraction, maxFraction);
      },
      isAnimated: isAnimated,
      cornerRadius: borderRadius,
      visibleFraction: 1,
      duration: duration,
      strokeWidth: 5,
      child: child,
    );
  }
}
