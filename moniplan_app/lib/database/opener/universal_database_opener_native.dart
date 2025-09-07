// Native implementation (lib/database/opener/universal_database_opener_native.dart)

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

enum DatabaseType { persistent, temporary }

enum Platform { native, web }

class UniversalDatabaseOpener {
  static DatabaseConnection open({
    required Platform platform,
    required DatabaseType type,
    String? customPath,
    Uint8List? initialBytes,
    String? databaseName,
    bool logStatements = false,
  }) {
    return switch ((platform, type)) {
      (Platform.native, DatabaseType.persistent) => _openNativePersistent(
        customPath: customPath,
        logStatements: logStatements,
      ),
      (Platform.native, DatabaseType.temporary) => _openNativeTemporary(
        initialBytes: initialBytes,
        logStatements: logStatements,
      ),
      _ => throw UnsupportedError('Platform/type combination not supported in native opener'),
    };
  }

  static DatabaseConnection _openNativePersistent({
    String? customPath,
    bool logStatements = false,
  }) {
    assert(customPath != null, 'Custom path required for persistent native database');

    return DatabaseConnection.delayed(
      Future(() async {
        final file = File(customPath!);
        await file.parent.create(recursive: true);

        return DatabaseConnection(NativeDatabase(file, logStatements: logStatements));
      }),
    );
  }

  static DatabaseConnection _openNativeTemporary({
    Uint8List? initialBytes,
    bool logStatements = false,
  }) {
    return DatabaseConnection(
      NativeDatabase.memory(
        setup: (database) async {
          if (initialBytes != null) {
            await _restoreFromBytes(database, initialBytes);
          }
        },
        logStatements: logStatements,
      ),
    );
  }

  static Future<void> _restoreFromBytes(Database database, Uint8List bytes) async {
    final tempFile = await getTemporaryDatabaseFile();

    try {
      await tempFile.writeAsBytes(bytes);
      final sourceDb = sqlite3.open(tempFile.path);
      try {
        final backup = database.backup(sourceDb);
        await backup.drain();
      } finally {
        sourceDb.dispose();
      }
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  static Future<void> overridePersistentDatabase({
    required Platform platform,
    required String databasePath,
    required Uint8List newBytes,
    String? sqlite3Uri,
    String? driftWorkerUri,
  }) async {
    final file = File(databasePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(newBytes);
  }
}

Future<File> getDatabaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
  return file;
}

Future<File> getTemporaryDatabaseFile() async {
  final dbFolder = await getTemporaryDirectory();
  final file = File(p.join(dbFolder.path, 'db_temporary.sqlite'));
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
  return file;
}
