// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// В заданных границах дат генерирует для повторяющихся платежей
/// список платежей.
/// У каждого платежа будет указан [plannerId].
/// Используется каждый раз, когда перегенирируем планер.
class ExpandPaymentToPeriodUseCase implements IUseCase<ExpandPaymentToPeriodUseCaseResult> {
  /// С этим id будут связаны все платежи.
  final String plannerId;

  final Payment payment;

  final DateTime startPeriod;
  final DateTime endPeriod;

  const ExpandPaymentToPeriodUseCase({
    required this.plannerId,
    required this.payment,
    required this.startPeriod,
    required this.endPeriod,
  });

  @override
  ExpandPaymentToPeriodUseCaseResult run() {
    const uuid = Uuid();
    final start = startPeriod;
    final end = endPeriod;

    // Если платеж не повторяющийся, то просто
    // меняем ему plannerId и возвращаем
    if (!payment.isRepeat) {
      final originalPayment = payment.copyWith(
        plannerId: plannerId,
      );
      return ExpandPaymentToPeriodUseCaseResult(
        basePayment: originalPayment,
        dateStart: start,
        dateEnd: end,
        payments: [originalPayment],
      );
    }

    final paymentDateStart = payment.dateStart;
    final paymentDateEnd = payment.dateEnd;

    // Определяем границы дат для генерации повторяющегося платежа

    // Если у платежа указана дата начала и старт планера раньше,
    // то используется дата начала платежа
    //
    // Если у платежа указана дата начала и старт планера позже,
    // то используется дата старта планера
    //
    // Если у платежа НЕ указана дата начала
    // то используется дата старта планера
    final targetDateStart = paymentDateStart != null
        ? startPeriod.isAfter(paymentDateStart)
            ? startPeriod
            : paymentDateStart
        : startPeriod;

    // Если у платежа указана дата окончания и конец планера раньше,
    // то используется дата конца планера
    //
    // Если у платежа указана дата начала и конец планера позже,
    // то используется дата окончания платежа
    //
    // Если у платежа НЕ указана дата начала
    // то используется дата конца планера
    final targetDateEnd = paymentDateEnd != null
        ? endPeriod.isBefore(paymentDateEnd)
            ? endPeriod
            : paymentDateEnd
        : endPeriod;

    final baseDate = payment.date;

    // Генерируем даты в рамках заданного начала и конца повторения,
    // начиная с даты платежа
    final generatedDates = GenerateRepeatDatesUseCase(
      repeat: payment.repeat,
      base: baseDate,
      dateStart: targetDateStart,
      dateEnd: targetDateEnd,
      generatePastDates: false,
    ).run();

    // Затем в каждую сгенерированную дату копируем платеж
    final payments = generatedDates.map((e) {
      final date = e;

      // Если дата платежа совпадает с датой оригинального платежа, из которого генерируем,
      // то не меняем id и подставляем оригинальный платеж.
      // В любом случае заменяем plannerId.
      if (date.isSameDay(baseDate)) {
        return payment.copyWith(
          date: date,
          plannerId: plannerId,
        );
      }

      // Если дата платежа НЕ совпадает с датой оригинального платежа, из которого генерируем,
      // то создаем новый id у платежа, и записываем референс на оригинальный платеж.
      // В любом случае заменяем plannerId.
      else {
        return payment.copyWith(
          date: date,
          paymentId: uuid.v4(),
          originalPaymentId: payment.paymentId,
          plannerId: plannerId,
        );
      }
    }).toList();

    final result = ExpandPaymentToPeriodUseCaseResult(
      basePayment: payment,
      dateStart: start,
      dateEnd: end,
      payments: payments,
    );

    return result;
  }
}

class ExpandPaymentToPeriodUseCaseResult {
  final DateTime dateStart;
  final DateTime dateEnd;
  final Payment basePayment;
  final List<Payment> payments;

  ExpandPaymentToPeriodUseCaseResult({
    required this.basePayment,
    required this.dateStart,
    required this.dateEnd,
    this.payments = const [],
  });
}
