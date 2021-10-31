import 'package:flutter/material.dart';

class BottomSheetDismissRectangle extends StatelessWidget {
  const BottomSheetDismissRectangle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: 36,
      decoration: BoxDecoration(
        color: Color(0xffC4C4C4),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class BaseBottomSheet extends StatelessWidget {
  const BaseBottomSheet({
    Key? key,
    required this.child,
    this.expand = false,
  }) : super(key: key);

  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: expand ? MediaQuery.of(context).size.height * .9 : null,
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetDismissRectangle(),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
