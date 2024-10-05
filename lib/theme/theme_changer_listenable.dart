import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MoniplanThemeListenable extends StatelessWidget {
  const MoniplanThemeListenable({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Brightness>(
      valueListenable: AppColorTokens.brightnessListenable,
      builder: (context, brightness, __) {
        return SizedBox(
          key: ValueKey(brightness),
          child: child,
        );
      },
    );
  }
}
