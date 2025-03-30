import 'dart:typed_data';
import '_index.dart';

abstract interface class IMonisyncDbEncrypter<T extends AppEncryptionKey> {
  abstract final IAppEncrypter encrypter;

  Future<Uint8List> encrypt(Uint8List data);

  Future<Uint8List> decrypt(Uint8List data);
}
