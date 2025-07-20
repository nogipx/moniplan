import '_index.dart';
import 'package:paseto_dart/models/token.dart';
import 'package:rpc_dart/rpc_dart.dart';

class CordCryptoCaller extends RpcCallerContract implements CordCryptoContract {
  CordCryptoCaller(RpcCallerEndpoint endpoint, {String tag = ''})
    : super(CordCryptoContract.serviceName(tag), endpoint);

  @override
  Future<CryptoData> decrypt(DecryptRequest request, {RpcContext? context}) {
    return callUnary(
      methodName: CordCryptoContract.methodDecrypt,
      request: request,
    );
  }

  @override
  Future<Token> encrypt(EncryptRequest request, {RpcContext? context}) {
    return callUnary(
      methodName: CordCryptoContract.methodEncrypt,
      request: request,
    );
  }
}
