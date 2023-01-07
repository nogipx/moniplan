import 'package:moniplan_core/moniplan_core.dart';

import 'periodic.dart';

abstract class BudgetsRequests {
  static final onlyRequiredSpendsToYearEnd =
      OperationsManagerEvent.computeBudget(
    operations: KarimDaryaPeriodicOperations.all,
    startPeriod: DateTime.now().monthMedian,
    endPeriod:
        DateTime.now().addTime(month: 1).monthMedian.subtractTime(day: 1),
  );

  static final currentSpends = OperationsManagerEvent.computeBudget(
    operations: [
      ...KarimDaryaPeriodicOperations.all,
      // ...KarimDaryaOperationalBudget.all,
    ],
    // initialBudget: 135000,
    startPeriod: DateTime(2023, 1, 7),
    endPeriod: DateTime(2023, 1, 28).monthEnd,
    // endPeriod: DateTime(2023, 3, 31),
  );
}
