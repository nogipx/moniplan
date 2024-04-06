import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

class DebtReceipts implements OperationsProvider {
  static final ipotekaLower = OperationReceipt(
    name: 'Ипотека поменьше',
    money: 23000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final ipotekaGreater = OperationReceipt(
    name: 'Ипотека побольше',
    money: 37000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final refinanceCredit = OperationReceipt(
    name: 'Кредит Альфа',
    money: 26000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final creditCardTinkoff = OperationReceipt(
    name: 'Платеж по кредитке',
    money: 20000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final splitGooglePixel = OperationReceipt(
    name: 'Сплит пиксель',
    money: 23000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  @override
  List<Operation> get operations {
    return [
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 16),
        repeat: DateTimeRepeat.month,
        receipt: ipotekaLower,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        receipt: ipotekaGreater,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 6),
        repeat: DateTimeRepeat.month,
        receipt: refinanceCredit,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 14),
        repeat: DateTimeRepeat.month,
        receipt: creditCardTinkoff,
      ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 26),
        dateStart: DateTime(2024, 4, 12),
        dateEnd: DateTime(2024, 7, 26),
        repeat: DateTimeRepeat.month,
        receipt: splitGooglePixel,
      ),
    ];
  }
}
