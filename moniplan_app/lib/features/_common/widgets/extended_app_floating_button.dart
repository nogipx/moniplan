import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class ExtendedAppFloatingButton extends StatelessWidget {
  const ExtendedAppFloatingButton({
    required this.onPressed,
    super.key,
    this.onLongPressed,
    this.onDoubleTap,
  });

  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPressed,
      onDoubleTap:
          onDoubleTap ??
          () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => AppColorsDisplayScreen()));
          },
      child: FloatingActionButton(onPressed: onPressed, child: const Icon(Icons.add)),
    );
  }
}
