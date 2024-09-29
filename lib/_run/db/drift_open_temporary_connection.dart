import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<File> getTemporaryDatabaseFile() async {
  final dbFolder = await getTemporaryDirectory();
  final file = File(p.join(dbFolder.path, 'db_temporary.sqlite'));
  return file;
}

QueryExecutor driftOpenTemporary({required Uint8List bytes}) {
  return LazyDatabase(() async {
    final file = await getTemporaryDatabaseFile();
    await file.writeAsBytes(bytes);
    return NativeDatabase.createBackgroundConnection(file);
  });
}

Future<void> driftClearTemporary() async {
  final file = await getTemporaryDatabaseFile();
  if (file.existsSync()) {
    await file.delete();
  }
}
