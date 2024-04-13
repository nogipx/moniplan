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

class ExpandPaymentToPeriodUseCase extends UseCase<ExpandPaymentToPeriodUseCaseResult> {
  final Payment payment;
  final DateTime startPeriod;
  final DateTime endPeriod;

  const ExpandPaymentToPeriodUseCase({
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
      return ExpandPaymentToPeriodUseCaseResult(
        basePayment: payment,
        dateStart: start,
        dateEnd: end,
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

    final generatedDates = GenerateRepeatDatesUseCase(
      repeat: payment.repeat,
      base: payment.date,
      dateStart: targetDateStart,
      dateEnd: targetDateEnd,
    ).run();

    final payments = generatedDates
        .map((e) => payment.copyWith(
              date: e,
              id: uuid.v4(),
              originalPaymentId: payment.id,
            ))
        .toList();

    final result = ExpandPaymentToPeriodUseCaseResult(
      basePayment: payment,
      dateStart: start,
      dateEnd: end,
      payments: payments,
    );

    return result;
  }
}
