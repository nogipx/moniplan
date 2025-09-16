import 'package:moniplan_app/core/_index.dart';

class PaymentsDateGrouped {
  final DateTime date;
  final List<Payment> payments;

  const PaymentsDateGrouped({required this.date, required this.payments});
}
