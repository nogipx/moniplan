import '../_index.dart';
import 'package:paseto_dart/models/token.dart';

class EncryptRequest {
  final CryptoData data;
  final String? password;

  EncryptRequest({required this.data, this.password});
}

class DecryptRequest {
  final Token token;
  final String? password;

  DecryptRequest({required this.token, this.password});
}
