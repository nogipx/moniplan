import 'dart:async';
import 'dart:io';

import 'package:monishare/monishare_responder.dart';
import 'package:rpc_dart_transports/rpc_dart_transports.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> main(List<String> args) async {
  final incomingConnections = StreamController<WebSocketChannel>.broadcast();
  final port = 8081;
  RpcLogger.setDefaultMinLogLevel(RpcLoggerLevel.internal);

  final rpcServer = RpcWebSocketServer.createWithContracts(
    port: port,
    connections: incomingConnections.stream,
    logger: RpcLogger('Server'),
    contracts: [
      MoniShareResponder(),
    ],
  );
  await rpcServer.start();

  // 6) Реальный HTTP биндинг (без прямого импорта dart:io в этом файле)
  final shelfServer = await shelf_io.serve(
    const Pipeline().addHandler(webSocketHandler((WebSocketChannel ch, str) {
      incomingConnections.add(ch);
    })),
    InternetAddress.anyIPv4,
    port,
  );

  final server = RpcServerBootstrap(
    appName: 'MoniShareServer',
    server: rpcServer,
    onClose: () async {
      await incomingConnections.close();
      await shelfServer.close(force: true);
      print('Все закрыто');
    },
  );

  return await server.run(args);
}
