import 'dart:io';

/// Возвращает свободный TCP-порт, выделенный ОС (эпhemeral).
/// По умолчанию ищет на 127.0.0.1 (loopback IPv4).
Future<int> getEphemeralPort({InternetAddress? address}) async {
  final addr = address ?? InternetAddress.loopbackIPv4;
  final server = await ServerSocket.bind(addr, 0, shared: false);
  final port = server.port;
  await server.close();
  return port;
}

/// Возвращает хост, на котором разумно запускать локальный сервер.
/// Логика:
/// 1. Если задана переменная окружения HOST — вернуть её.
/// 2. Попытаться выбрать первый нормальный IPv4-адрес сетевого интерфейса
///    (исключая loopback и link-local 169.254.x.x).
/// 3. В качестве запасного варианта вернуть loopback (127.0.0.1).
Future<String> getRunningHost() async {
  // 1) Переменная окружения имеет приоритет
  final envHost = Platform.environment['HOST'];
  if (envHost != null && envHost.isNotEmpty) {
    return envHost;
  }

  // 2) Попытаться получить первый подходящий IPv4-адрес интерфейса
  try {
    final interfaces = await NetworkInterface.list(includeLoopback: false);
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          final a = addr.address;
          // Пропускаем link-local 169.254.x.x
          if (a.startsWith('169.254.')) continue;
          // Пропускаем адреса 0.0.0.0 и прочие явно некорректные
          if (a == '0.0.0.0') continue;
          return a;
        }
      }
    }
  } catch (_) {
    // ignore и перейдём к fallback
  }

  // 3) Fallback — localhost
  return InternetAddress.loopbackIPv4.address;
}
