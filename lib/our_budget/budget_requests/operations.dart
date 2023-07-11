import 'package:moniplan_core/moniplan_core.dart';

abstract class CreditOperations {
  // 22 число
  static final rentHome = OperationReceipt(
    name: 'Аренда квартиры',
    money: -43000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // 8 число
  static final communal = OperationReceipt(
    name: 'Коммуналка',
    money: -5500,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // 15-17 число
  static final ipotekaBig = OperationReceipt(
    name: 'Ипотека побольше',
    money: -36500,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // 23 число
  static final ipotekaSmall = OperationReceipt(
    name: 'Ипотека поменьше',
    money: -22500,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // 6 число
  static final creditAlfa = OperationReceipt(
    name: 'Кредит альфа',
    money: -26000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // 5 августа
  static final book3 = OperationReceipt(
    name: 'Рассрочка книга 3',
    money: -6673,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  // 5 сентября
  static final book4 = OperationReceipt(
    name: 'Рассрочка книга 4',
    money: -6670,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );
}
