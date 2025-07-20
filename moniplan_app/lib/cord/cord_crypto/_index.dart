import 'dart:typed_data';
import '_index.dart';

export 'models/crypto_data.dart';
export 'models/password_key.dart';
export 'requests/encrypt_decrypt_request.dart';

export 'cord_crypto_contract.dart';
export 'cord_crypto_responder.dart';

void main(List<String> args) async {
  final r = CordCryptoResponder(tag: 'version');

  final t = await r.encrypt(
    EncryptRequest(
      password: 'test123',
      data: CryptoData(
        appId: 'appId',
        data: Uint8List.fromList('chchchch'.codeUnits),
      ),
    ),
  );

  print(t.parsedFooter);
  print(t.hasPassword);

  final d = await r.decrypt(DecryptRequest(token: t, password: 'test123'));
  print(String.fromCharCodes(d.data));
}
