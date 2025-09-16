import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:licensify/licensify.dart';

import '../models/backup_info.dart';

abstract interface class IMonisyncRepo {
  String createBackupFileName(DateTime date);

  Future<void> importData({required String token, required String password});

  Future<String> exportData({required DateTime now, required String password});

  Future<BackupInfo?> readBackupInfo({required String token, String? password});
}

LicensifySymmetricKey getLicensifyPasswordKey(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return LicensifySymmetricKey.xchacha20(Uint8List.fromList(digest.bytes.take(32).toList()));
}
