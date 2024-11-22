import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';

final dbInspectorFloatingActionButton = Builder(builder: (context) {
  return FloatingActionButton(
    child: const Icon(Icons.manage_search),
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DriftDbViewer(AppDb().db),
        ),
      );
    },
  );
});
