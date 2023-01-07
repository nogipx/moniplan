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
        name: '💰 Зп Карим ',
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
      enabled: true,
      receipt: OperationReceipt(
        name: '💰 OhSofia',
        money: 150000,
        type: ReceiptType.income,
        currency: AppCurrencies.ru,
      ),
    ),
    // Operation(
    //   id: const Uuid().v4(),
    //   type: OperationType.income,
    //   currency: AppCurrencies.ru,
    //   date: DateTime(2023, 2, 25),
    //   note: '💰 OhSofia',
    //   enabled: true,
    //   money: 150000,
    // ),
  ];

  static final homeSpends = [
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2021, 9, 22),
      repeat: DateTimeRepeat.everyDay,
      enabled: false,
      receipt: OperationReceipt(
        name: '! ЕДА !',
        money: -2000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 22),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: 'Аренда квартиры',
        money: -43000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 1, 10),
      repeat: DateTimeRepeat.everyTwoWeek,
      receipt: OperationReceipt(
        name: 'Клининг',
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
        name: 'Коммуналка',
        money: -4000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    // Operation(
    //   id: const Uuid().v4(),
    //   type: OperationType.outcome,
    //   currency: AppCurrencies.ru,
    //   date: DateTime(2022, 9, 16),
    //   repeat: OperationRepeat.everyMonth,
    //   note: 'Еда и веселье в месяц',
    //   enabled: false,
    //   money: 50000,
    // ),
  ];

  static final monthlyCredits = [
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 19),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: 'Кредит iPad',
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
        name: 'Ипотека Даша',
        money: 22000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 9, 30),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: 'Кредит Google Pixel',
        money: 5020,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
  ];

  static final creditCards = [
    // Operation(
    //   id: const Uuid().v4(),
    //   type: OperationType.outcome,
    //   currency: AppCurrencies.ru,
    //   date: DateTime(2022, 9, 30),
    //   repeat: OperationRepeat.everyMonth,
    //   note: 'Кредитка Карим Альфа поменьше',
    //   money: 4000,
    // ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 2, 1),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: 'Кредитка Карим Альфа побольше',
        money: 10000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
    Operation(
      id: const Uuid().v4(),
      date: DateTime(2022, 2, 1),
      repeat: DateTimeRepeat.everyMonth,
      receipt: OperationReceipt(
        name: 'Кредитка Даша Тинькоф',
        money: 10000,
        type: ReceiptType.outcome,
        currency: AppCurrencies.ru,
      ),
    ),
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
