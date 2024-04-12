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
    return ValueListenableBuilder(
      valueListenable: MoniplanColors.brightnessListenable,
      builder: (context, _, __) {
        return SizedBox(
          key: ValueKey(_),
          child: child,
        );
      },
    );
  }
}
