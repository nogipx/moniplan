import 'package:moniplan_core/moniplan_core.dart';

abstract class VredniReceipt {
  static final rentHome = OperationReceipt(
    name: '🏠 Аренда квартиры',
    money: -43000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final cleaning = OperationReceipt(
    name: '🏠 Клининг',
    money: -2000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final communalPayment = OperationReceipt(
    name: '🏠 Коммуналка',
    money: -4000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final yandexEat = OperationReceipt(
    name: '🥑 Яндекс.Еда / Delivery',
    money: -3000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final samokat = OperationReceipt(
    name: '🥑 Самокат',
    money: -1000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final catsSummary = OperationReceipt(
    name: '🏠 Все для котов',
    money: -7000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final salaryKarim = OperationReceipt(
    name: '💰 ЗП Карим',
    money: 105000,
    type: ReceiptType.income,
    currency: AppCurrencies.ru,
  );

  static final salaryDarya = OperationReceipt(
    name: '💰 ЗП Дарья',
    money: 40000,
    type: ReceiptType.income,
    currency: AppCurrencies.ru,
  );

  static final ipotekaDarya = OperationReceipt(
    name: '🏢 Ипотека, самолет Дарья',
    money: 22500,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final ipotekaKarim = OperationReceipt(
    name: '🏢 Ипотека, самолет Карим',
    money: 37000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final refinanceCredit = OperationReceipt(
    name: '💳 Кредит, рефинансирование',
    money: 26000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  static final daryaManicure = OperationReceipt(
    name: '💅 Маникюр, Дарья',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 2000,
  );
  static final daryaHairSupport = OperationReceipt(
    name: '💅 Коррекция наращивания, Дарья',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 15000,
  );
  static final daryaPsychiatrist = OperationReceipt(
    name: '💅 Психиатр, Даша',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 5000,
  );
}
