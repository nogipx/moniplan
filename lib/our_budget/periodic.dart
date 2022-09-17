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
      type: OperationType.income,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 15),
      repeat: OperationRepeat.everyMonth,
      note: '💰 Зп карим аванс',
      money: 89000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.income,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 30),
      repeat: OperationRepeat.everyMonth,
      note: '💰 Зп карим основная',
      money: 120000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.income,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 10, 10),
      repeat: OperationRepeat.everyMonth,
      note: '💰 Зп Кисяб основная',
      money: 60000,
    ),
  ];

  static final homeSpends = [
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 21),
      repeat: OperationRepeat.everyMonth,
      note: 'Аренда квартиры',
      money: -43000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 20),
      repeat: OperationRepeat.everyTwoWeek,
      note: 'Клининг',
      money: -2000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 10, 8),
      repeat: OperationRepeat.everyMonth,
      note: 'Коммуналка',
      money: -4000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 16),
      repeat: OperationRepeat.everyMonth,
      note: 'Еда и веселье в месяц',
      // enabled: false,
      money: 50000,
    ),
  ];

  static final monthlyCredits = [
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 19),
      repeat: OperationRepeat.everyMonth,
      note: 'Кредит iPad',
      money: 7500,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 22),
      repeat: OperationRepeat.everyMonth,
      note: 'Ипотека Даша',
      money: 22000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 30),
      repeat: OperationRepeat.everyMonth,
      note: 'Кредит Google Pixel',
      money: 5020,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 10, 1),
      repeat: OperationRepeat.everyMonth,
      note: 'Кредит волосы Даша',
      money: 7800,
    ),
  ];

  static final creditCards = [
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 30),
      repeat: OperationRepeat.everyMonth,
      note: 'Кредитка Карим Альфа поменьше',
      money: 4000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 23),
      repeat: OperationRepeat.everyMonth,
      note: 'Кредитка Карим Альфа побольше',
      money: 5000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 10, 5),
      repeat: OperationRepeat.everyMonth,
      note: 'Кредитка Даша Тинькоф',
      money: 5000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 10, 8),
      repeat: OperationRepeat.everyMonth,
      note: 'Кредитка Карим Тинькоф',
      money: 6600,
    ),
  ];
}
