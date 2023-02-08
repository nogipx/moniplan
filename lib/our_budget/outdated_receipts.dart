import 'package:moniplan_core/moniplan_core.dart';

abstract class OutdatedVredniReceipt {
  static final ohSofia = OperationReceipt(
    name: '💰 OhSofia',
    money: 150000,
    type: ReceiptType.income,
    currency: AppCurrencies.ru,
  );

  static final creditIpad = OperationReceipt(
    name: '👹 Кредит iPad',
    money: 10000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final creditMacbook = OperationReceipt(
    name: '👹 Кредит MacBook',
    money: 10000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final creditCardAlfaKarim = OperationReceipt(
    name: '🤡 Кредитка Карим Альфа побольше',
    money: 15000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final creditCardTinkoffDarya = OperationReceipt(
    name: '🤡 Кредитка Даша Тинькоф',
    money: 15000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );
}
