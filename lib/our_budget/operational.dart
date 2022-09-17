import 'package:moniplan_core/moniplan_core.dart';
import 'package:uuid/uuid.dart';

class KarimDaryaOperationalBudget {
  static final currentBudget = Operation(
    id: const Uuid().v4(),
    type: OperationType.income,
    currency: AppCurrencies.ru,
    date: DateTime(2022, 9, 15),
    note: 'Текущий бюджет',
    money: 44000,
  );

  static final all = <Operation>[
    currentBudget,
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 16),
      note: 'Поилка и штучки',
      money: 11500,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.income,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 15),
      note: 'Добавка к зарплате (какой-то аванс)',
      money: 71000,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 20),
      note: 'Психиатр',
      money: 3500,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 9, 23),
      note: 'Маник',
      money: 1600,
    ),
    Operation(
      id: const Uuid().v4(),
      type: OperationType.outcome,
      currency: AppCurrencies.ru,
      date: DateTime(2022, 10, 1),
      note: 'Обновление волос',
      money: 15000,
    ),
  ];
}
