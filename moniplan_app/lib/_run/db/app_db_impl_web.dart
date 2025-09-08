// filepath: lib/_run/db/app_db_impl_web.dart
// Web implementation of AppDbImpl — refactored to use connection_web helpers.

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/connection/connection_web.dart' as dbconn;
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:rpc_dart/logger.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  StreamSubscription? _listenChanges;
  RpcLogger? _log;

  @override
  MoniplanDriftDb get db => _db!;

  MoniplanDriftDb? _db;
  DatabaseConnection? _connection;
  String? _databaseName; // информативно (см. getPath)

  final bool _inMemory;

  AppDbImpl._(this._log, this._inMemory, this._databaseName);

  factory AppDbImpl({RpcLogger? log, bool inMemory = false, String? databaseName}) {
    return AppDbImpl._(log ?? RpcLogger('AppDbImpl'), inMemory, databaseName ?? 'app_db');
  }

  @override
  Future<void> open() async {
    try {
      if (_connection != null) return;

      if (_inMemory) {
        // Эфемерная БД в памяти. Подаём "пустые" байты: SQLite создаст файл при первой записи.
        final conn = await dbconn.openTempDbFromBytes(Uint8List(0));
        _connection = conn;
      } else {
        // Персистентная основная БД (OPFS/IndexedDB/fallback — решает Drift)
        final conn = await dbconn.openMainDb();
        _connection = conn;
      }

      _db = _tryConnectDb(_connection!);

      // Опционально «прогреем»: откроет соединение и прогонит миграции
      await _connection!.executor.ensureOpen(_db!);

      _startWatchChanges();
      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('open', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<void> overwriteWithBytes({required Uint8List bytes}) async {
    try {
      await _close();

      if (_inMemory) {
        // Временная (неперсистентная) БД из байт
        final conn = await dbconn.openTempDbFromBytes(bytes);
        _connection = conn;
      } else {
        // Атомарная замена персистентной БД и повторное открытие
        await dbconn.replaceMainDbFromBytes(bytes);
        _connection = await dbconn.openMainDb();
      }

      _db = _tryConnectDb(_connection!);
      await _connection!.executor.ensureOpen(_db!);

      _startWatchChanges();
      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('overwriteWithBytes', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    try {
      _stopWatchChanges();
      await _close();

      _db = null;
      _connection = null;

      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('close', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<String> getPath() async {
    // На web возвращаем «имя» (оно у нас информативное — фактическое хранение управляет Drift)
    if (_inMemory) return 'in-memory';
    return _databaseName ?? 'app_db';
  }

  // --- internals -------------------------------------------------------------

  MoniplanDriftDb _tryConnectDb(DatabaseConnection conn) {
    return MoniplanDriftDb(dbExecutor: conn.executor);
  }

  Future<void> _close() async {
    try {
      await _db?.close();
    } finally {
      await _connection?.executor.close(); // закрываем нижележащий executor
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

    _listenChanges = _db!.tableUpdates(query).listen((_) {
      _updateLastActionDate();
    });
  }

  void _stopWatchChanges() {
    _listenChanges?.cancel();
    _listenChanges = null;
  }
}
