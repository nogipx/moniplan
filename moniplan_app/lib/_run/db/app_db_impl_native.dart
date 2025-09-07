// filepath: lib/_run/db/app_db_impl_native.dart
// Native implementation of AppDbImpl

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/opener/universal_database_opener.dart' as opener;
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';
import 'package:moniplan_app/features/payment/_index.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  StreamSubscription? _listenChanges;
  AppLog? _log;

  @override
  MoniplanDriftDb get db => _db!;

  MoniplanDriftDb? _db;
  DatabaseConnection? _connection;
  String? _instancePath;
  bool _isInstanceFile = false;

  final bool _inMemory;
  final opener.Platform _platform = opener.Platform.native;

  AppDbImpl._(this._log, this._inMemory);

  factory AppDbImpl({AppLog? log, bool inMemory = false}) {
    return AppDbImpl._(log ?? AppLog('AppDbImpl'), inMemory);
  }

  @override
  Future<void> close() async {
    try {
      await _db?.close();
      if (_connection != null) {
        await _connection?.close();
        _connection = null;
      }
      _stopWatchChanges();

      try {
        if (_isInstanceFile && _instancePath != null) {
          final file = File(_instancePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        final tempObj = await opener.getTemporaryDatabaseFile();
        if (tempObj is File) {
          if (await tempObj.exists()) await tempObj.delete();
        }
      } catch (_) {}

      _db = null;
      _instancePath = null;
      _isInstanceFile = false;

      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('close', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> open() async {
    try {
      if (_connection != null) return;

      // Resolve file/path from opener in a robust way
      String? customPath;
      Uint8List? initialBytes;
      if (_inMemory) {
        final dbObj = await opener.getDatabaseFile();
        if (dbObj is File) {
          initialBytes = await dbObj.readAsBytes();
        }
      } else {
        final dbObj = await opener.getDatabaseFile();
        if (dbObj is File) {
          customPath = dbObj.path;
        } else if (dbObj is String) {
          customPath = dbObj;
        }
      }

      final connection = opener.UniversalDatabaseOpener.open(
        platform: _platform,
        type: _inMemory ? opener.DatabaseType.temporary : opener.DatabaseType.persistent,
        customPath: customPath,
        initialBytes: initialBytes,
      );

      _connection = connection;
      _db = MoniplanDriftDb(dbExecutor: _connection as QueryExecutor);

      if (!_inMemory) {
        _instancePath = (await opener.getDatabaseFile()).path;
        _isInstanceFile = false;
      } else {
        _instancePath = null;
        _isInstanceFile = false;
      }

      _startWatchChanges();
      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('open', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<void> overwriteWithBytes({required Uint8List bytes}) async {
    try {
      if (_inMemory) {
        await _db?.close();
        if (_connection != null) {
          await _connection?.close();
          _connection = null;
        }

        final connection = opener.UniversalDatabaseOpener.open(
          platform: _platform,
          type: opener.DatabaseType.temporary,
          initialBytes: bytes,
        );

        _connection = connection;
        _db = MoniplanDriftDb(dbExecutor: _connection as QueryExecutor);
        _startWatchChanges();
        notifyListeners();
        return;
      }

      final dbObj = await opener.getDatabaseFile();
      String dbPath;
      if (dbObj is File) {
        dbPath = dbObj.path;
      } else if (dbObj is String) {
        dbPath = dbObj;
      } else {
        throw Exception('Unsupported database file object from opener');
      }

      await opener.UniversalDatabaseOpener.overridePersistentDatabase(
        platform: _platform,
        databasePath: dbPath,
        newBytes: bytes,
      );

      await _db?.close();
      if (_connection != null) {
        await _connection?.close();
        _connection = null;
      }

      final newConnection = opener.UniversalDatabaseOpener.open(
        platform: _platform,
        type: opener.DatabaseType.persistent,
        customPath: dbPath,
      );

      _connection = newConnection;
      _db = MoniplanDriftDb(dbExecutor: _connection as QueryExecutor);
      _instancePath = dbPath;
      _isInstanceFile = false;
      _startWatchChanges();
      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('overwriteWithBytes', error: error, trace: trace);
      rethrow;
    }
  }

  Future<void> _updateLastActionDate() async {
    if (_db == null) throw Exception('Database not opened');

    final data = GlobalLastUpdateData(
      lastUpdateId: GlobalLastUpdate.entityId,
      updatedAt: DateTime.now(),
    );

    _db!.globalLastUpdate.insertOne(data, mode: InsertMode.insertOrReplace);
  }

  void _startWatchChanges() {
    if (_db == null) throw Exception('Database not opened');

    final query = TableUpdateQuery.onAllTables([
      _db!.paymentPlannersDriftTable,
      _db!.paymentsComposedDriftTable,
    ]);

    _listenChanges = _db!.tableUpdates(query).listen((updates) {
      _updateLastActionDate();
    });
  }

  void _stopWatchChanges() {
    _listenChanges?.cancel();
  }

  @override
  Future<String> getPath() async {
    if (_instancePath != null) return _instancePath!;
    if (_inMemory) return 'in-memory';
    final dbObj = await opener.getDatabaseFile();
    if (dbObj is File) return dbObj.path;
    if (dbObj is String) return dbObj;
    throw Exception('Unsupported database file object');
  }
}
