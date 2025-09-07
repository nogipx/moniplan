// filepath: lib/database/opener/universal_database_opener_web.dart
// Web implementation (no dart:io import)

import 'package:cross_file/cross_file.dart';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

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
      (Platform.web, DatabaseType.persistent) => _openWebPersistent(
        databaseName: databaseName ?? 'app_db',
        initialBytes: initialBytes,
      ),
      (Platform.web, DatabaseType.temporary) => _openWebTemporary(initialBytes: initialBytes),
      _ => throw UnsupportedError('Platform/type combination not supported in web opener'),
    };
  }

  static DatabaseConnection _openWebPersistent({
    required String databaseName,
    Uint8List? initialBytes,
  }) {
    return DatabaseConnection.delayed(
      Future(() async {
        final probed = await WasmDatabase.probe(
          sqlite3Uri: Uri.parse('sqlite3.wasm'),
          driftWorkerUri: Uri.parse('drift_worker.dart.js'),
          databaseName: databaseName,
        );

        final implementation = _selectBestPersistentStorage(probed);

        return await probed.open(
          implementation,
          databaseName,
          initializeDatabase: initialBytes != null ? () async => initialBytes : null,
        );
      }),
    );
  }

  static DatabaseConnection _openWebTemporary({Uint8List? initialBytes}) {
    return DatabaseConnection.delayed(
      Future(() async {
        final probed = await WasmDatabase.probe(
          sqlite3Uri: Uri.parse('sqlite3.wasm'),
          driftWorkerUri: Uri.parse('drift_worker.dart.js'),
        );

        final tempName = 'temp_${DateTime.now().millisecondsSinceEpoch}';

        return await probed.open(
          WasmStorageImplementation.inMemory,
          tempName,
          initializeDatabase: initialBytes != null ? () async => initialBytes : null,
        );
      }),
    );
  }

  static WasmStorageImplementation _selectBestPersistentStorage(WasmProbeResult probed) {
    const persistentOptions = [
      WasmStorageImplementation.opfsShared,
      WasmStorageImplementation.opfsLocks,
      WasmStorageImplementation.sharedIndexedDb,
      WasmStorageImplementation.unsafeIndexedDb,
    ];

    for (final option in persistentOptions) {
      if (probed.availableStorages.contains(option)) {
        return option;
      }
    }

    return WasmStorageImplementation.inMemory;
  }

  static Future<void> overridePersistentDatabase({
    required Platform platform,
    required String databasePath,
    required Uint8List newBytes,
    String? sqlite3Uri,
    String? driftWorkerUri,
  }) async {
    final probed = await WasmDatabase.probe(
      sqlite3Uri: Uri.parse(sqlite3Uri ?? 'sqlite3.wasm'),
      driftWorkerUri: Uri.parse(driftWorkerUri ?? 'drift_worker.dart.js'),
      databaseName: databasePath,
    );

    final existingDatabases = probed.existingDatabases;
    for (final (storage, name) in existingDatabases) {
      if (name == databasePath) {
        await probed.deleteDatabase((storage, name));
        break;
      }
    }

    final implementation = _selectBestPersistentStorage(probed);
    final connection = await probed.open(
      implementation,
      databasePath,
      initializeDatabase: () async => newBytes,
    );

    await connection.executor.close();
  }
}

Future<XFile> getDatabaseFile() async {
  throw UnsupportedError('getDatabaseFile is not supported on web');
}

Future<XFile> getTemporaryDatabaseFile() async {
  throw UnsupportedError('getTemporaryDatabaseFile is not supported on web');
}
