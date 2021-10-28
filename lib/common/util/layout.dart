import 'package:flutter/material.dart';

class ExpandWidthLayout extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext context, double width)? builder;

  const ExpandWidthLayout({
    Key? key,
    required this.child,
  })   : builder = null,
        super(key: key);

  const ExpandWidthLayout.builder({
    Key? key,
    required this.builder,
  })   : child = const SizedBox(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final width = size.maxWidth != double.infinity
            ? size.maxWidth
            : MediaQuery.of(context).size.width;
        return builder?.call(context, width) ??
            SizedBox(
              width: width,
              child: child,
            );
      },
    );
  }
}
