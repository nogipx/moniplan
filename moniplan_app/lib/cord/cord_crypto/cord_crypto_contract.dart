import 'package:paseto_dart/paseto_dart.dart';
import 'package:rpc_dart/rpc_dart.dart';

import '_index.dart';

abstract interface class CordCryptoContract {
  static String serviceName(String tag) => 'CordCryptoContract#$tag';
  static String methodEncrypt = 'Encrypt';
  static String methodDecrypt = 'Decrypt';

  Future<CryptoData> decrypt(DecryptRequest request, {RpcContext? context});

  Future<Token> encrypt(EncryptRequest request, {RpcContext? context});
}

abstract class CordCryptoResponderBase extends RpcResponderContract
    implements CordCryptoContract {
  CordCryptoResponderBase(String tag)
    : super(
        CordCryptoContract.serviceName(tag),
        dataTransferMode: RpcDataTransferMode.zeroCopy,
      );

  @override
  void setup() {
    addUnaryMethod<DecryptRequest, CryptoData>(
      methodName: CordCryptoContract.methodDecrypt,
      handler: decrypt,
    );
    addUnaryMethod<EncryptRequest, Token>(
      methodName: CordCryptoContract.methodEncrypt,
      handler: encrypt,
    );
  }
}
