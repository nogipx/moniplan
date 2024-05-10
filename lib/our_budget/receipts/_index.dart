import 'package:moniplan_core/moniplan_core.dart';

export 'debt_receipts.dart';
export 'soderzhanki_receipts.dart';
export 'salary_receipts.dart';
export 'survival_receipts.dart';

abstract interface class PaymentsProvider {
  List<Payment> get payments;
}
