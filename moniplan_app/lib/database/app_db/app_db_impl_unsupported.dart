import 'package:flutter/widgets.dart';
import 'package:rpc_dart/rpc_dart.dart';

import '../_index.dart';

class AppDbImpl extends ChangeNotifier implements AppDb {
  // ignore: avoid_unused_constructor_parameters
  factory AppDbImpl({RpcLogger? log, bool inMemory = false}) {
    return AppDbImpl._();
  }

  AppDbImpl._();

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  MoniplanDriftDb get db => throw UnimplementedError();

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
