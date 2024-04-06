import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class DashaReceipts implements OperationsProvider {
  static final daryaManicure = OperationReceipt(
    name: '💅 Маникюр, Дарья',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 3000,
  );
  static final daryaHairSupport = OperationReceipt(
    name: '💅 Коррекция наращивания, Дарья',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 20000,
  );
  static final daryaPsychiatrist = OperationReceipt(
    name: '💅 Прием у психиатра, Даша',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 3000,
  );
  static final daryaPsycholog = OperationReceipt(
    name: '💅 Прием у психолога, Даша',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 3000,
  );
  static final daryaTabletki = OperationReceipt(
    name: '💅 Таблетки, Даша',
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
    money: 5000,
  );

  // Даша
  static final daryaLifeMonth = OperationReceipt(
    name: 'Даше на жизнь',
    money: 50000,
    type: ReceiptType.outcome,
    currency: AppCurrencies.ru,
  );

  @override
  List<Operation> get operations {
    return [
      // Operation(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 8),
      //   repeat: DateTimeRepeat.twoWeek,
      //   receipt: daryaManicure,
      // ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 16),
        dateStart: DateTime.now().monthStart,
        repeat: DateTimeRepeat.threeMonths,
        receipt: daryaHairSupport,
      ),
      // Operation(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 8),
      //   dateStart: DateTime.now().monthStart,
      //   repeat: DateTimeRepeat.month,
      //   receipt: daryaPsychiatrist,
      // ),
      // Operation(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 1),
      //   dateStart: DateTime.now().monthStart,
      //   repeat: DateTimeRepeat.twoWeek,
      //   receipt: daryaPsycholog,
      // ),
      // Operation(
      //   id: const Uuid().v4(),
      //   date: PeriodDateTime.currentYear(day: 1),
      //   dateStart: DateTime.now().monthStart,
      //   repeat: DateTimeRepeat.threeWeek,
      //   receipt: daryaTabletki,
      // ),
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        receipt: daryaLifeMonth,
      ),
    ];
  }
}
