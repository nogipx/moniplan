import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as s3;

/// Путь к основной базе на девайсе.
Future<File> _mainDbFile() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'app.db'));
  return file;
}

/// (1) Открыть основную БД
Future<DatabaseConnection> openMainDb() async {
  final file = await _mainDbFile();
  // создаст файл при первом запуске
  return DatabaseConnection(NativeDatabase(file));
}

/// (2) Заменить текущую БД байтами другой БД (runtime импорт)
///
/// ВАЖНО: сначала закройте ваш AppDatabase (await db.close()).
Future<void> replaceMainDbFromBytes(Uint8List bytes) async {
  final target = await _mainDbFile();

  // пишем пришедшие байты во временный файл
  final tmp = File('${target.path}.import.tmp');
  await tmp.parent.create(recursive: true);
  await tmp.writeAsBytes(bytes, flush: true);

  // используем sqlite3 и VACUUM INTO — рекомендуемый путь для импорта
  final backupDb = s3.sqlite3.open(tmp.path);
  try {
    // цель должна быть перезаписана "правильным" способом
    backupDb.execute('VACUUM INTO ?', [target.path]);
  } finally {
    backupDb.dispose();
    if (tmp.existsSync()) {
      await tmp.delete();
    }
  }
  // после этого заново откройте AppDatabase поверх openMainDb().
}

/// (3a) Временная БД из байт — через временный файл (просто и надежно)
Future<DatabaseConnection> openTempDbFromBytes(Uint8List bytes) async {
  final dir = await getTemporaryDirectory();
  final tmp = File(p.join(dir.path, 'temp_${DateTime.now().microsecondsSinceEpoch}.db'));
  await tmp.writeAsBytes(bytes, flush: true);
  // Ваша ответственность — потом удалить tmp после db.close()
  return DatabaseConnection(NativeDatabase(tmp));
}

/// (3b) Временная БД из байт — полностью в памяти (без файла)
Future<DatabaseConnection> openInMemoryDbFromBytes(Uint8List bytes) async {
  // грузим из байт во временный файл, затем копируем в память через backup API
  final dir = await getTemporaryDirectory();
  final tmp = File(p.join(dir.path, 'import_${DateTime.now().microsecondsSinceEpoch}.db'));
  await tmp.writeAsBytes(bytes, flush: true);

  final src = s3.sqlite3.open(tmp.path);
  final dst = s3.sqlite3.openInMemory();
  try {
    // копируем содержимое src -> dst
    await for (final _ in src.backup(dst)) {
      /* no-op, просто дождаться */
    }
    // создаем Drift-экзекутор поверх уже открытой in-memory базы
    return DatabaseConnection(NativeDatabase.opened(dst));
  } finally {
    src.dispose();
    if (tmp.existsSync()) {
      await tmp.delete();
    }
  }
}
