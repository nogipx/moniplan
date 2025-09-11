import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:moniplan_app/database/connection/connection_web.dart' as dbconn;
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:rpc_dart/logger.dart';

import '../_index.dart';

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

  /// Экспорт текущей персистентной базы как Uint8List.
  /// Требует чтобы `sqlite3.wasm` и `drift_worker.dart.js` лежали в /web и чтобы
  /// имя БД совпадало с тем, что ты используешь при open().
  Future<Uint8List> exportBytes() async {
    if (_inMemory) {
      throw UnsupportedError('Экспорт из временной (in-memory) БД в браузере не поддержан.');
    }

    final name = _databaseName ?? 'app_db';

    // Пробуем окружение и перечисляем существующие базы.
    // Важно: передаём databaseName, иначе IndexedDB-базы могут не определиться.
    final probe = await WasmDatabase.probe(
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      databaseName: name,
    );

    // existingDatabases: список (WebStorageApi, String). Ищем нашу по имени.
    final existing = probe.existingDatabases.firstWhere(
      (db) => db.$2 == name,
      orElse: () => throw StateError('База "$name" не найдена в хранилище браузера.'),
    );

    final bytes = await probe.exportDatabase(existing);
    if (bytes == null) {
      throw UnsupportedError('Текущая реализация хранилища не поддерживает экспорт.');
    }
    return bytes;
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
