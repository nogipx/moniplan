import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

@Deprecated('For backward compatibility with AES encryption. Not used anymore.')
final class MonisyncEncryptionKeyV1 extends AppEncryptionKey {
  const MonisyncEncryptionKeyV1();

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
