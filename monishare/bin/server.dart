import 'dart:async';

import 'package:rpc_dart/rpc_dart.dart';

import 'package:monishare/monishare_responder.dart';

Future<void> main() async {
  final (_, serverTransport) = RpcInMemoryTransport.pair();
  final responderEndpoint = RpcResponderEndpoint(
    transport: serverTransport,
    debugLabel: 'MoniShareServer',
  );

  final service = MoniShareResponder();
  responderEndpoint.registerServiceContract(service);
  responderEndpoint.start();

  print('MoniShare responder started with in-memory transport.');

  // Держим процесс активным для демонстрации.
  await Completer<void>().future;
}
