import 'package:moniplan_domain/moniplan_domain.dart';

class PaymentsDateGrouped {
  final DateTime date;
  final List<Payment> payments;

  const PaymentsDateGrouped({
    required this.date,
    required this.payments,
  });
}
