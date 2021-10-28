import 'package:flutter/material.dart';

class Grayscale extends StatelessWidget {
  final Widget child;
  final bool grayscale;

  const Grayscale({
    Key? key,
    required this.child,
    this.grayscale = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ColorFiltered(
        colorFilter: !grayscale
            ? ColorFilter.mode(Colors.transparent, BlendMode.dstOver)
            : ColorFilter.matrix([
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
      ),
    );
  }
}
