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
    implanon,
    hairCorrection,
    cosmetic,
    gym,
  ];

  static final ipotekaLower = PaymentDetails(
    name: 'Ипотека поменьше',
    // money: 23000,
    money: 30000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.longTimeDebt,
      Tags.required,
      Tags.everyMonth,
    },
    note: 'После того как закончим оформление и сделаем закладную будет 23000',
  );

  static final ipotekaGreater = PaymentDetails(
    name: 'Ипотека побольше',
    // money: 37000,
    money: 40000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.longTimeDebt,
      Tags.required,
      Tags.everyMonth,
    },
    note: 'После того как закончим оформление и сделаем закладную будет 37000',
  );

  static final refinanceCredit = PaymentDetails(
    name: 'Кредит Альфа',
    money: 26000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.required,
      Tags.everyMonth,
    },
    note: 'Кредитные каникулы. Следующий платеж 06.09.2024',
  );

  static final creditTashkent = PaymentDetails(
    name: 'Вернуть заем на Ташкент',
    money: 90000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.singleTime,
      Tags.required,
    },
    note: 'Вернуть 5-го июля, как плоучу деньги от узума',
  );

  static final creditCardTinkoff = PaymentDetails(
    name: 'Кредитка Тинькофф',
    money: 18000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.required,
      Tags.everyMonth,
    },
    note: 'Планирую закрыть с оплаты за период работы без контракта в узуме',
  );

  static final creditCardAlfa = PaymentDetails(
    name: 'Кредитка Альфа',
    money: 6600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.required,
      Tags.everyMonth,
    },
    note: 'Тут все ок, платим как обычно',
  );

  static final splitGooglePixelForce = PaymentDetails(
    name: 'Сплит пиксель (досрок)',
    money: 28000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.singleTime,
      Tags.required,
    },
    note: 'Хочу закрыть досрочно',
  );

  static final kubishkaFullfill = PaymentDetails(
    name: 'Погашение кубышки',
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    money: 42000,
    tags: {
      Tags.singleTime,
      Tags.required,
    },
    note: 'Больше не хочу брать из кубышки. '
        'Но с другой стороны, это на крайний случай хороший вариант.'
        'Нужно гасить как можно раньше.',
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
      Tags.required,
      Tags.everyMonth,
      Tags.longTimeDebt,
    },
    note: 'Ну да, я лох',
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
    },
    note: 'Приходит 7-го числа. В точку.',
  );

  static final salaryUzumHalf = PaymentDetails(
    name: 'ЗП Узум',
    money: 120000,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
    tags: {
      Tags.income,
    },
    note: 'Приходит 5-го числа и 20-го числа. В узумбанк. '
        '\n20.06.2024 придет 120к'
        '\n05.07.2024 придет примерно 120к + 240к + 60к = 420к',
  );
  static final salaryCopix = PaymentDetails(
    name: 'ЗП Copix',
    money: 250000,
    tax: 0.01,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
    tags: {
      Tags.income,
    },
    note: 'Приходит 15 числа. В точку.',
  );

  // Аренда
  static final rentHomeSuvorova = PaymentDetails(
    name: 'Аренда Суворова',
    money: 43000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.required,
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
      Tags.required,
      Tags.everyMonth,
    },
  );
  static final communalBelichenko = PaymentDetails(
    name: 'Коммуналка Беличенко',
    money: 2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.required,
      Tags.everyMonth,
    },
  );
  static final communalGondarya = PaymentDetails(
    name: 'Коммуналка Гондаря',
    money: 2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.required,
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
      Tags.required,
      Tags.everyMonth,
    },
  );
  static final catsSummary = PaymentDetails(
    name: 'Все для котов',
    money: 10000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.required,
      Tags.everyMonth,
    },
  );
  static final implanon = PaymentDetails(
    name: 'Импланон Даше',
    money: 20000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.dasya,
      Tags.singleTime,
    },
    note: 'Чтобы кончать внутрь',
  );
  static final hairCorrection = PaymentDetails(
    name: 'Коррекция волос',
    money: 20000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.dasya,
      Tags.required,
      Tags.irregular,
    },
  );
  static final cosmetic = PaymentDetails(
      name: 'Уходовая косметика',
      money: 16000,
      type: PaymentType.expense,
      currency: AppCurrencies.ru,
      tags: {
        Tags.dasya,
        Tags.irregular,
      },
      note: 'Скинжестик важнее почки');
  static final gym = PaymentDetails(
    name: 'Абонемент качалка Даше',
    money: 15000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    tags: {
      Tags.dasya,
      Tags.singleTime,
    },
    note: '50 посещений',
  );
}
