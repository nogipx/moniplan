import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

final february2023 = OperationsManagerComputeBudgetEvent(
  startPeriod: DateTime(2023, 1, 31),
  endPeriod: DateTime(2023, 2, 1).monthEnd,
  initialBudget: 80000,
  operations: [
    ..._salary,
    ..._daryaHealth,
    Operation(
      id: const Uuid().v4(),
      enabled: false,
      date: DateTime(2023, 2, 3),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.ohSofia,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 22),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.rentHome,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 31, 1),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: VredniReceipt.cleaning,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 8),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.communalPayment.copyWith(
        money: 8000,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 2),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: VredniReceipt.catsSummary,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 19),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.creditIpad,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 9),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.creditMacbook,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 22),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.ipotekaDarya,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 24),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.ipotekaKarim,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 1),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.creditCardAlfaKarim,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 2, 1),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.creditCardTinkoffDarya,
    ),
  ],
);

final _salary = [
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 15),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.salaryKarim,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 28),
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
    repeat: DateTimeRepeat.everyMonth,
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
    date: DateTime(2023, 2, 5),
    repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.daryaHairSupport,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 1),
    // repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.daryaPsychiatrist,
  ),
  Operation(
    id: const Uuid().v4(),
    date: DateTime(2023, 2, 15),
    // repeat: DateTimeRepeat.everyMonth,
    receipt: VredniReceipt.daryaPsychiatrist,
  ),
];
