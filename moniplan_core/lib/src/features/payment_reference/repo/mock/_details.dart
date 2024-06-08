import 'package:moniplan_core/moniplan_core.dart';

import '_tags.dart';

String get newUuid => const Uuid().v4();

abstract class Details {
  static final list = <PaymentDetails>[
    ipotekaLower,
    ipotekaGreater,
    refinanceCredit,
    creditTashkent,
    creditCardTinkoff,
    creditCardAlfa,
    splitGooglePixelForce,
    kubishkaFullfill,
    daryaLifeMonth,
    creditCar,
    natashaLifeMonth,
    salaryBristol,
    salaryUzumHalf,
    salaryUzumHalf,
    salaryCopix,
    rentHomeSuvorova,
    communalSuvorova,
    communalBelichenko,
    communalGondarya,
    internet,
    catsSummary,
  ];

  static final ipotekaLower = PaymentDetails(
    name: 'Ипотека поменьше',
    money: 23000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.longTimeDebt,
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );

  static final ipotekaGreater = PaymentDetails(
    name: 'Ипотека побольше',
    money: 37000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.longTimeDebt,
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );

  static final refinanceCredit = PaymentDetails(
    name: 'Кредит Альфа',
    money: 26000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );

  static final creditTashkent = PaymentDetails(
    name: 'Вернуть заем на Ташкент',
    money: 90000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.oneShotPayment,
      Tags.requiredPayments,
    },
  );

  static final creditCardTinkoff = PaymentDetails(
    name: 'Кредитка Тинькофф',
    money: 18000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );

  static final creditCardAlfa = PaymentDetails(
    name: 'Кредитка Альфа',
    money: 6600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );

  static final splitGooglePixelForce = PaymentDetails(
    name: 'Сплит пиксель (досрок)',
    money: 42500,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.oneShotPayment,
    },
  );

  static final kubishkaFullfill = PaymentDetails(
    name: 'Погашение кубышки',
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    money: 42000,
    tags: {
      Tags.oneShotPayment,
    },
  );

  static final daryaLifeMonth = PaymentDetails(
    name: 'Содержанка Даша',
    money: 90000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.dasya,
      Tags.soderzhanki,
      Tags.everyMonth,
    },
  );
  static final creditCar = PaymentDetails(
    name: 'Автокредит',
    money: 30000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.dasya,
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );
  static final natashaLifeMonth = PaymentDetails(
    name: 'Содержанка Наташа',
    money: 70000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.soderzhanki,
      Tags.everyMonth,
    },
  );

  static final salaryBristol = PaymentDetails(
    name: 'ЗП Бристоль',
    money: 340000,
    tax: 0.01,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
    tags: {
      Tags.income,
      Tags.everyMonth,
    },
  );

  static final salaryUzumHalf = PaymentDetails(
    name: 'ЗП Узум',
    money: 120000,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
    tags: {
      Tags.income,
      Tags.everyMonth,
    },
  );
  static final salaryCopix = PaymentDetails(
    name: 'ЗП Copix',
    money: 250000,
    tax: 0.01,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
    tags: {
      Tags.income,
      Tags.everyMonth,
    },
  );

  // Аренда
  static final rentHomeSuvorova = PaymentDetails(
    name: 'Аренда Суворова',
    money: 43000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );

  // Коммуналка
  static final communalSuvorova = PaymentDetails(
    name: 'Коммуналка Суворова',
    money: 5500,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );
  static final communalBelichenko = PaymentDetails(
    name: 'Коммуналка Беличенко',
    money: 2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );
  static final communalGondarya = PaymentDetails(
    name: 'Коммуналка Гондаря',
    money: 2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
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
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );

  // Коты
  static final catsSummary = PaymentDetails(
    name: 'Все для котов',
    money: 10000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.requiredPayments,
      Tags.everyMonth,
    },
  );
}
