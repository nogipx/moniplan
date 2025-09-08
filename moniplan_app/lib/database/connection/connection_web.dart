import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

final _sqliteWasm = Uri.parse('sqlite3.wasm'); // лежит в /web
final _workerJs = Uri.parse('drift_worker.dart.js'); // лежит в /web
const _mainName = 'app_db';

/// (1) Открыть основную БД (персистентно: OPFS / IndexedDB / fallback)
Future<DatabaseConnection> openMainDb() async {
  final res = await WasmDatabase.open(
    databaseName: _mainName,
    sqlite3Uri: _sqliteWasm,
    driftWorkerUri: _workerJs,
  );
  return res.resolvedExecutor;
}

/// (2) Заменить текущую БД байтами другой БД (runtime импорт)
///
/// ВАЖНО: сначала закройте ваш AppDatabase (await db.close()).
Future<void> replaceMainDbFromBytes(Uint8List bytes) async {
  final probe = await WasmDatabase.probe(
    sqlite3Uri: _sqliteWasm,
    driftWorkerUri: _workerJs,
    databaseName: _mainName,
  );

  // удалить текущую персистентную БД (OPFS / IndexedDB)
  for (final db in probe.existingDatabases) {
    await probe.deleteDatabase(db);
  }

  // открыть заново основную БД, проинициализировав её вашими байтами
  await WasmDatabase.open(
    databaseName: _mainName,
    sqlite3Uri: _sqliteWasm,
    driftWorkerUri: _workerJs,
    initializeDatabase: () async => bytes,
  );
}

/// (3) Временная БД из байт — без персистенции (in-memory)
Future<DatabaseConnection> openTempDbFromBytes(Uint8List bytes) async {
  final probe = await WasmDatabase.probe(sqlite3Uri: _sqliteWasm, driftWorkerUri: _workerJs);

  // открываем in-memory хранилище и заливаем стартовые байты
  final conn = await probe.open(
    WasmStorageImplementation.inMemory,
    // имя произвольное (не сохраняется)
    'tmp_${DateTime.now().microsecondsSinceEpoch}',
    initializeDatabase: () async => bytes,
  );

  return conn;
}
