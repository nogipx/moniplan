import 'package:rpc_dart/rpc_dart.dart';

/// Заготовка middleware для авторизации или дополнительного логирования.
/// По умолчанию просто прокидывает запросы и ответы без изменений.
class AuthorizationMiddleware implements IRpcMiddleware {
  AuthorizationMiddleware({this.onValidate});

  final Future<void> Function(
    String serviceName,
    String methodName,
    dynamic request,
  )? onValidate;

  @override
  Future<dynamic> processRequest(
    String serviceName,
    String methodName,
    dynamic request,
  ) async {
    if (onValidate != null) {
      await onValidate!(serviceName, methodName, request);
    }
    return request;
  }

  @override
  Future<dynamic> processResponse(
    String serviceName,
    String methodName,
    dynamic response,
  ) async {
    return response;
  }
}
