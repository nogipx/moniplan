import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

final april2024 = PaymentPlanner(
  id: const Uuid().v4(),
  dateStart: DateTime(2024, 4, 6),
  dateEnd: DateTime(2024, 5, 6),
  initialBudget: 26000,
  shouldGenerate: true,
  payments: [
    ...DebtReceipts().payments,
    ...SalaryReceipts().payments,
    ...SurvivalReceipts().payments,
    ...DashaReceipts().payments,
  ],
);
