import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SurvivalReceipts implements PaymentsProvider {
  // Аренда
  static final rentHomeSuvorova = PaymentDetails(
    name: 'Аренда Суворова',
    money: 43000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final rentHomeSamolet = PaymentDetails(
    name: '💅 Аренда Самолет',
    money: 24000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  // Коммуналка
  static final communalSuvorova = PaymentDetails(
    name: 'Коммуналка Суворова',
    money: -5500,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final communalBelichenko = PaymentDetails(
    name: 'Коммуналка Беличенко',
    money: -2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final communalGondarya = PaymentDetails(
    name: 'Коммуналка Гондаря',
    money: -2600,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final communalSamolet = PaymentDetails(
    name: '💅 Коммуналка Самолет Даша',
    money: -4000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );
  static final internet = PaymentDetails(
    name: 'Интернеты и серверы',
    money:
        // даша инет
        (350 + 600) +
            // карим инет
            (900 + 800) +
            // впн (россия и сербия)
            (600 + 600),
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

  @override
  List<Payment> get payments {
    return [
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 3),
        repeat: DateTimeRepeat.month,
        details: rentHomeSamolet,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        details: rentHomeSuvorova,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: communalBelichenko,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: communalGondarya,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: communalSuvorova,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: communalSamolet,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.month,
        details: catsSummary,
      ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.month,
        details: internet,
      ),
    ];
  }
}
