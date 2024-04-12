import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:uuid/uuid.dart';

class GenerateRepeatPaymentsUseCaseResult {
  final DateTime dateStart;
  final DateTime dateEnd;
  final Payment basePayment;
  final List<Payment> payments;

  GenerateRepeatPaymentsUseCaseResult({
    required this.basePayment,
    required this.dateStart,
    required this.dateEnd,
    this.payments = const [],
  });
}

class GenerateRepeatPaymentsUseCase extends UseCase<GenerateRepeatPaymentsUseCaseResult> {
  final Payment payment;
  final DateTime startPeriod;
  final DateTime endPeriod;

  const GenerateRepeatPaymentsUseCase({
    required this.payment,
    required this.startPeriod,
    required this.endPeriod,
  });

  @override
  GenerateRepeatPaymentsUseCaseResult run() {
    const uuid = Uuid();
    final start = startPeriod;
    final end = endPeriod;

    if (!payment.isRepeat) {
      return GenerateRepeatPaymentsUseCaseResult(
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

    final result = GenerateRepeatPaymentsUseCaseResult(
      basePayment: payment,
      dateStart: start,
      dateEnd: end,
      payments: payments,
    );

    return result;
  }
}
