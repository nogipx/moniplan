// filepath: lib/_run/db/app_db_impl_unsupported.dart
// Fallback stub for AppDbImpl when neither native nor web implementation is available.

import 'package:flutter/widgets.dart';
import 'package:moniplan_app/core/drift/app_db.dart';
import 'package:moniplan_app/core/drift/drift_database.dart';
import 'package:rpc_dart/rpc_dart.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  AppDbImpl._();

  factory AppDbImpl({RpcLogger? log, bool inMemory = false}) {
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
