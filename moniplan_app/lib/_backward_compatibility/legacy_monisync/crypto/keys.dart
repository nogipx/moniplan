import 'package:moniplan_app/core/env/env.dart';

import 'app_encryption_key.dart';

@Deprecated('For backward compatibility with AES encryption. Not used anymore.')
final class OldMockedEncryptionKey extends AppEncryptionKey {
  const OldMockedEncryptionKey();

  @override
  String get id => 'aes_db_mocked_v1';

  @override
  String get rawValue => 'J33L06KoJbO1okTNJ1sHNV1DS5UiVtLPLmWn0RZbxGk=';
}

@Deprecated('For backward compatibility with AES encryption. Not used anymore.')
final class OldEnviedEncryptionKey extends AppEncryptionKey {
  const OldEnviedEncryptionKey();

  @override
  String get id => 'aes_db_v1';

  @override
  String get rawValue => SecureEnv.dbEncryptionKeyOld1;
}

final class MonisyncEncryptionKeyV2 extends AppEncryptionKey {
  @override
  String get id => 'salsa20_db_v2';

  @override
  String get rawValue => SecureEnv.dbEncryptionKey;
}
