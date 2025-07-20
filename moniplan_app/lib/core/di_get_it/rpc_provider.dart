import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpc_dart/rpc_dart.dart';

/// {@template CordCallersProvider}
/// Виджет-провайдер для RPC caller'ов, который делает их доступными в дочерних контекстах
///
/// Принимает уже настроенные Provider'ы для caller'ов, что дает полную гибкость
/// в настройке зависимостей и создании caller'ов.
///
/// Пример использования:
/// ```dart
/// CordCallersProvider(
///   providers: [
///     RepositoryProvider<EcpSigningCaller>(
///       create: (context) => EcpSigningCaller(
///         context.read<RpcCallerEndpoint>(),
///         EcpSigningId(taskId: taskId),
///       ),
///     ),
///     RepositoryProvider<LocalInventoryCompletionCaller>(
///       create: (context) => LocalInventoryCompletionCaller(
///         context.read<RpcCallerEndpoint>(),
///         LocalInventoryCompletionId(taskId: taskId, userId: userId),
///       ),
///     ),
///   ],
///   child: CordRespondersProvider(
///     responders: [
///       CordResponderConfig<EcpSigningResponder>(
///         createResponder: (context) => EcpSigningResponder(
///           // Здесь доступны caller'ы через context.caller<T>()
///           id: EcpSigningId(taskId: taskId),
///           repository: context.read<SomeRepository>(),
///         ),
///       ),
///     ],
///     child: MyApp(),
///   ),
/// );
/// ```
/// {@endtemplate}
class CordCallersProvider extends StatefulWidget {
  /// Дочерний виджет
  final Widget child;

  /// Список провайдеров для caller'ов
  final List<Provider> providers;

  /// {@macro CordCallersProvider}
  const CordCallersProvider({
    required this.child,
    required this.providers,
    super.key,
  });

  @override
  State<CordCallersProvider> createState() => _CordCallersProviderState();
}

class _CordCallersProviderState extends State<CordCallersProvider> {
  late final RpcCallerEndpoint _callerEndpoint;
  late final IRpcTransport _responderTransport;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    if (!_isInitialized) {
      _initializeEndpoint();
    }
    super.didChangeDependencies();
  }

  void _initializeEndpoint() {
    // Создаем ОДНУ пару связанных транспортов
    final (callerTransport, responderTransport) = RpcInMemoryTransport.pair();
    _callerEndpoint = RpcCallerEndpoint(transport: callerTransport);
    _responderTransport = responderTransport;
    _isInitialized = true;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _callerEndpoint.close();
      _callerEndpoint.transport.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Провайдим оба endpoint'а, чтобы они были доступны в дочерних виджетах
    return MultiProvider(
      providers: [
        Provider<RpcCallerEndpoint>.value(value: _callerEndpoint),
        Provider<IRpcTransport>.value(value: _responderTransport),
        ...widget.providers.cast<Provider>(),
      ],
      child: widget.child,
    );
  }
}

/// {@template CordRespondersProvider}
/// Виджет-провайдер для RPC responder'ов, который создает их с доступом к caller'ам из контекста
///
/// Должен использоваться внутри CordCallersProvider для доступа к caller'ам.
/// В функции createResponder доступен контекст, через который можно получить caller'ы
/// и другие зависимости из родительских провайдеров.
/// {@endtemplate}
class CordRespondersProvider extends StatefulWidget {
  /// Дочерний виджет
  final Widget child;

  /// Список конфигураций RPC responder'ов
  final List<CordResponderConfig> responders;

  /// {@macro CordRespondersProvider}
  const CordRespondersProvider({
    required this.child,
    required this.responders,
    super.key,
  });

  @override
  State<CordRespondersProvider> createState() => _CordRespondersProviderState();
}

class _CordRespondersProviderState extends State<CordRespondersProvider> {
  late final List<RpcResponderContract> _responders;
  late final RpcResponderEndpoint _responderEndpoint;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    if (!_isInitialized) {
      _initializeResponders(context);
    }
    super.didChangeDependencies();
  }

  void _initializeResponders(BuildContext context) {
    // Используем транспорт, предоставленный CordCallersProvider
    final responderTransport = context.read<IRpcTransport>();
    _responderEndpoint = RpcResponderEndpoint(transport: responderTransport);

    // Создаем responder'ы
    _responders = [];
    for (final config in widget.responders) {
      final responder = config.createResponder(context);
      _responders.add(responder);

      // Регистрируем responder в endpoint
      _responderEndpoint.registerServiceContract(responder);
    }

    // Запускаем endpoint
    _responderEndpoint.start();
    _isInitialized = true;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _responderEndpoint.close();
      _responderEndpoint.transport.close();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// {@template CordResponderConfig}
/// Конфигурация для RPC responder'а в cord-домене
/// {@endtemplate}
class CordResponderConfig<TResponder extends RpcResponderContract> {
  /// Функция создания responder'а
  final TResponder Function(BuildContext context) createResponder;

  /// {@macro CordResponderConfig}
  const CordResponderConfig({required this.createResponder});
}

/// {@template CordDomainConfig}
/// Конфигурация для RPC контракта в cord-домене (для обратной совместимости)
/// {@endtemplate}
class CordDomainConfig<
  TCaller extends RpcCallerContract,
  TResponder extends RpcResponderContract
> {
  /// Функция создания responder'а
  final TResponder Function(BuildContext context) createResponder;

  /// Функция создания caller'а
  final Provider<TCaller> callerProvider;

  /// {@macro CordDomainConfig}
  const CordDomainConfig({
    required this.createResponder,
    required this.callerProvider,
  });
}

/// {@template CordDomainProvider}
/// Виджет-провайдер для cord-доменов, который комбинирует caller'ы и responder'ы
///
/// Это удобная обертка над CordCallersProvider и CordRespondersProvider
///
/// Пример использования:
/// ```dart
/// CordDomainProvider(
///   contracts: [
///     CordDomainConfig<EcpSigningCaller, EcpSigningResponder>(
///       createResponder: (context, endpoint) => EcpSigningResponder(
///         // Здесь можно получить другие caller'ы через context.caller<T>()
///         someCaller: context.caller<SomeOtherCaller>(),
///       ),
///       createCaller: (context, endpoint) => EcpSigningCaller(endpoint: endpoint),
///     ),
///   ],
///   child: MyApp(),
/// );
/// ```
/// {@endtemplate}
class CordDomainProvider extends StatelessWidget {
  /// Дочерний виджет
  final Widget child;

  /// Список конфигураций RPC контрактов
  final List<CordDomainConfig> contracts;

  /// {@macro CordDomainProvider}
  const CordDomainProvider({
    required this.child,
    required this.contracts,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Извлекаем caller'ы и responder'ы из контрактов
    final callerProviders =
        contracts.map((config) => config.callerProvider).toList();

    final responders =
        contracts
            .map(
              (config) =>
                  CordResponderConfig(createResponder: config.createResponder),
            )
            .toList();

    return CordCallersProvider(
      providers: callerProviders,
      child: CordRespondersProvider(responders: responders, child: child),
    );
  }
}
