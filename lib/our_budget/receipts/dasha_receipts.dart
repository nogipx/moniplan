import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class DashaReceipts implements PaymentsProvider {
  static final daryaManicure = PaymentDetails(
    name: '💅 Маникюр, Дарья',
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    money: 3000,
  );
  static final daryaHairSupport = PaymentDetails(
    name: '💅 Коррекция наращивания, Дарья',
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    money: 20000,
  );
  static final daryaPsychiatrist = PaymentDetails(
    name: '💅 Прием у психиатра, Даша',
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    money: 3000,
  );
  static final daryaPsycholog = PaymentDetails(
    name: '💅 Прием у психолога, Даша',
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    money: 3000,
  );
  static final daryaTabletki = PaymentDetails(
    name: '💅 Таблетки, Даша',
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
    money: 5000,
  );

  // Даша
  static final daryaLifeMonth = PaymentDetails(
    name: '💅 Даше на жизнь',
    money: 50000,
    type: PaymentType.expense,
    currency: AppCurrencies.ru,
  );

  @override
  List<Payment> get payments {
    return [
      // Payment(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 8),
      //   repeat: DateTimeRepeat.twoWeek,
      //   details: daryaManicure,
      // ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 16),
        dateStart: DateTime.now().monthStart,
        repeat: DateTimeRepeat.threeMonths,
        details: daryaHairSupport,
      ),
      // Payment(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 8),
      //   dateStart: DateTime.now().monthStart,
      //   repeat: DateTimeRepeat.month,
      //   details: daryaPsychiatrist,
      // ),
      // Payment(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 1),
      //   dateStart: DateTime.now().monthStart,
      //   repeat: DateTimeRepeat.twoWeek,
      //   details: daryaPsycholog,
      // ),
      // Payment(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 1),
      //   dateStart: DateTime.now().monthStart,
      //   repeat: DateTimeRepeat.threeWeek,
      //   details: daryaTabletki,
      // ),
      Payment(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        details: daryaLifeMonth,
      ),
    ];
  }
}
