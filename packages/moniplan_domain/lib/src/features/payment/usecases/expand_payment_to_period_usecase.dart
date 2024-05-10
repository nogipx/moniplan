import 'package:moniplan_domain/moniplan_domain.dart';

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

class ExpandPaymentToPeriodUseCase implements IUseCase<ExpandPaymentToPeriodUseCaseResult> {
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

    final targetDateStart = paymentDateStart != null
        ? startPeriod.isAfter(paymentDateStart)
            ? startPeriod
            : paymentDateStart
        : startPeriod;

    final targetDateEnd = paymentDateEnd != null
        ? endPeriod.isBefore(paymentDateEnd)
            ? endPeriod
            : paymentDateEnd
        : endPeriod;

    final baseDate = payment.date;
    final generatedDates = GenerateRepeatDatesUseCase(
      repeat: payment.repeat,
      base: baseDate,
      dateStart: targetDateStart,
      dateEnd: targetDateEnd,
    ).run();

    final payments = generatedDates.map((e) {
      final date = e;
      if (date.isSameDay(baseDate)) {
        return payment.copyWith(
          date: date,
          plannerId: plannerId,
        );
      } else {
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
