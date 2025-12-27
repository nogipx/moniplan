import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:rpc_dart/logger.dart';
import 'package:rpc_dart_data/rpc_dart_data.dart';

import 'app_db.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  // ignore: avoid_unused_constructor_parameters
  factory AppDbImpl({RpcLogger? log, bool inMemory = false}) {
    return AppDbImpl._();
  }

  AppDbImpl._();

  @override
  DataServiceClient get dataService => throw UnsupportedError('Not supported on this platform');

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> open() {
    throw UnimplementedError();
  }

  @override
  Future<void> overwriteWithBytes({required Uint8List bytes}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> exportBytes() {
    throw UnimplementedError();
  }
}
