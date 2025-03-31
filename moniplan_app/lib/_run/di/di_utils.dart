import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<IAppEncrypter> encrypterFactory(AppEncrypterFactoryArgs? args, dynamic _) async {
  final enableMetadata = args?.enableMetadata ?? true;
  final preferNewEncryption = args?.preferNewEncryption ?? true;
  final forceUseSavedPassword = args?.forceUseSavedPassword ?? false;
  final forceUseLegacyEncryption = args?.forceUseLegacyEncryption ?? false;
  final packageInfo = await PackageInfo.fromPlatform();
  final buildNumber = int.tryParse(packageInfo.buildNumber);

  /// Если пользователь запросил использование старого алгоритма шифрования,
  /// используем его
  if (forceUseLegacyEncryption) {
    return AesMonisyncEncrypter(OldMockedEncryptionKey(), enableMetadata: enableMetadata);
  }

  /// Если версия приложения меньше или равна 32,
  /// и пользователь не запросил использование нового алгоритма шифрования,
  /// используем старый алгоритм
  if (buildNumber != null && buildNumber <= 32 && !preferNewEncryption) {
    return AesMonisyncEncrypter(OldEnviedEncryptionKey(), enableMetadata: enableMetadata);
  }

  /// Если пользователь передал пароль, используем его
  if (args?.password != null && args!.password.isNotEmpty) {
    return Salsa20MonisyncEncrypter(
      PasswordEncryptionKey.fromPassword(args.password),
      enableMetadata: enableMetadata,
    );
  }

  final passwordHash = await FlutterSecureStorage().read(key: 'password_hashed');

  /// Если пользователь запросил использование сохраненного пароля,
  /// и он существует, используем его
  if (forceUseSavedPassword && passwordHash != null) {
    return Salsa20MonisyncEncrypter(
      PasswordEncryptionKey.fromHash(passwordHash),
      enableMetadata: enableMetadata,
    );
  }

  if (passwordHash != null) {
    return Salsa20MonisyncEncrypter(
      PasswordEncryptionKey.fromHash(passwordHash),
      enableMetadata: enableMetadata,
    );
  }

  /// Иначе используем новый алгоритм
  return Salsa20MonisyncEncrypter(MonisyncEncryptionKeyV2(), enableMetadata: enableMetadata);
}
