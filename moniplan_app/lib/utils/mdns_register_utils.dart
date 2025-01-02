// import 'dart:io';
// import 'dart:math';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:lan_messaging/lan_messaging.dart';
// import 'package:moniplan_core/moniplan_core.dart';
//
// Future<MDnsRegisterPacket?> registerMDns({
//   int? customTargetPort,
//   required String serviceType,
//   String? customTargetHostname,
//   InternetAddress? customTargetAddress,
// }) async {
//   try {
//     return await _registerMDns(
//       serviceType: serviceType,
//       customTargetPort: customTargetPort,
//       customTargetAddress: customTargetAddress,
//       customTargetHostname: customTargetHostname,
//     );
//   } on Object catch (e) {
//     print('Error while register mDNS: \n$e');
//     return null;
//   }
// }
//
// Future<MDnsRegisterPacket?> _registerMDns({
//   required String serviceType,
//   int? customTargetPort,
//   String? customTargetHostname,
//   InternetAddress? customTargetAddress,
// }) async {
//   final targetAddress =
//       customTargetAddress ?? (await MDnsRegistrarExt.availableLocalAddresses).firstOrNull;
//   if (targetAddress == null) {
//     throw ArgumentError.notNull('targetAddress');
//   }
//
//   final info = await DeviceInfoPlugin().deviceInfo;
//   final serviceName = await getDeviceServiceName(info);
//
//   final targetPort = customTargetPort ?? await generateAvailablePort(min: 10000);
//   final targetHostname = customTargetHostname ?? serviceName;
//
//   final registrar = MDnsRegistrar(
//     serviceName: serviceName,
//     serviceType: serviceType,
//     targetPort: targetPort,
//     targetHostname: targetHostname,
//     targetHost: targetAddress,
//   );
//
//   await registrar.start();
//
//   return registrar.registerPacket;
// }
//
// Future<String> getDeviceServiceName(BaseDeviceInfo info) async {
//   final id = const Uuid().v4();
//   var serviceName = 'unknown_$id';
//
//   if (info is AndroidDeviceInfo) {
//     serviceName = '${info.model}_$id';
//   } else if (info is IosDeviceInfo) {
//     serviceName = '${info.model}_$id';
//   } else if (info is WebBrowserInfo) {
//     serviceName = '${info.userAgent}_$id';
//   } else if (info is MacOsDeviceInfo) {
//     serviceName = '${info.model}_$id';
//   } else if (info is WindowsDeviceInfo) {
//     serviceName = '${info.productName}_$id';
//   } else if (info is LinuxDeviceInfo) {
//     serviceName = '${info.name}_$id';
//   }
//
//   serviceName = serviceName.replaceAll(RegExp(r'[^\w\-]'), '_').toLowerCase();
//
//   return serviceName;
// }
//
// Future<int> generateAvailablePort({int min = 10000, int max = 65535}) async {
//   final random = Random();
//
//   Future<bool> isPortAvailable(int port) async {
//     try {
//       final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
//       await server.close();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   while (true) {
//     final port = min + random.nextInt(max - min + 1);
//     if (await isPortAvailable(port)) {
//       return port;
//     }
//   }
// }
