import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<File> getTemporaryDatabaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db_temporary.sqlite'));
  return file;
}

LazyDatabase driftOpenTemporary({required Uint8List bytes}) {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    final file = await getTemporaryDatabaseFile();
    await file.writeAsBytes(bytes);

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}

Future<void> driftClearTemporary() async {
  final file = await getTemporaryDatabaseFile();
  if (file.existsSync()) {
    await file.delete();
  }
}
