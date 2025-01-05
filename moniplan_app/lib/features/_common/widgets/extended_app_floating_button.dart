import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class ExtendedAppFloatingButton extends StatelessWidget {
  const ExtendedAppFloatingButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DriftDbViewer(AppDi.instance.getDb().db),
          ),
        );
      },
      onDoubleTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AppColorsDisplayScreen(),
          ),
        );
      },
      child: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: onPressed,
      ),
    );
  }
}
