import 'package:licensify/licensify.dart';
import 'package:paseto_dart/paseto_dart.dart';
import 'package:rpc_dart/rpc_dart.dart';

import '_index.dart';

class CordCryptoResponder extends CordCryptoResponderBase {
  final Future<LicensifySymmetricKey> Function()? encryptionKeyProvider;
  final String? implicitAssertion;

  CordCryptoResponder({
    this.encryptionKeyProvider,
    this.implicitAssertion,
    String tag = '',
  }) : super(tag);

  @override
  Future<CryptoData> decrypt(
    DecryptRequest request, {
    RpcContext? context,
  }) async {
    final password = request.password;
    final isPassswordExists = password?.isNotEmpty == true;
    final key =
        isPassswordExists
            ? PasswordEncryptionKey.fromPassword(password!).licensifyKey
            : await encryptionKeyProvider?.call();

    if (key == null) {
      throw RpcException('Cannot decrypt without key');
    }

    final decrypted = await Licensify.decryptData(
      encryptedToken: request.token.toTokenString,
      encryptionKey: key,
    );
    key.dispose();

    final result = CryptoData.fromJson(decrypted);
    return result;
  }

  @override
  Future<Token> encrypt(EncryptRequest request, {RpcContext? context}) async {
    final password = request.password;
    final isPassswordExists = password?.isNotEmpty == true;
    final key =
        isPassswordExists
            ? PasswordEncryptionKey.fromPassword(password!).licensifyKey
            : await encryptionKeyProvider?.call();

    if (key == null) {
      throw RpcException('Cannot encrypt without key');
    }

    final json =
        (isPassswordExists ? request.data.withPassword(true) : request.data)
            .toJson();

    final metadata = json.remove('metadata');

    final result = await Licensify.encryptData(
      data: json,
      encryptionKey: key,
      footer: metadata,
      implicitAssertion: implicitAssertion,
    );
    key.dispose();
    return Token.fromString(result);
  }
}
