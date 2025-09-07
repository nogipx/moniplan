// filepath: lib/_run/db/app_db_impl_unsupported.dart
// Fallback stub for AppDbImpl when neither native nor web implementation is available.

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:moniplan_app/core/drift/app_db.dart';
import 'package:moniplan_app/core/drift/drift_database.dart';
import 'package:moniplan_app/domain/lib/log.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  AppDbImpl._();

  factory AppDbImpl({AppLog? log, bool inMemory = false}) {
    return AppDbImpl._();
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  // TODO: implement db
  MoniplanDriftDb get db => throw UnimplementedError();

  @override
  Future<String> getPath() {
    // TODO: implement getPath
    throw UnimplementedError();
  }

  @override
  Future<void> open() {
    // TODO: implement open
    throw UnimplementedError();
  }

  @override
  Future<void> overwriteWithBytes({required Uint8List bytes}) {
    // TODO: implement overwriteWithBytes
    throw UnimplementedError();
  }
}

Future<void> getPath() async => throw UnsupportedError('AppDbImpl is unsupported on this platform');
