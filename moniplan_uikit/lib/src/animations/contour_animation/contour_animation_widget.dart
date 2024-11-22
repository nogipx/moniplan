import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget with contour animation.
///
/// [child] — nested widget around which the contour animation will be drawn.
/// [isAnimated] — flag to enable or disable animation.
class ContourAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool debugMode;
  final bool isAnimated;

  /// Optional painter for drawing additional elements (e.g., for debugging).
  final CustomPainter Function(double progress)? debugPainter;

  /// Customizable line width.
  final double strokeWidth;

  /// Customizable line color.
  final Color color;

  /// Customizable line cap style (e.g., round or square).
  final StrokeCap strokeCap;

  /// Corner radius for rounded edges.
  final double cornerRadius;

  /// Length of the visible part of the line as a fraction of the total perimeter length.
  final double visibleFraction;

  /// Duration of the animation playback.
  final Duration duration;

  /// Parameters for adjusting the size of the rectangle for each side in pixels.
  final EdgeInsets edgeOffsets;

  /// Callback for generating color based on the current progress.
  final Color Function(double progress)? colorGenerator;

  /// Callback for generating line width based on the current progress.
  final double Function(double progress)? strokeWidthGenerator;

  /// Callback for generating corner radius based on the current progress.
  final double Function(double progress)? cornerRadiusGenerator;

  /// Callback for generating visible line length based on the current progress.
  final double Function(double progress)? visibleFractionGenerator;

  const ContourAnimationWidget({
    required this.child,
    this.debugMode = false,
    this.isAnimated = true,
    this.debugPainter,
    this.strokeWidth = 6.0,
    this.color = Colors.white,
    this.strokeCap = StrokeCap.round,
    this.cornerRadius = 10.0,
    this.visibleFraction = 1 / 12,
    this.duration = const Duration(seconds: 10),
    this.edgeOffsets = EdgeInsets.zero,
    this.colorGenerator,
    this.strokeWidthGenerator,
    this.cornerRadiusGenerator,
    this.visibleFractionGenerator,
    super.key,
  });

  @override
  _ContourAnimationWidgetState createState() => _ContourAnimationWidgetState();
}

class _ContourAnimationWidgetState extends State<ContourAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.isAnimated) {
      // Create animation controller
      _controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );

      // Start animation if isAnimated is true
      _controller!.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ContourAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller state when the isAnimated flag changes
    if (_controller != null && oldWidget.isAnimated != widget.isAnimated) {
      if (widget.isAnimated) {
        _controller!.repeat();
      } else {
        _controller!.stop();
      }
    }

    // Update widget when debug mode changes
    if (oldWidget.debugMode != widget.debugMode) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Release animation controller resources
    if (_controller != null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If animation is disabled, return only the child without additional layers
    if (!widget.isAnimated || _controller == null) {
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          return CustomPaint(
            painter: ContourAnimationPainter(
              _controller!.value,
              debugPainter: widget.debugMode && widget.debugPainter != null
                  ? widget.debugPainter!(_controller!.value)
                  : null,
              strokeWidth: widget.strokeWidthGenerator != null
                  ? widget.strokeWidthGenerator!(_controller!.value)
                  : widget.strokeWidth,
              color: widget.colorGenerator != null
                  ? widget.colorGenerator!(_controller!.value)
                  : widget.color,
              strokeCap: widget.strokeCap,
              cornerRadius: widget.cornerRadiusGenerator != null
                  ? widget.cornerRadiusGenerator!(_controller!.value)
                  : widget.cornerRadius,
              visibleFraction: widget.visibleFractionGenerator != null
                  ? widget.visibleFractionGenerator!(_controller!.value)
                  : widget.visibleFraction,
              edgeOffsets: widget.edgeOffsets,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Custom painter for drawing animation along the contour of a widget.
///
/// This class is responsible for drawing an animated line that moves around
/// the perimeter of a rounded rectangle. It can be used to create a visual effect
/// of outlining or highlighting a widget.
class ContourAnimationPainter extends CustomPainter {
  /// Current animation progress value (from 0.0 to 1.0).
  final double progress;

  /// Optional painter for drawing additional elements (e.g., for debugging).
  final CustomPainter? debugPainter;

  /// Customizable line width.
  final double strokeWidth;

  /// Customizable line color.
  final Color color;

  /// Customizable line cap style (e.g., round or square).
  final StrokeCap strokeCap;

  /// Corner radius for rounded edges.
  final double cornerRadius;

  /// Length of the visible part of the line as a fraction of the total perimeter length.
  final double visibleFraction;

  /// Parameters for adjusting the size of the rectangle for each side in pixels.
  final EdgeInsets edgeOffsets;

  /// Constructor for the [ContourAnimationPainter] class.
  ///
  /// Takes [progress] to control the animation and additional parameters for appearance customization.
  const ContourAnimationPainter(
    this.progress, {
    this.debugPainter,
    this.strokeWidth = 6.0,
    this.color = Colors.white,
    this.strokeCap = StrokeCap.round,
    this.cornerRadius = 10.0,
    this.visibleFraction = 1 / 12,
    this.edgeOffsets = EdgeInsets.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Get the rectangle coordinates considering edgeOffsets.
    final left = edgeOffsets.left;
    final top = edgeOffsets.top;
    final right = size.width - edgeOffsets.right;
    final bottom = size.height - edgeOffsets.bottom;

    // Calculate the total perimeter length of the rectangle considering rounded corners.
    //
    // The formula consists of:
    // - the total length of the sides without rounded corners: 2 * ((right - left) + (bottom - top) - 4 * cornerRadius)
    // - the length of the rounded corners: 2 * π * cornerRadius
    final perimeterLength =
        2 * ((right - left) + (bottom - top) - 4 * cornerRadius) + 2 * math.pi * cornerRadius;

    // Determine the length of the visible segment of the line.
    final visibleLength = perimeterLength * visibleFraction;

    // Calculate the current starting position of the visible segment on the perimeter.
    //
    // Multiply [progress] by the total perimeter length and use modulo to loop the movement.
    final currentProgress = (progress * perimeterLength) % perimeterLength;

    // Create a rounded rectangle that the line will move around.
    final roundedRect = RRect.fromLTRBR(
      left, // Left boundary coordinate.
      top, // Top boundary coordinate.
      right, // Right boundary coordinate.
      bottom, // Bottom boundary coordinate.
      Radius.circular(cornerRadius), // Corner radius.
    );

    // Create a path based on the rounded rectangle.
    final path = Path()..addRRect(roundedRect);

    // Get path metrics for precise positioning on the path.
    //
    // Use an iterator for efficient access without creating a list.
    final iterator = path.computeMetrics().iterator;

    // Check if the path contains any metrics.
    if (!iterator.moveNext()) {
      return; // If not, exit the method.
    }

    // Get the first metric of the path.
    final pathMetric = iterator.current;

    // Determine the start and end points of the visible segment on the path.
    final start = currentProgress; // Start point of the segment.
    final end = start + visibleLength; // End point of the segment.

    // Initialize a variable to store the extracted path segment.
    Path extractPath;

    // Check if the end of the segment exceeds the total path length.
    if (end <= pathMetric.length) {
      // If the end of the segment is within the path length,
      // extract the segment directly.
      extractPath = pathMetric.extractPath(
        start,
        end,
      );
    } else {
      // If the end of the segment exceeds the path,
      // two segments need to be combined:
      // 1. From the start point to the end of the path.
      // 2. From the beginning of the path to the remaining part of the segment.
      extractPath = Path()
        // Add the first segment from [start] to the end of the path.
        ..addPath(
          pathMetric.extractPath(
            start,
            pathMetric.length,
          ),
          Offset.zero, // No offset needed.
        )
        // Add the second segment from the start of the path to [(end - path length)].
        ..addPath(
          pathMetric.extractPath(
            0,
            end - pathMetric.length,
          ),
          Offset.zero,
        );
    }

    // Static [Paint] object for configuring the drawing brush.
    final paint = Paint()
      ..strokeWidth = strokeWidth // Customizable line width.
      ..color = color // Customizable line color.
      ..style = PaintingStyle.stroke // Set to draw only the stroke.
      ..strokeCap = strokeCap; // Customizable line ends.

    // Draw the extracted path segment on the canvas using the configured brush.
    canvas.drawPath(extractPath, paint);

    // If [debugPainter] is provided, call its paint method for additional drawing.
    debugPainter?.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant ContourAnimationPainter oldDelegate) {
    // Indicate that repainting is necessary if [progress] or any of the customization parameters have changed.
    return oldDelegate.progress != progress ||
        oldDelegate.debugPainter != debugPainter ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.visibleFraction != visibleFraction ||
        oldDelegate.edgeOffsets != edgeOffsets;
  }
}
