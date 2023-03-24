import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

final april2023 = OperationsManagerComputeBudgetEvent(
  startPeriod: DateTime(2023, 3, 24),
  endPeriod: DateTime(2023, 4, 1).monthEnd,
  initialBudget: 35000 + 15000,
  operations: [
    ..._salary,
    ..._daryaHealth,
    ..._credits,
    ..._home,
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 4, 1),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.daryaCarSchool,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 4, 21),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.daryaHeadphones,
    ),
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
    date: DateTime(2023, 3, 28),
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
    date: DateTime(2023, 3, 30),
    repeat: DateTimeRepeat.everyTwoWeek,
    receipt: VredniReceipt.catsSummary,
  ),
];

final _credits = [
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 4, 6),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.refinanceCredit,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 4, 22),
    dateStart: DateTime(2023, 4, 22),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.ipotekaDarya,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 4, 24),
    dateStart: DateTime(2023, 4, 24),
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
    dateStart: DateTime(2023, 4, 25),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.salaryDarya,
  ),
];

final _daryaHealth = [
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 24),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.daryaManicure,
  ),
  // Operation(
  //   id: const Uuid().v4(),
  //   date: DateTime(2023, 2, 11),
  //   repeat: DateTimeRepeat.everyMonth,
  //   receipt: VredniReceipt.daryaHairSupport,
  // ),
  // Operation(
  //   id: const Uuid().v4(),
  //   date: DateTime(2023, 3, 1),
  //   // repeat: DateTimeRepeat.everyMonth,
  //   receipt: VredniReceipt.daryaPsychiatrist,
  // ),
];
