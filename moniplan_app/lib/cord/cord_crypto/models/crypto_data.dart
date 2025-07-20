import 'dart:convert';

import 'package:paseto_dart/paseto_dart.dart';
import 'package:rpc_dart/rpc_dart.dart';

extension TokenX on Token {
  Map<String, dynamic> get parsedFooter {
    if (footer == null || footer!.isEmpty) {
      return {};
    }
    return jsonDecode(utf8.decode(footer!));
  }

  bool get hasPassword => parsedFooter['hasPassword'] ?? false;
}

class CryptoData implements IRpcSerializable {
  final String appId;
  final Uint8List data;
  final Map<String, dynamic> metadata;

  CryptoData({
    required this.appId,
    required this.data,
    this.metadata = const {},
  });

  bool? get hasPassword => metadata['hasPassword'];

  factory CryptoData.fromJson(Map<String, dynamic> json) {
    final appId = json['appId'] as String? ?? '';
    final data = Uint8List.fromList(base64Decode(json['bytes']));

    final metadataJson = json['_footer'] ?? json['metadata'] ?? '{}';
    final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;

    return CryptoData(appId: appId, data: data, metadata: metadata);
  }

  CryptoData withPassword(bool hasPassword) {
    return CryptoData(
      appId: appId,
      data: data,
      metadata: {...metadata, 'hasPassword': hasPassword},
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'bytes': base64Encode(data),
      'metadata': jsonEncode(metadata),
    };
  }
}
