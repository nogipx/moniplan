import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';

class MonisyncScreen extends StatefulWidget {
  const MonisyncScreen({super.key});

  @override
  State<MonisyncScreen> createState() => _MonisyncScreenState();
}

class _MonisyncScreenState extends State<MonisyncScreen> {
  final _monisyncRepo = AppDi.instance.getMonisyncRepo();
  final _log = AppLog('MoniSync');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _exportFilePicker,
              child: Text('Export Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importFilePicker,
              child: Text('Import Data'),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _exportShareFile() async {
  //   final now = DateTime.now();
  //   final exportResult = await _monisyncRepo.exportDataToFile(now: now);
  //
  //   if (exportResult != null) {
  //     try {
  //       final bytes = await exportResult.file.readAsBytes();
  //       final xfile = XFile.fromData(bytes);
  //
  //       final result = Share.shareXFiles(
  //         [xfile],
  //         subject: 'Share Moniplan data',
  //       );
  //       print(result);
  //     } on Object catch (error, trace) {
  //       _log.error('Failed to export', error: error, trace: trace);
  //       rethrow;
  //     }
  //   }
  // }

  Future<void> _exportFilePicker() async {
    final now = DateTime.now();
    final exportResult = await _monisyncRepo.exportDataToFile(now: now);

    if (exportResult != null) {
      try {
        final bytes = exportResult.file.readAsBytesSync();

        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Where to backup Moniplan',
          fileName: _monisyncRepo.getBackupFileName(now),
          bytes: bytes,
        );

        if (result != null) {
          final saveFile = await File(result).writeAsBytes(bytes);
          print(saveFile);
        }
      } on Object catch (error, trace) {
        _log.error('Failed to export', error: error, trace: trace);

        rethrow;
      }
    }
  }

  Future<void> _importFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final filePath = result.files.single.path!;
      await _monisyncRepo.importDataFromFile(filePath: filePath);
    } else {
      // User canceled the picker
    }
  }
}
