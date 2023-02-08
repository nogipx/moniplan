import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

final february2023 = OperationsManagerComputeBudgetEvent(
  startPeriod: DateTime(2023, 2, 8),
  endPeriod: DateTime(2023, 3, 1).monthEnd,
  // initialBudget: 80000,
  operations: [
    ..._salary,
    ..._daryaHealth,
    ..._credits,
    ..._home,
  ],
);

final _home = [
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 22),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.rentHome,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 14),
    repeat: DateTimeRepeat.everyTwoWeek,
    receipt: VredniReceipt.cleaning,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 3, 8),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.communalPayment,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 14),
    repeat: DateTimeRepeat.everyTwoWeek,
    receipt: VredniReceipt.catsSummary,
  ),
];

final _credits = [
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 3, 6),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.refinanceCredit,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 22),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.ipotekaDarya,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 3, 24),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.ipotekaKarim,
  ),
];

final _salary = [
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 15),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.salaryKarim,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 30),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.salaryKarim,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 10),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.salaryDarya,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 1, 25),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.salaryDarya,
  ),
];

final _daryaHealth = [
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 10),
    receipt: OperationReceipt(
      type: ReceiptType.outcome,
      name: 'Коронка',
      money: 20000,
      currency: AppCurrencies.ru,
    ),
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 24),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.daryaManicure,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 11),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.daryaHairSupport,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 3, 1),
    // repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.daryaPsychiatrist,
  ),
];
