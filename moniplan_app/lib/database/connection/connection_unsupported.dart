import 'package:drift/drift.dart';

/// (1) Открыть основную БД (персистентно: OPFS / IndexedDB / fallback)
Future<DatabaseConnection> openMainDb() async {
  throw UnimplementedError();
}

/// (2) Заменить текущую БД байтами другой БД (runtime импорт)
///
/// ВАЖНО: сначала закройте ваш AppDatabase (await db.close()).
Future<void> replaceMainDbFromBytes(Uint8List bytes) async {
  throw UnimplementedError();
}

/// (3) Временная БД из байт — без персистенции (in-memory)
Future<DatabaseConnection> openTempDbFromBytes(Uint8List bytes) async {
  throw UnimplementedError();
}
