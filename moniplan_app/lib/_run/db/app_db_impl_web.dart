// filepath: lib/_run/db/app_db_impl_web.dart
// Web implementation of AppDbImpl

import 'dart:async';

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
  String? _databaseName;

  final bool _inMemory;
  final opener.Platform _platform = opener.Platform.web;

  AppDbImpl._(this._log, this._inMemory, this._databaseName);

  factory AppDbImpl({AppLog? log, bool inMemory = false, String? databaseName}) {
    return AppDbImpl._(log ?? AppLog('AppDbImpl'), inMemory, databaseName ?? 'app_db');
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

      _db = null;
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

      final connection = opener.UniversalDatabaseOpener.open(
        platform: _platform,
        type: _inMemory ? opener.DatabaseType.temporary : opener.DatabaseType.persistent,
        databaseName: _databaseName ?? 'app_db',
        initialBytes: null,
      );

      _connection = connection;
      _db = MoniplanDriftDb(dbExecutor: _connection as QueryExecutor);

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

      final name = _databaseName ?? 'app_db';

      await opener.UniversalDatabaseOpener.overridePersistentDatabase(
        platform: _platform,
        databasePath: name,
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
        databaseName: name,
      );

      _connection = newConnection;
      _db = MoniplanDriftDb(dbExecutor: _connection as QueryExecutor);
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
    if (_inMemory) return 'in-memory';
    return _databaseName ?? 'app_db';
  }
}
