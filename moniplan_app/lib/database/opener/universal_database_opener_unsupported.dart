// filepath: lib/_run/db/universal_database_opener_unsupported.dart
// Fallback stub when neither native nor web implementations are available.

import 'package:cross_file/cross_file.dart';
import 'package:drift/drift.dart';

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
    throw UnsupportedError('UniversalDatabaseOpener is not supported on this platform');
  }

  static Future<void> overridePersistentDatabase({
    required Platform platform,
    required String databasePath,
    required Uint8List newBytes,
    String? sqlite3Uri,
    String? driftWorkerUri,
  }) async {
    throw UnsupportedError('overridePersistentDatabase is not supported on this platform');
  }
}

Future<XFile> getDatabaseFile() async {
  throw UnsupportedError('getDatabaseFile is not supported on this platform');
}

Future<XFile> getTemporaryDatabaseFile() async {
  throw UnsupportedError('getTemporaryDatabaseFile is not supported on this platform');
}
