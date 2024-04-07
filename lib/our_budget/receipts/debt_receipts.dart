import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

class DebtReceipts implements PaymentsProvider {
  static final ipotekaLower = PaymentDetails(
    name: 'Ипотека поменьше',
    money: 23000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final ipotekaGreater = PaymentDetails(
    name: 'Ипотека побольше',
    money: 37000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final refinanceCredit = PaymentDetails(
    name: 'Кредит Альфа',
    money: 26000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final creditCardTinkoff = PaymentDetails(
    name: 'Платеж по кредитке',
    money: 17000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final splitGooglePixel = PaymentDetails(
    name: 'Сплит пиксель',
    money: 23000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  @override
  List<Payment> get payments {
    return [
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 16),
        repeat: DateTimeRepeat.month,
        details: ipotekaLower,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        details: ipotekaGreater,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 6),
        repeat: DateTimeRepeat.month,
        details: refinanceCredit,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 14),
        repeat: DateTimeRepeat.month,
        details: creditCardTinkoff,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 26),
        dateStart: DateTime(2024, 4, 12),
        dateEnd: DateTime(2024, 7, 26),
        repeat: DateTimeRepeat.month,
        details: splitGooglePixel,
      ),
    ];
  }
}
