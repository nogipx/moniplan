import 'package:moniplan_core/moniplan_core.dart';

abstract class OutdatedVredniReceipt {
  static final ohSofia = PaymentDetails(
    name: '💰 OhSofia',
    money: 150000,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
  );

  static final creditIpad = PaymentDetails(
    name: '👹 Кредит iPad',
    money: 10000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final creditMacbook = PaymentDetails(
    name: '👹 Кредит MacBook',
    money: 10000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final creditCardAlfaKarim = PaymentDetails(
    name: '🤡 Кредитка Карим Альфа побольше',
    money: 15000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final creditCardTinkoffDarya = PaymentDetails(
    name: '🤡 Кредитка Даша Тинькоф',
    money: 15000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
}
