import 'package:moniplan_app/core/env/env.dart';

import 'app_encryption_key.dart';

final class MonisyncEncryptionKeyV2 extends AppEncryptionKey {
  @override
  String get id => 'salsa20_db_v2';

  @override
  String get rawValue => SecureEnv.dbEncryptionKey;
}
