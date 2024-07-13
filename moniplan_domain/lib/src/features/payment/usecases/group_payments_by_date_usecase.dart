import 'package:moniplan_domain/moniplan_domain.dart';

class GroupPaymentsByDateUsecase implements IUseCase<List<PaymentsDateGrouped>> {
  final List<Payment> payments;

  const GroupPaymentsByDateUsecase({
    required this.payments,
  });

  @override
  List<PaymentsDateGrouped> run() {
    final mapped = <DateTime, List<Payment>>{};

    for (final payment in payments) {
      mapped.putIfAbsent(payment.date.onlyDate, () => []).add(payment);
    }

    final entries = mapped.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    final result = entries.map((e) {
      return PaymentsDateGrouped(
        date: e.key,
        payments: e.value,
      );
    }).toList();

    return result;
  }
}
