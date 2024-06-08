import 'package:flutter/material.dart';

class Grayscale extends StatelessWidget {
  const Grayscale({
    super.key,
    required this.child,
    this.grayscale = false,
  });

  final Widget child;
  final bool grayscale;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: !grayscale
          ? const ColorFilter.mode(Colors.transparent, BlendMode.dstOver)
          : const ColorFilter.matrix([
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
      child: child,
    );
  }
}
