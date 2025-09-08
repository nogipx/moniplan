// filepath: lib/_run/db/app_db_impl_native.dart
// Native implementation of AppDbImpl — refactored to use connection_native helpers.

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/database/connection/connection_native.dart' as dbconn;
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rpc_dart/logger.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  StreamSubscription? _listenChanges;
  RpcLogger? _log;

  @override
  MoniplanDriftDb get db => _db!;

  MoniplanDriftDb? _db;
  DatabaseConnection? _connection; // держим connection, из него берём executor
  String? _instancePath;

  final bool _inMemory;

  AppDbImpl._(this._log, this._inMemory);

  factory AppDbImpl({RpcLogger? log, bool inMemory = false}) {
    return AppDbImpl._(log ?? RpcLogger('AppDbImpl'), inMemory);
  }

  @override
  Future<void> open() async {
    try {
      if (_connection != null) return;

      if (_inMemory) {
        // пустая временная БД в памяти
        final executor = NativeDatabase.memory();
        _connection = DatabaseConnection(executor);
      } else {
        // персистентная основная БД
        final conn = await dbconn.openMainDb();
        _connection = conn;

        // сохраним путь к файлу (должен совпадать с logic в connection_native)
        _instancePath = await _resolvePersistentDbPath();
      }

      // Создаём Drift-DB. Предпочтительно — через .connect(...)
      // Если у твоего класса нет конструктора .connect, используй executor:
      //   _db = MoniplanDriftDb(dbExecutor: _connection!.executor);
      _db = _tryConnectDb(_connection!);

      // Опционально «прогреем» БД (откроет и прогонит миграции)
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
      // Закрываем текущую
      await _close();

      if (_inMemory) {
        // Временная БД из байт (полностью в памяти)
        final conn = await dbconn.openInMemoryDbFromBytes(bytes);
        _connection = conn;
        _db = _tryConnectDb(conn);
        await _connection!.executor.ensureOpen(_db!);
        _instancePath = null; // in-memory
      } else {
        // Заменяем основную БД атомарно
        await dbconn.replaceMainDbFromBytes(bytes);
        // И открываем заново основную
        final conn = await dbconn.openMainDb();
        _connection = conn;
        _db = _tryConnectDb(conn);
        await _connection!.executor.ensureOpen(_db!);
        _instancePath = await _resolvePersistentDbPath();
      }

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
      _instancePath = null;

      notifyListeners();
    } on Object catch (error, trace) {
      _log?.critical('close', error: error, stackTrace: trace);
      rethrow;
    }
  }

  @override
  Future<String> getPath() async {
    if (_inMemory) return 'in-memory';
    if (_instancePath != null) return _instancePath!;
    return _resolvePersistentDbPath();
  }

  // --- internals -------------------------------------------------------------

  MoniplanDriftDb _tryConnectDb(DatabaseConnection conn) {
    // fallback: используем executor-подпись
    return MoniplanDriftDb(dbExecutor: conn.executor);
  }

  Future<void> _close() async {
    try {
      await _db?.close();
    } finally {
      // Закрываем нижележащий executor (файл/память)
      await _connection?.executor.close();
    }
  }

  Future<String> _resolvePersistentDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    // имя должно совпадать с connection_native.dart
    return p.join(dir.path, 'app.db');
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
