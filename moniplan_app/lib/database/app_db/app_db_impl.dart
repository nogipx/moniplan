import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'app_db.dart';

/// Универсальный AppDb поверх rpc_dart_data. Использует SQLite файл на IO и OPFS/IndexedDB на web.
class AppDbImpl extends ChangeNotifier implements AppDb {
  AppDbImpl({RpcLogger? log, bool inMemory = false})
    : _log = log ?? RpcLogger('AppDbImpl'),
      _inMemory = inMemory;

  final bool _inMemory;
  final RpcLogger _log;

  DatabaseConnection? _connection;
  SqliteDataStorageAdapter? _storage;
  SqliteDataRepository? _repository;
  InMemoryDataServiceEnvironment? _env;
  String? _dbPath;

  @override
  IDataService get dataService {
    final client = _env?.client;
    if (client == null) {
      throw StateError('Database not opened');
    }
    return client;
  }

  @override
  Future<void> open() async {
    if (_env != null) {
      return;
    }

    try {
      final options = _buildOptions();
      _connection = _inMemory
          ? await openInMemoryDb(options: options)
          : await _openPersistentConnection(options);

      _storage = SqliteDataStorageAdapter.connection(
        _connection!,
        isInMemory: _inMemory,
      );
      await _storage!.ensureReady();

      _repository = SqliteDataRepository(storage: _storage!);
      _env = await DataServiceFactory.inMemory(repository: _repository);

      notifyListeners();
    } on Object catch (error, trace) {
      _log.error('open failed', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<void> overwriteWithBytes({required Uint8List bytes}) async {
    try {
      if (_env == null) {
        await open();
      }
      final payload = utf8.decode(bytes);
      await dataService.importDatabase(payload: payload, replaceExisting: true);
      notifyListeners();
    } on Object catch (error, trace) {
      _log.error('overwriteWithBytes failed', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<Uint8List> exportBytes() async {
    if (_env == null) {
      await open();
    }
    final export = await dataService.exportDatabase();
    return Uint8List.fromList(utf8.encode(export.payload));
  }

  @override
  Future<void> close() async {
    await _close();
    notifyListeners();
  }

  Future<void> _close() async {
    try {
      await _env?.dispose();
    } finally {
      _env = null;
      _repository = null;
      try {
        await _storage?.dispose();
      } finally {
        _storage = null;
      }
      try {
        await _connection?.close();
      } finally {
        _connection = null;
      }
    }
  }

  Future<DatabaseConnection> _openPersistentConnection(
    SqliteConnectionOptions options,
  ) async {
    if (kIsWeb) {
      return openFileDb(options: options);
    }

    final path = await _resolveDbPath();
    final opts = SqliteConnectionOptions(
      nativePath: path,
      nativeFileName: options.nativeFileName,
      nativeTempDirectory: options.nativeTempDirectory,
      webSqliteWasmUri: options.webSqliteWasmUri,
      webWorkerUri: options.webWorkerUri,
      webDatabaseName: options.webDatabaseName,
      webVfsMode: options.webVfsMode,
      webFileName: options.webFileName,
      webCustomVfs: options.webCustomVfs,
    );
    return openFileDb(options: opts);
  }

  SqliteConnectionOptions _buildOptions() {
    final wasmUri = Uri.parse('sqlite3mc.wasm');
    return SqliteConnectionOptions(
      webSqliteWasmUri: wasmUri,
      webFileName: 'app.db',
      webVfsMode: WebVfsMode.opfs,
    );
  }

  Future<String> _resolveDbPath() async {
    if (_dbPath != null) {
      return _dbPath!;
    }

    if (_inMemory) {
      final dir = await getTemporaryDirectory();
      _dbPath = p.join(dir.path, 'app_db_temp.sqlite');
      return _dbPath!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _dbPath = p.join(dir.path, 'app.db');
    return _dbPath!;
  }
}
