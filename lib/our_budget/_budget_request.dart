import 'package:moniplan_core/moniplan_core.dart';

import '_index.dart';

final currentRequest = PaymentPlanner(
  id: const Uuid().v4(),
  dateStart: DateTime(2024, 5, 1),
  dateEnd: DateTime(2024, 6, 6),
  initialBudget: 0,
  isDraft: true,
  payments: [
    ...DebtReceipts().payments,
    ...SalaryReceipts().payments,
    ...SurvivalReceipts().payments,
    ...SoderzhankiReceipts().payments,
  ],
);
