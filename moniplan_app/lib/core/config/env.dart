// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true, allowOptionalFields: true)
abstract class SecureEnv {
  @EnviedField(varName: 'PUBLIC_KEY')
  static String publicKey = _SecureEnv.publicKey;

  @EnviedField(varName: 'PRIVATE_KEY', optional: true)
  static String? privateKey = _SecureEnv.privateKey;

  @EnviedField(varName: 'DB_ENCRYPTION_KEY', optional: true)
  static String? dbEncryptionKey = _SecureEnv.dbEncryptionKey;
}
