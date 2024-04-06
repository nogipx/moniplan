import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';
import '../receipts/_index.dart';

final april2024 = OperationsManagerComputeBudgetEvent(
  startPeriod: DateTime(2024, 4, 6),
  endPeriod: DateTime(2024, 5, 6),
  initialBudget: 26000,
  operations: [
    ...DebtReceipts().operations,
    ...SalaryReceipts().operations,
    ...SurvivalReceipts().operations,
    ...DashaReceipts().operations,
  ],
);
