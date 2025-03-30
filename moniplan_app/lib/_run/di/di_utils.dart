import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<IAppEncrypter> encrypterFactory(AppEncrypterFactoryArgs? args, dynamic _) async {
  final passwordHash = await FlutterSecureStorage().read(key: 'password_hashed');
  final packageInfo = await PackageInfo.fromPlatform();
  if (args?.password != null && args!.password.isNotEmpty) {
    return Salsa20MonisyncEncrypter(PasswordEncryptionKey.fromPassword(args.password));
  }

  if (args?.forceOldEncryption == true) {
    return AesMonisyncEncrypter(MonisyncEncryptionKeyV1());
  }

  if (passwordHash == null) {
    final buildNumber = int.tryParse(packageInfo.buildNumber);
    if (buildNumber != null && buildNumber >= 32) {
      return Salsa20MonisyncEncrypter(MonisyncEncryptionKeyV2());
    }
    return AesMonisyncEncrypter(MonisyncEncryptionKeyV1());
  }
  return Salsa20MonisyncEncrypter(PasswordEncryptionKey.fromHash(passwordHash));
}
