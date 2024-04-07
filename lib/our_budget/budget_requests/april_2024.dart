import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';
import '../receipts/_index.dart';

final april2024 = PaymentsManagerComputeBudgetEvent(
  startPeriod: DateTime(2024, 4, 6),
  endPeriod: DateTime(2024, 5, 6),
  initialBudget: 26000,
  payments: [
    ...DebtReceipts().payments,
    ...SalaryReceipts().payments,
    ...SurvivalReceipts().payments,
    ...DashaReceipts().payments,
  ],
);
