import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'app_db.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  final bool _inMemory;
  final RpcLogger _log;

  DatabaseConnection? _connection;
  SqliteDataStorageAdapter? _storage;
  SqliteDataRepository? _repository;
  InMemoryDataServiceEnvironment? _env;
  String? _dbPath;

  AppDbImpl._(this._log, this._inMemory);

  factory AppDbImpl({RpcLogger? log, bool inMemory = false}) {
    return AppDbImpl._(log ?? RpcLogger('AppDbImpl'), inMemory);
  }

  @override
  DataServiceClient get dataService {
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
      final path = await _resolveDbPath();
      _connection = await openFileDb(
        options: SqliteConnectionOptions(nativePath: path),
      );

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
      await _close();
      final path = await _resolveDbPath();
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      await open();
    } on Object catch (error, trace) {
      _log.error('overwriteWithBytes failed', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<Uint8List> exportBytes() async {
    final path = await _resolveDbPath();
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('Database not opened');
    }
    return await file.readAsBytes();
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
