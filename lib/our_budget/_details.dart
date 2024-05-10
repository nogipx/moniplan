import 'package:moniplan_core/moniplan_core.dart';

String get newUuid => const Uuid().v4();

abstract class Details {
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
    name: 'Кредитка Тинькофф',
    money: 18000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final creditCardAlfa = PaymentDetails(
    name: 'Кредитка Альфа',
    money: 6600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final splitGooglePixel = PaymentDetails(
    name: 'Сплит пиксель',
    money: 21500,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final daryaLifeMonth = PaymentDetails(
    name: 'Содержанка Даша',
    money: 70000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final natashaLifeMonth = PaymentDetails(
    name: 'Содержанка Наташа',
    money: 50000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  static final salaryBristol = PaymentDetails(
    name: 'ЗП Бристоль',
    money: 340000 * 0.99,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
  );

  static final salaryUzumHalf = PaymentDetails(
    name: 'ЗП Узум',
    money: 125000,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
  );
  static final salaryCopix = PaymentDetails(
    name: 'ЗП Copix',
    money: 250000,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
  );

  // Аренда
  static final rentHomeSuvorova = PaymentDetails(
    name: 'Аренда Суворова',
    money: 43000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  // Коммуналка
  static final communalSuvorova = PaymentDetails(
    name: 'Коммуналка Суворова',
    money: 5500,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final communalBelichenko = PaymentDetails(
    name: 'Коммуналка Беличенко',
    money: 2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final communalGondarya = PaymentDetails(
    name: 'Коммуналка Гондаря',
    money: 2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final internet = PaymentDetails(
    name: 'Интернеты и серверы',
    money:
        // карим инет
        (900 + 800) +
            // впн (сербия)
            (600),
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  // Коты
  static final catsSummary = PaymentDetails(
    name: 'Все для котов',
    money: -10000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
}
