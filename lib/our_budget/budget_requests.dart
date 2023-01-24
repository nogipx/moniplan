import 'package:moniplan/our_budget/static_spends.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:uuid/uuid.dart';

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
    initialBudget: 16000,
    startPeriod: DateTime(2023, 1, 24),
    endPeriod: DateTime(2023, 2, 20).monthEnd,
  );

  static final monthlyCycle = OperationsManagerEvent.computeBudget(
    operations: [
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 15),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.salaryKarim,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 30),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.salaryKarim,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 10),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.salaryDarya,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 25),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.salaryDarya,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 22),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.rentHome,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 22),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.ipotekaDarya,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 24),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.ipotekaKarim,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 12),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.cleaning,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 24),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.cleaning,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 8),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.communalPayment,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 1),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.catsSummary,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 15),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.catsSummary,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 19),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.creditIpad,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 9),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.creditMacbook,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 1),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.creditCardAlfaKarim,
      ),
      Operation(
        id: const Uuid().v4(),
        date: DateTime(0, 1, 1),
        repeat: DateTimeRepeat.everyMonth,
        receipt: VredniReceipt.creditCardTinkoffDarya,
      ),
    ],
    startPeriod: DateTime(0, 1, 1),
    endPeriod: DateTime(0, 1, 20).monthEnd,
  );
}
