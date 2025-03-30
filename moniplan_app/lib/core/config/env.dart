// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(obfuscate: true, requireEnvFile: true)
abstract class SecureEnv {
  @EnviedField(varName: 'PUBLIC_KEY')
  static String publicKey = _SecureEnv.publicKey;

  @EnviedField(varName: 'DB_ENCRYPTION_KEY')
  static String dbEncryptionKey = _SecureEnv.dbEncryptionKey;

  @EnviedField(varName: 'DB_ENCRYPTION_KEY_OLD_1')
  static String dbEncryptionKeyOld1 = _SecureEnv.dbEncryptionKeyOld1;
}
