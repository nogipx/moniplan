import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SurvivalReceipts implements OperationsProvider {
  // Аренда
  static final rentHomeSuvorova = OperationReceipt(
    name: 'Аренда Суворова',
    money: 43000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );
  static final rentHomeSamolet = OperationReceipt(
    name: 'Аренда Самолет',
    money: 24000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // Коммуналка
  static final communalSuvorova = OperationReceipt(
    name: 'Коммуналка Суворова',
    money: -5500,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );
  static final communalBelichenko = OperationReceipt(
    name: 'Коммуналка Беличенко',
    money: -2600,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );
  static final communalGondarya = OperationReceipt(
    name: 'Коммуналка Гондаря',
    money: -2600,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );
  static final communalSamolet = OperationReceipt(
    name: 'Коммуналка Самолет Даша',
    money: -4000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );
  static final internet = OperationReceipt(
    name: 'Интернеты и серверы',
    money: 900 + 800 + 600 + 600 + 800,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // Коты
  static final catsSummary = OperationReceipt(
    name: 'Все для котов',
    money: -10000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  @override
  List<Operation> get operations {
    return [
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 3),
        repeat: DateTimeRepeat.month,
        receipt: rentHomeSamolet,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        receipt: rentHomeSuvorova,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        receipt: communalBelichenko,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        receipt: communalGondarya,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        receipt: communalSuvorova,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        receipt: communalSamolet,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.month,
        receipt: catsSummary,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.month,
        receipt: internet,
      ),
    ];
  }
}
