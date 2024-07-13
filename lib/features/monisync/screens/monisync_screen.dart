import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan/features/monisync/repo/monisync_repo_impl.dart';
import 'package:moniplan/main.dart';
import 'package:moniplan_core/moniplan_core.dart';

const mockEncryptionKey = 'J33L06KoJbO1okTNJ1sHNV1DS5UiVtLPLmWn0RZbxGk=';

class MonisyncScreen extends StatefulWidget {
  const MonisyncScreen({super.key});

  @override
  State<MonisyncScreen> createState() => _MonisyncScreenState();
}

class _MonisyncScreenState extends State<MonisyncScreen> {
  late final IMonisyncRepo _monisyncRepo;

  @override
  void initState() {
    _monisyncRepo = MonisyncRepoImpl(
      encryptKey: mockEncryptionKey,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final exportResult = await _monisyncRepo.exportDataToFile();

                if (exportResult != null) {
                  await FilePicker.platform.saveFile(
                    dialogTitle: 'Where to backup Moniplan',
                    fileName: _monisyncRepo.getBackupFileName(now),
                    bytes: exportResult.file.readAsBytesSync(),
                  );
                }
              },
              child: Text('Export Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();

                if (result != null) {
                  final filePath = result.files.single.path!;
                  await db.close();
                  await _monisyncRepo.importDataFromFile(filePath: filePath);
                  db = MoniplanDriftDb(
                    lazyDatabase: driftOpenConnection(),
                  );
                } else {
                  // User canceled the picker
                }
              },
              child: Text('Import Data'),
            ),
          ],
        ),
      ),
    );
  }
}
