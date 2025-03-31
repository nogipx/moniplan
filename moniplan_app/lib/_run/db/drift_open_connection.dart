// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<QueryExecutor> driftOpenDefault() async {
  return driftOpen(getDatabaseFile);
}

typedef SqliteFileProvider = Future<File> Function();

Future<File> getDatabaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
  return file;
}

Future<File> getTemporaryDatabaseFile() async {
  final dbFolder = await getTemporaryDirectory();
  final file = File(p.join(dbFolder.path, 'db_temporary.sqlite'));
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
  return file;
}

Future<void> driftWriteTemporary({required Uint8List bytes}) async {
  final file = await getTemporaryDatabaseFile();
  await file.writeAsBytes(bytes);
}

Future<void> driftClearTemporary() async {
  final file = await getTemporaryDatabaseFile();
  if (file.existsSync()) {
    await file.delete();
  }
}

Future<QueryExecutor> driftOpen(SqliteFileProvider dbFileProvider) async {
  // the LazyDatabase util lets us find the right location for the file async.

  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final file = await dbFileProvider();

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}

Future<QueryExecutor> driftOpenInMemory(Uint8List bytes) async {
  return LazyDatabase(() async {
    await driftWriteTemporary(bytes: bytes);
    final file = await getTemporaryDatabaseFile();
    final reference = sqlite3.open(file.path);
    final copy = sqlite3.openInMemory();
    await reference.backup(copy).drain();
    return NativeDatabase.opened(copy);
  });
}
