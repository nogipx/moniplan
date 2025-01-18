// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> getTemporaryDatabaseFile() async {
  final dbFolder = await getTemporaryDirectory();
  final file = File(p.join(dbFolder.path, 'db_temporary.sqlite'));
  return file;
}

QueryExecutor driftOpenTemporary({required Uint8List bytes}) {
  return LazyDatabase(() async {
    final file = await getTemporaryDatabaseFile();
    await file.writeAsBytes(bytes);
    return NativeDatabase.createBackgroundConnection(file);
  });
}

Future<void> driftClearTemporary() async {
  final file = await getTemporaryDatabaseFile();
  if (file.existsSync()) {
    await file.delete();
  }
}
