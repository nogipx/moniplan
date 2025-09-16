import 'dart:typed_data';

typedef IAppDbFactory = IAppDb Function();

abstract class IAppDb {
  Future<void> close();

  Future<void> open();

  Future<void> overwriteWithBytes({required Uint8List bytes});

  Future<Uint8List> exportBytes();
}
