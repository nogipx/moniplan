import 'package:moniplan_core/moniplan_core.dart';
import 'package:uuid/uuid.dart';

import '../_index.dart';

final monthlyCycle = OperationsManagerEvent.computeBudget(
  startPeriod: DateTime(0, 1, 1),
  endPeriod: DateTime(0, 1, 20).monthEnd,
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
);
