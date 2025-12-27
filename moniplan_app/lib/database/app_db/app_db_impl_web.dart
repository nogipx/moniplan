import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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

  AppDbImpl._(this._log, this._inMemory);

  factory AppDbImpl({RpcLogger? log, bool inMemory = false, String? databaseName}) {
    databaseName; // unused but kept for API compatibility
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
      if (_inMemory) {
        // Web storage is in-memory by default; flag retained for API parity.
      }
      _connection = await openFileDb(); // web implementation is in-memory
      _storage = SqliteDataStorageAdapter.connection(
        _connection!,
        isInMemory: true,
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
    final client = _env?.client;
    if (client == null) {
      throw StateError('Database not opened');
    }
    final export = await client.exportDatabase();
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
}
