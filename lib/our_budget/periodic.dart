import 'package:moniplan_core/moniplan_core.dart';
import 'package:uuid/uuid.dart';

abstract class KarimDaryaPeriodicOperations {
  static final all = <Operation>[
    ...incomes,
    ...homeSpends,
    ...monthlyCredits,
    ...creditCards,
  ];

  static final incomes = [
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 15),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '💰 Зп Карим',
        money: 89000,
        type: ReceiptType.income,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 30),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '💰 Аванс Карим',
        money: 120000,
        type: ReceiptType.income,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 10),
      repeat: DateTimeRepeat.everyMonth,
      enabled: true,
      receipt: OperationReceipt(
        name: '💰 Аванс Даша',
        money: 60000,
        type: ReceiptType.income,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 25),
      repeat: DateTimeRepeat.everyMonth,
      enabled: true,
      receipt: OperationReceipt(
        name: '💰 Зп Даша',
        money: 20000,
        type: ReceiptType.income,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 25),
      // enabled: false,
      dateEnd: DateTime(2023, 2, 1),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '📈 OhSofia',
        money: 150000,
        type: ReceiptType.income,
        currency: AppCurrencies.ru,
      ),
    ),
  ];

  static final homeSpends = [
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2021, 9, 22),
      repeat: DateTimeRepeat.everyThreeDay,
      receipt: OperationReceipt(
        name: '🥑 Яндекс.Еда / Delivery',
        money: -3000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2021, 9, 22),
      repeat: DateTimeRepeat.everyDay,
      receipt: OperationReceipt(
        name: '🥑 Самокат',
        money: -1000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 22),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '🏠 Аренда квартиры',
        money: -43000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2023, 1, 10),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: OperationReceipt(
        name: '🏠 Клининг',
        money: -2000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 10, 8),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '🏠 Коммуналка',
        money: -4000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 10, 10),
      repeat: DateTimeRepeat.everyWeek,
      receipt: OperationReceipt(
        name: '🏠 Все для котов',
        money: -5000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
  ];

  static final monthlyCredits = [
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 19),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '👹 Кредит iPad',
        money: 7500,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 22),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '🏢 Ипотека, самолет 4кв 2023',
        money: 22500,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 30),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: '👹 Кредит Google Pixel',
        money: 5020,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
  ];

  static final creditCards = [
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 2, 1),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: OperationReceipt(
        name: '🤡 Кредитка Карим Альфа побольше',
        money: 10000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 2, 1),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: OperationReceipt(
        name: '🤡 Кредитка Даша Тинькоф',
        money: 10000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    // Operation(
    //   id: const Uuid().v4(),
    //   type: OperationType.outcome,
    //   currency: AppCurrencies.ru,
    //   date: DateTime(2022, 9, 30),
    //   repeat: OperationRepeat.everyMonth,
    //   note: 'Кредитка Карим Альфа поменьше',
    //   money: 4000,
    // ),
    // Operation(
    //   id: const Uuid().v4(),
    //   type: OperationType.outcome,
    //   currency: AppCurrencies.ru,
    //   date: DateTime(2022, 10, 8),
    //   repeat: OperationRepeat.everyMonth,
    //   note: 'Кредитка Карим Тинькоф',
    //   money: 6600,
    // ),
  ];
}
