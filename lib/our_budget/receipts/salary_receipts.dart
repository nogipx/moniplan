import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SalaryReceipts implements PaymentsProvider {
  static final salaryBristol = PaymentDetails(
    name: 'ЗП Бристоль',
    money: 293000,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
  );

  static final salaryUzumHalf = PaymentDetails(
    name: 'ЗП Узум',
    money: 125000,
    type: PaymentType.income,
    currency: AppCurrencies.ru,
  );

  @override
  List<Payment> get payments {
    return [
      Payment(
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        details: salaryBristol,
      ),
      Payment(
        isEnabled: false,
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.twoWeek,
        details: salaryUzumHalf,
      ),
    ];
  }
}
