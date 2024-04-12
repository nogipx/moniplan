import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class ThemeChangerListenable extends StatelessWidget {
  const ThemeChangerListenable({
    super.key,
    required this.child,
    required this.themeBrightness,
  });

  final Widget child;
  final ValueListenable<ThemeBrightness> themeBrightness;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeBrightness>(
      valueListenable: themeBrightness,
      builder: (context, _, __) {
        return SizedBox(
          key: ValueKey(_),
          child: child,
        );
      },
    );
  }
}
