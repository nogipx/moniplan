// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:moniplan_app/_run/db/app_db_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/domain/lib/moniplan_domain.dart';

import '../_index.dart';

final class PlannerRepoDrift implements IPlannerRepo {
  final AppDbImpl appDb;
  final AppLog _log;

  PlannerRepoDrift({required this.appDb}) : _log = AppLog('PlannerRepoDrift');

  static const _plannerMapper = PlannerMapperDrift();
  static const _paymentMapper = PaymentMapperDrift();
  static const _plannerActualInfoMapper = PlannerActualInfoMapper();

  Future<T> _guard<T>(Future<T> Function() action, {String name = ''}) async {
    try {
      // Механизм повторных попыток с экспоненциальной задержкой
      int retryCount = 0;
      const maxRetries = 5;
      const initialDelay = Duration(milliseconds: 100);

      while (true) {
        try {
          final result = await action();
          _log.business('Success: $name()');
          return result;
        } on Object catch (e) {
          // Проверяем любые ошибки, связанные с блокировкой базы данных
          final errorMessage = e.toString().toLowerCase();
          final isDatabaseLocked =
              errorMessage.contains('database is locked') ||
              errorMessage.contains('busy') ||
              errorMessage.contains('cannot start a transaction');

          if (isDatabaseLocked && retryCount < maxRetries) {
            retryCount++;
            // Экспоненциальная задержка: 100ms, 200ms, 400ms, 800ms, 1600ms
            final delay = Duration(milliseconds: initialDelay.inMilliseconds * (1 << retryCount));
            _log.warning(
              'Database locked, retrying $name() after ${delay.inMilliseconds}ms (attempt $retryCount/$maxRetries)',
            );
            await Future.delayed(delay);
            continue;
          }
          rethrow;
        }
      }
    } on Object catch (error, trace) {
      _log.error('Failed operation: $name()', error: error, trace: trace);
      rethrow;
    }
  }

  @override
  Future<Planner?> getPlannerById(String id, {bool withActualInfo = false}) async {
    return _guard(name: 'getPlannerById', () async {
      // Получаем данные планировщика
      final plannerDao = await _getPlannerById(id);
      if (plannerDao == null) return null;

      // Получаем платежи планировщика
      final payments = await getPaymentsByPlannerId(plannerId: id);

      // Получаем актуальную информацию о планировщике, если требуется
      final actualInfo = withActualInfo ? await getPlannerActualInfo(plannerId: id) : null;

      // Создаем объект планировщика
      return _plannerMapper
          .toDomain(plannerDao)
          .copyWith(payments: payments, actualInfo: actualInfo);
    });
  }

  @override
  Future<List<Planner>> getPlanners({bool withPayments = false, bool withActualInfo = true}) async {
    return _guard(name: 'getPlanners', () async {
      // Получаем все планировщики
      final plannersDao = await appDb.db.managers.paymentPlannersDriftTable.get();

      // Словарь для хранения платежей по планировщикам
      final paymentsForPlanner = <String, List<Payment>>{};

      // Если нужны платежи, получаем их для всех планировщиков
      if (withPayments) {
        final plannersIds = plannersDao.map((e) => e.plannerId).toSet();

        // Получаем все платежи для всех планировщиков
        final allPaymentsDao =
            await appDb.db.managers.paymentsComposedDriftTable
                .filter((f) => f.plannerId.isIn(plannersIds))
                .get();

        // Преобразуем DAO в доменные объекты
        final allPayments = allPaymentsDao.map(_paymentMapper.toDomain).toList();

        // Группируем платежи по планировщикам
        for (final payment in allPayments) {
          final list = paymentsForPlanner.putIfAbsent(payment.plannerId, () => []);
          list.add(payment);
        }
      }

      // Словарь для хранения актуальной информации по планировщикам
      final actualInfosForPlanner = <String, PlannerActualInfo?>{};

      // Если нужна актуальная информация, получаем ее для всех планировщиков
      if (withActualInfo) {
        for (final plannerDao in plannersDao) {
          final id = plannerDao.plannerId;
          actualInfosForPlanner[id] = await getPlannerActualInfo(plannerId: id);
        }
      }

      // Преобразуем DAO в доменные объекты и добавляем платежи и актуальную информацию
      final planners =
          plannersDao.map((e) {
            return _plannerMapper
                .toDomain(e)
                .copyWith(
                  payments: paymentsForPlanner[e.plannerId] ?? [],
                  actualInfo: actualInfosForPlanner[e.plannerId],
                );
          }).toList();

      return planners;
    });
  }

  @override
  Future<Planner?> savePlanner(Planner planner) async {
    return _guard(name: 'savePlanner', () async {
      // Проверяем, что планировщик может быть сохранен
      if (!planner.isGenerationAllowed) {
        throw Exception(
          'Cannot persist generated planners. '
          'Only blueprints allowed to persist.',
        );
      }

      // Проверяем, что у планировщика есть ID
      if (planner.id.isEmpty) {
        throw Exception(
          'Invalid planner. '
          'Planner should have id.',
        );
      }

      // Преобразуем доменный объект в DAO
      final plannerDao = _plannerMapper.toDto(planner);

      // Сохраняем планировщик в транзакции
      return appDb.db.transaction(() async {
        await appDb.db.managers.paymentPlannersDriftTable.create(
          (o) => plannerDao,
          mode: InsertMode.insertOrReplace,
        );

        return planner;
      });
    });
  }

  @override
  Future<Payment?> getPaymentById({required String plannerId, required String paymentId}) async {
    return _guard(name: 'getPaymentById', () async {
      // Получаем платеж из DAO
      final paymentDao = await appDb.db.paymentDao.getPaymentByIdInPlanner(paymentId, plannerId);

      // Если платеж найден, преобразуем его в доменный объект
      if (paymentDao != null) {
        return _paymentMapper.toDomain(paymentDao);
      }

      return null;
    });
  }

  @override
  Future<List<Payment>> getPaymentsByPlannerId({required String plannerId}) async {
    return _guard(name: 'getPaymentsByPlannerId', () async {
      // Получаем все платежи планировщика из DAO
      final paymentsDao = await appDb.db.paymentDao.getPaymentsByPlannerId(plannerId);

      // Преобразуем DAO в доменные объекты
      return paymentsDao.map(_paymentMapper.toDomain).toList();
    });
  }

  @override
  Future<Payment?> savePayment({
    required String plannerId,
    required Payment payment,
    bool allowCreate = false,
  }) async {
    return _guard(name: 'savePayment', () async {
      // Подготавливаем данные платежа
      final resultPayment = payment.copyWith(plannerId: plannerId);
      final paymentDao = _paymentMapper.toDto(resultPayment);

      // Проверяем существование платежа в планировщике, если не разрешено создание
      if (!allowCreate) {
        final exists = await appDb.db.paymentDao.paymentExistsInPlanner(
          payment.paymentId,
          plannerId,
        );

        if (!exists) {
          throw Exception('Payment "${payment.paymentId}" is not linked with Planner "$plannerId"');
        }
      }

      // Сохраняем платеж используя DAO
      await appDb.db.paymentDao.savePayment(paymentDao);

      return resultPayment;
    });
  }

  @override
  Future<void> deletePlanner(String plannerId) {
    return _guard(name: 'deletePlanner', () async {
      // Удаляем планировщик в транзакции
      return appDb.db.transaction(() async {
        // Удаляем все платежи планировщика
        await appDb.db.paymentDao.deleteAllPaymentsFromPlanner(plannerId);

        // Удаляем сам планировщик
        await appDb.db.managers.paymentPlannersDriftTable
            .filter((f) => f.plannerId.equals(plannerId))
            .delete();

        // Удаляем информацию о планировщике
        await _deleteInfoForPlanner(plannerId: plannerId);
      });
    });
  }

  @override
  Future<Planner?> duplicatePlanner({
    required String originalPlannerId,
    required DateTime newStartDate,
    required DateTime newEndDate,
    String? newName,
  }) {
    return _guard(name: 'duplicatePlanner', () async {
      // Получаем оригинальный планнер со всеми платежами
      final originalPlanner = await getPlannerById(originalPlannerId, withActualInfo: false);
      if (originalPlanner == null) {
        throw Exception('Original planner with id "$originalPlannerId" not found');
      }

      // Получаем все платежи оригинального планнера
      final originalPayments = await getPaymentsByPlannerId(plannerId: originalPlannerId);

      // Создаем новый ID для дублированного планнера
      final newPlannerId = const Uuid().v4();
      final plannerName = newName ?? '${originalPlanner.name} (копия)';

      // Создаем копию планнера с новыми параметрами
      final duplicatedPlanner = originalPlanner.copyWith(
        id: newPlannerId,
        name: plannerName,
        dateStart: newStartDate,
        dateEnd: newEndDate,
        payments: [], // Очищаем платежи, будем добавлять отдельно
        actualInfo: null, // Сбрасываем актуальную информацию
        isGenerationAllowed: true, // Разрешаем генерацию для нового планнера
      );

      return appDb.db.transaction(() async {
        // Сохраняем дублированный планнер
        await appDb.db.managers.paymentPlannersDriftTable.create(
          (o) => _plannerMapper.toDto(duplicatedPlanner),
          mode: InsertMode.insertOrReplace,
        );

        // Дублируем все платежи с новыми ID и привязкой к новому планнеру
        for (final originalPayment in originalPayments) {
          final duplicatedPayment = originalPayment.copyWith(
            paymentId: const Uuid().v4(),
            plannerId: newPlannerId,
            // Сохраняем все остальные параметры платежа как есть
          );

          final paymentDao = _paymentMapper.toDto(duplicatedPayment);
          await appDb.db.paymentDao.savePayment(paymentDao);
        }

        // Возвращаем созданный планнер
        return duplicatedPlanner;
      });
    });
  }

  @override
  Future<void> deletePayment({required String plannerId, required String paymentId}) async {
    return _guard(name: 'deletePayment', () async {
      // Проверяем существование платежа в планировщике
      final exists = await appDb.db.paymentDao.paymentExistsInPlanner(paymentId, plannerId);

      if (!exists) {
        throw Exception('Payment "$paymentId" is not linked with Planner "$plannerId"');
      }

      // Удаляем платеж
      await appDb.db.paymentDao.deletePaymentFromPlanner(paymentId, plannerId);
    });
  }

  @override
  Future<Payment?> fixateRepeatedPayment({
    required String plannerId,
    required String paymentId,
  }) async {
    return _guard(name: 'fixateRepeatedPayment', () async {
      // Получаем платеж
      final payment = await getPaymentById(plannerId: plannerId, paymentId: paymentId);
      if (payment == null) {
        throw Exception('Cannot find payment with id "$paymentId" in planner "$plannerId"');
      }

      // Проверяем, что платеж является повторяющимся
      if (!payment.isRepeatParent) {
        throw Exception('Payment should be repeated and parent');
      }

      // Создаем копию платежа без повторения
      final copiedPayment = payment.copyWith(
        paymentId: const Uuid().v4(),
        repeat: DateTimeRepeat.noRepeat,
        dateStart: null,
        dateEnd: null,
      );

      // Обновляем оригинальный платеж, сдвигая его дату на следующий период
      final updatedOriginalPayment = payment.copyWith(date: payment.repeat.next(payment.date));

      // Подготавливаем данные для обоих платежей
      final resultCopiedPayment = copiedPayment.copyWith(plannerId: plannerId);
      final copiedPaymentDao = _paymentMapper.toDto(resultCopiedPayment);

      final resultUpdatedPayment = updatedOriginalPayment.copyWith(plannerId: plannerId);
      final updatedPaymentDao = _paymentMapper.toDto(resultUpdatedPayment);

      // Сохраняем оба платежа в одной транзакции для атомарности
      await appDb.db.transaction(() async {
        // Создаем копию платежа
        await appDb.db.paymentDao.createPayment(copiedPaymentDao);

        // Обновляем оригинальный платеж
        await appDb.db.paymentDao.updatePayment(updatedPaymentDao);
      });

      return resultCopiedPayment;
    });
  }

  @override
  Future<PlannerActualInfo?> getPlannerActualInfo({required String plannerId}) {
    return _guard(name: 'getPlannerActualInfo', () async {
      // Получаем актуальную информацию о планировщике
      final infoList =
          await appDb.db.managers.plannerActualInfoDriftTable
              .filter((f) => f.plannerId.equals(plannerId))
              .get();

      // Если информация найдена, преобразуем ее в доменный объект
      return infoList.isNotEmpty ? _plannerActualInfoMapper.toDomain(infoList.first) : null;
    });
  }

  @override
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required String plannerId,
    required PlannerActualInfo plannerActualInfo,
  }) async {
    return _guard(name: 'updatePlannerActualInfo', () async {
      try {
        // Преобразуем доменную модель в DTO
        final dto = _plannerActualInfoMapper.toDto(plannerActualInfo);

        // Сначала удаляем существующую запись, если она есть
        final selector = appDb.db.managers.plannerActualInfoDriftTable.filter(
          (f) => f.plannerId.equals(plannerId),
        );
        await selector.delete();

        // Затем вставляем новую запись
        await appDb.db.managers.plannerActualInfoDriftTable.create(
          (o) => dto,
          mode: InsertMode.insertOrReplace,
        );

        // Возвращаем обновленную информацию
        return plannerActualInfo;
      } catch (e) {
        print('Ошибка при обновлении актуальной информации о планировщике: $e');
        return null;
      }
    });
  }

  Future<void> _deleteInfoForPlanner({required String plannerId}) {
    return _guard(name: '_deleteInfoForPlanner', () async {
      // Удаляем информацию о планировщике
      final selector = appDb.db.managers.plannerActualInfoDriftTable.filter(
        (f) => f.plannerId.equals(plannerId),
      );

      // Проверяем существование информации и удаляем ее
      final exists = await selector.get().then((list) => list.isNotEmpty);
      if (exists) {
        await selector.delete();
      }
    });
  }

  Future<PaymentPlannersDriftTableData?> _getPlannerById(String id) =>
      appDb.db.managers.paymentPlannersDriftTable
          .filter((f) => f.plannerId.equals(id))
          .getSingleOrNull();
}
