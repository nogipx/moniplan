import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

import '_index.dart';

class AppEncrypterFactoryArgs {
  final bool forceOldEncryption;
  final String password;

  const AppEncrypterFactoryArgs({this.forceOldEncryption = false, this.password = ''});
}

abstract base class IAppEncrypter {
  static const encryptMarker = 'ENCRYPTED:';
  static final encryptMarkerBytes = Uint8List.fromList(encryptMarker.codeUnits);

  Uint8List get getEncryptMarkerBytes =>
      enableEncryptionMarker ? encryptMarkerBytes : Uint8List.fromList([]);

  final AppEncryptionKey key;
  final bool enableEncryptionMarker;

  const IAppEncrypter(this.key, {this.enableEncryptionMarker = false});

  /// Must be called in end of the overriden method to add encryption marker
  @mustCallSuper
  Uint8List encryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    if (enableEncryptionMarker) {
      return Uint8List.fromList(getEncryptMarkerBytes + bytes);
    }
    return bytes;
  }

  /// Must be called in start of the overriden method to remove encryption marker
  @mustCallSuper
  Uint8List decryptBytes(Uint8List bytes, {Map<String, dynamic>? options}) {
    if (enableEncryptionMarker) {
      return bytes.sublist(0, getEncryptMarkerBytes.length);
    }
    return bytes;
  }
}
