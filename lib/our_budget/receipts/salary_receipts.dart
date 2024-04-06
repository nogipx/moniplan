import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SalaryReceipts implements OperationsProvider {
  static final salaryBristol = OperationReceipt(
    name: 'ЗП Бристоль',
    money: 297000,
    type: ReceiptType.income,
    currency: AppCurrencies.ru,
  );

  static final salaryUzumHalf = OperationReceipt(
    name: 'ЗП Узум',
    money: 125000,
    type: ReceiptType.income,
    currency: AppCurrencies.ru,
  );

  @override
  List<Operation> get operations {
    return [
      Operation(
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        receipt: salaryBristol,
      ),
      Operation(
        enabled: false,
        id: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.twoWeek,
        receipt: salaryUzumHalf,
      ),
    ];
  }
}
