// ignore_for_file: prefer_collection_literals

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:rpc_dart/logger.dart';
import 'package:uuid/uuid.dart';

import '../repo/_index.dart';
import '../usecases/_index.dart';
import 'planner_event.dart';
import 'planner_state.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final IPlannersRepo _plannersRepo;
  final IPaymentsRepo _paymentsRepo;
  final IPlannerActualInfoRepo _actualInfoRepo;
  final String plannerId;
  final _log = RpcLogger('PlannerBloc');

  // Переменные для дебаунса
  DateTime? _lastSaveTime;
  static const _debounceTime = Duration(seconds: 5);

  // Переменные для кэширования
  List<Payment>? _cachedPayments;
  Planner? _cachedPlanner;
  DateTime? _lastPaymentsLoadTime;
  DateTime? _lastPlannerLoadTime;
  static const _cacheValidTime = Duration(seconds: 2);

  // Флаг для отслеживания, идет ли сейчас загрузка данных
  bool _isLoading = false;

  // Переменные для кэширования результатов вычислений
  PlannerState? _cachedState;
  String? _cachedStateHash;

  // Переменные для отслеживания обновлений actualInfo
  DateTime? _lastActualInfoUpdateTime;
  static const _actualInfoUpdateInterval = Duration(seconds: 10);
  String? _lastActualInfoHash;

  PlannerBloc({
    required this.plannerId,
    required IPlannersRepo plannersRepo,
    required IPaymentsRepo paymentsRepo,
    required IPlannerActualInfoRepo actualInfoRepo,
  }) : _plannersRepo = plannersRepo,
       _paymentsRepo = paymentsRepo,
       _actualInfoRepo = actualInfoRepo,
       super(const PlannerInitialState()) {
    on<PlannerComputeBudgetEvent>(_onCompute, transformer: droppable());

    on<PlannerEvent>(
      (e, emit) => switch (e) {
        PlannerUpdatePaymentEvent() => _onUpdatePayment(e, emit),
        PlannerDeletePaymentEvent() => _onDeletePayment(e, emit),
        PlannerFixateRepeatedPaymentEvent() => _onFixateRepeatedPayment(
          e,
          emit,
        ),
        _ => emit(state),
      },
      transformer: sequential(),
    );
  }

  // Метод для получения платежей с кэшированием
  Future<List<Payment>> _getPaymentsWithCache() async {
    final now = DateTime.now();

    // Проверяем, есть ли кэш и не устарел ли он
    if (_cachedPayments != null &&
        _lastPaymentsLoadTime != null &&
        now.difference(_lastPaymentsLoadTime!) < _cacheValidTime) {
      _log.debug(
        'Используем кэшированные платежи (возраст кэша: ${now.difference(_lastPaymentsLoadTime!).inMilliseconds} мс)',
      );
      return _cachedPayments!;
    }

    // Если уже идет загрузка, ждем ее завершения
    if (_isLoading) {
      _log.debug('Загрузка платежей уже идет, ждем...');
      // Ждем небольшую паузу и проверяем снова
      await Future.delayed(const Duration(milliseconds: 100));
      return _getPaymentsWithCache();
    }

    // Загружаем платежи
    _isLoading = true;
    _log.debug('Загружаем платежи из базы данных');
    try {
      final payments = await _paymentsRepo.listByPlanner(plannerId);

      // Обновляем кэш
      _cachedPayments = payments;
      _lastPaymentsLoadTime = now;

      _log.debug('Платежи загружены и кэшированы (${payments.length} шт.)');
      return payments;
    } finally {
      _isLoading = false;
    }
  }

  // Метод для получения планера с кэшированием
  Future<Planner?> _getPlannerWithCache() async {
    final now = DateTime.now();

    // Проверяем, есть ли кэш и не устарел ли он
    if (_cachedPlanner != null &&
        _lastPlannerLoadTime != null &&
        now.difference(_lastPlannerLoadTime!) < _cacheValidTime) {
      _log.debug(
        'Используем кэшированный планер (возраст кэша: ${now.difference(_lastPlannerLoadTime!).inMilliseconds} мс)',
      );
      return _cachedPlanner;
    }

    // Загружаем планер
    _log.debug('Загружаем планер из базы данных');
    final planner = await _plannersRepo.getById(plannerId);

    // Обновляем кэш
    _cachedPlanner = planner;
    _lastPlannerLoadTime = now;

    _log.debug('Планер загружен и кэширован');
    return planner;
  }

  // Метод для инвалидации кэша
  void _invalidateCache() {
    _log.warning('Инвалидация кэша');
    _cachedPayments = null;
    _cachedPlanner = null;
    _lastPaymentsLoadTime = null;
    _lastPlannerLoadTime = null;
    _cachedState = null;
    _cachedStateHash = null;
    _lastActualInfoHash = null;
    // Не сбрасываем _lastActualInfoUpdateTime, чтобы сохранить интервал между обновлениями
  }

  // Метод для вычисления хэша состояния
  String _computeStateHash(Planner planner) {
    final paymentsHash = planner.payments
        .map(
          (p) => '${p.paymentId}:${p.isDone}:${p.isEnabled}:${p.date.millisecondsSinceEpoch}',
        )
        .join(',');
    return '${planner.id}:${planner.dateStart.millisecondsSinceEpoch}:${planner.dateEnd.millisecondsSinceEpoch}:$paymentsHash';
  }

  FutureOr<void> _onCompute(
    PlannerComputeBudgetEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final id = plannerId;
    final payments = await _getPaymentsWithCache();
    final planner = await _getPlannerWithCache();

    if (planner != null) {
      final newState = await _computeStateFromPlanner(
        planner.copyWith(payments: payments),
      );

      emit(newState.copyWith(plannerId: id));
    }
  }

  FutureOr<void> _onUpdatePayment(
    PlannerUpdatePaymentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    try {
      // Проверяем, можно ли применить обновление
      final canApplyUpdate = CheckPaymentCanApplyUpdate(
        updatedPayment: event.newPayment,
      ).run();
      if (!canApplyUpdate.canUpdate) {
        emit(state.copyWith(errors: canApplyUpdate.errorKeys));
        return;
      }

      // Подготавливаем платеж для сохранения
      final paymentToSave = event.newPayment.copyWith(
        // dateStart больше не нужен, поскольку больше не генерируем платежи прошлого
        dateStart: null,
      );

      // Сохраняем платеж с повторными попытками в случае ошибки
      Payment? result;
      var retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          // Сохраняем платеж
          final existing = await _paymentsRepo.getById(
            plannerId: plannerId,
            paymentId: paymentToSave.paymentId,
          );
          if (existing == null && !event.create) {
            throw Exception(
              'Payment "${paymentToSave.paymentId}" is not linked with Planner "$plannerId"',
            );
          }
          await _paymentsRepo.upsert(
            plannerId: plannerId,
            payment: paymentToSave,
          );
          result = paymentToSave;
          _log.info('Платеж успешно сохранен: ${result.paymentId}');
          break;
        } on Object catch (e) {
          _log.error(
            'Ошибка при сохранении платежа (попытка ${retryCount + 1}/$maxRetries): $e',
          );
        }

        // Увеличиваем счетчик попыток
        retryCount++;

        // Если достигнуто максимальное количество попыток, выбрасываем исключение
        if (retryCount >= maxRetries) {
          throw Exception(
            'Не удалось сохранить платеж после $maxRetries попыток',
          );
        }

        // Ждем перед следующей попыткой с экспоненциальной задержкой
        await Future.delayed(Duration(milliseconds: 200 * (1 << retryCount)));
      }

      if (result != null) {
        // Инвалидируем кэш после успешного сохранения платежа
        _invalidateCache();

        // Добавляем задержку перед вычислением бюджета,
        // чтобы дать базе данных время на завершение операции сохранения
        await Future.delayed(const Duration(milliseconds: 500));

        // Вычисляем бюджет
        await _onCompute(const PlannerComputeBudgetEvent(), emit);
      } else {
        // Если результат null, значит сохранение не удалось
        emit(state.copyWith(errors: {'Не удалось сохранить платеж'}));
      }
    } on Object catch (e) {
      _log.error('Ошибка при обновлении платежа: $e');
      emit(state.copyWith(errors: {'Ошибка при обновлении платежа: $e'}));
    }
  }

  FutureOr<void> _onDeletePayment(
    PlannerDeletePaymentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    await _paymentsRepo.delete(
      plannerId: plannerId,
      paymentId: event.paymentId,
    );

    // Инвалидируем кэш после удаления платежа
    _invalidateCache();

    await _onCompute(const PlannerComputeBudgetEvent(), emit);
  }

  Future<void> _onFixateRepeatedPayment(
    PlannerFixateRepeatedPaymentEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final payment = await _paymentsRepo.getById(
      plannerId: plannerId,
      paymentId: event.paymentId,
    );
    if (payment == null || payment.plannerId != plannerId) {
      throw Exception(
        'Cannot find payment with id "${event.paymentId}" in planner "$plannerId"',
      );
    }
    if (!payment.isRepeatParent) {
      throw Exception('Payment should be repeated and parent');
    }

    final copiedPayment = payment.copyWith(
      paymentId: const Uuid().v4(),
      repeat: DateTimeRepeat.noRepeat,
      dateStart: null,
      dateEnd: null,
    );
    final updatedOriginalPayment = payment.copyWith(
      date: payment.repeat.next(payment.date),
    );

    await _paymentsRepo.upsert(
      plannerId: plannerId,
      payment: copiedPayment.copyWith(plannerId: plannerId),
    );
    await _paymentsRepo.upsert(
      plannerId: plannerId,
      payment: updatedOriginalPayment,
    );

    // Инвалидируем кэш после фиксации повторяющегося платежа
    _invalidateCache();

    await _onCompute(const PlannerComputeBudgetEvent(), emit);
  }

  Future<PlannerState> _computeStateFromPlanner(Planner planner) async {
    // Вычисляем хэш текущего состояния
    final stateHash = _computeStateHash(planner);

    // Проверяем, изменилось ли состояние
    if (_cachedState != null && _cachedStateHash == stateHash) {
      _log.debug('Используем кэшированное состояние (хэш: $stateHash)');
      return _cachedState!;
    }

    _log.debug('Вычисляем новое состояние (хэш: $stateHash)');

    var targetPlanner = planner.copyWith();
    if (planner.isGenerationAllowed) {
      final result = GenerateNewPlannerUseCase(
        customPlannerId: targetPlanner.id,
        payments: targetPlanner.payments,
        dateStart: targetPlanner.dateStart,
        dateEnd: targetPlanner.dateEnd,
        initialBudget: targetPlanner.initialBudget,
      ).run();
      targetPlanner = result.planner.copyWith(
        id: targetPlanner.id,
        isGenerationAllowed: false,
      );
    }

    if (targetPlanner.isGenerationAllowed) {
      throw Exception('Cannot work with not generated planner');
    }

    final constrainedPayments = ConstrainItemsInPeriodUseCase(
      items: targetPlanner.payments,
      dateStart: targetPlanner.dateStart,
      dateEnd: targetPlanner.dateEnd,
      dateExtractor: (payment) => payment.date,
    ).run();

    final computedBudget = ComputeBudgetUseCase(
      payments: constrainedPayments,
      initialBudget: targetPlanner.initialBudget,
    ).run();

    final moneyFlow = MoneyFlowUseCase(
      payments: constrainedPayments,
      initialBudget: targetPlanner.initialBudget,
    ).run();

    final paymentsByDate = GroupPaymentsByDateUsecase(
      payments: constrainedPayments,
      today: DateTime.now(),
    ).run();

    final actualInfo = ComputeActualPlannerInfo(
      plannerId: targetPlanner.id,
      lastUpdatedBudget: computedBudget.lastUpdatedBudget,
      payments: constrainedPayments,
    ).run();

    final newState = PlannerState.budgetComputed(
      payments: constrainedPayments,
      paymentsByDate: paymentsByDate,
      budget: Map.from(computedBudget.budget),
      dateStart: targetPlanner.dateStart,
      dateEnd: targetPlanner.dateEnd,
      moneyFlow: moneyFlow,
      actualInfo: actualInfo,
    );

    // Кэшируем новое состояние
    _cachedState = newState;
    _cachedStateHash = stateHash;

    _log.debug('Новое состояние вычислено и кэшировано');

    return newState;
  }

  // Метод для обновления actualInfo в репозитории
  Future<void> updateActualInfo() async {
    _log.debug('Обновление actualInfo для планера $plannerId');

    // Если текущее состояние содержит actualInfo, обновляем его в репозитории
    if (state is PlannerBudgetComputedState) {
      final currentState = state as PlannerBudgetComputedState;
      if (currentState.actualInfo != null) {
        // Вычисляем хэш actualInfo
        final actualInfo = currentState.actualInfo!;
        final actualInfoHash =
            '${actualInfo.plannerId}:${actualInfo.updatedAt.millisecondsSinceEpoch}:${actualInfo.completedCount}:${actualInfo.waitingCount}:${actualInfo.disabledCount}:${actualInfo.totalCount}:${actualInfo.updatedAtBudget}';

        // Проверяем, изменился ли actualInfo и прошло ли достаточно времени с последнего обновления
        final now = DateTime.now();
        if (_lastActualInfoHash == actualInfoHash &&
            _lastActualInfoUpdateTime != null &&
            now.difference(_lastActualInfoUpdateTime!) < _actualInfoUpdateInterval) {
          _log.debug(
            'Пропускаем обновление actualInfo (последнее обновление было ${now.difference(_lastActualInfoUpdateTime!).inSeconds} сек. назад, хэш не изменился)',
          );
          return;
        }

        // Обновляем actualInfo в репозитории
        await _actualInfoRepo.upsert(actualInfo.copyWith(plannerId: plannerId));

        // Обновляем время последнего обновления и хэш
        _lastActualInfoUpdateTime = now;
        _lastActualInfoHash = actualInfoHash;

        _log.debug('actualInfo успешно обновлен');
      } else {
        _log.debug('actualInfo отсутствует в состоянии');
      }
    } else {
      _log.debug('Состояние не является PlannerBudgetComputedState');
    }
  }

  // Метод для сохранения actualInfo при выходе из экрана
  Future<void> saveActualInfo() async {
    _log.debug('Запрос на сохранение actualInfo для планера $plannerId');

    // Проверяем, прошло ли достаточно времени с последнего сохранения
    final now = DateTime.now();
    if (_lastSaveTime != null && now.difference(_lastSaveTime!) < _debounceTime) {
      // Если прошло меньше _debounceTime, не сохраняем
      _log.debug(
        'Сохранение отклонено из-за дебаунса (последнее сохранение было ${now.difference(_lastSaveTime!).inSeconds} сек. назад)',
      );
      return;
    }

    // Обновляем время последнего сохранения
    _lastSaveTime = now;
    _log.debug('Сохранение разрешено, обновляем время последнего сохранения');

    // Если текущее состояние содержит actualInfo, обновляем его в репозитории
    if (state is PlannerBudgetComputedState) {
      final currentState = state as PlannerBudgetComputedState;
      if (currentState.actualInfo != null) {
        // Обновляем actualInfo в репозитории, игнорируя проверку хэша
        await _actualInfoRepo.upsert(
          currentState.actualInfo!.copyWith(plannerId: plannerId),
        );

        // Обновляем время последнего обновления и хэш
        _lastActualInfoUpdateTime = now;
        _lastActualInfoHash =
            null; // Сбрасываем хэш, чтобы следующее обновление прошло в любом случае

        _log.debug('actualInfo успешно сохранен при выходе из экрана');
      } else {
        _log.debug('actualInfo отсутствует в состоянии при выходе из экрана');
      }
    } else {
      _log.debug(
        'Состояние не является PlannerBudgetComputedState при выходе из экрана',
      );
    }
  }

  @override
  Future<void> close() async {
    _log.debug('Закрытие блока для планера $plannerId');

    // Обновляем actualInfo в репозитории при закрытии блока
    // Игнорируем дебаунс и проверку хэша, так как это последний шанс сохранить данные
    if (state is PlannerBudgetComputedState) {
      final currentState = state as PlannerBudgetComputedState;
      if (currentState.actualInfo != null) {
        // Обновляем actualInfo в репозитории
        await _actualInfoRepo.upsert(
          currentState.actualInfo!.copyWith(plannerId: plannerId),
        );

        _log.debug('actualInfo успешно сохранен при закрытии блока');
      } else {
        _log.debug('actualInfo отсутствует в состоянии при закрытии блока');
      }
    } else {
      _log.debug(
        'Состояние не является PlannerBudgetComputedState при закрытии блока',
      );
    }

    // Инвалидируем кэш при закрытии блока
    _invalidateCache();

    _log.debug('Блок для планера $plannerId закрыт');
    await super.close();
  }
}
