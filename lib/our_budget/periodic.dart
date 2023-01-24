import 'package:moniplan/our_budget/static_spends.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:uuid/uuid.dart';

abstract class KarimDaryaPeriodicOperations {
  static final all = <Operation>[
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 15),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.salaryKarim,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 30),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.salaryKarim,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 10),
      repeat: DateTimeRepeat.everyMonth,
      enabled: true,
      receipt: VredniReceipt.salaryDarya,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 25),
      repeat: DateTimeRepeat.everyMonth,
      enabled: true,
      receipt: VredniReceipt.salaryDarya,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 25),
      // enabled: false,
      dateEnd: DateTime(2023, 2, 1),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.ohSofia,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 22),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.rentHome,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 31),
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
      date: DateTime(2023, 3, 8),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.communalPayment,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 10, 10),
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
      dateStart: DateTime(2023, 2, 24),
      repeat: DateTimeRepeat.everyMonth,
      receipt: VredniReceipt.ipotekaKarim,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 2, 1),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: VredniReceipt.creditCardAlfaKarim,
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 2, 1),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: VredniReceipt.creditCardTinkoffDarya,
    ),
  ];
}
