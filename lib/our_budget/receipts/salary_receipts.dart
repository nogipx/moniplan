import 'package:moniplan/our_budget/_details.dart';
import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SalaryReceipts implements PaymentsProvider {
  @override
  List<Payment> get payments {
    return [
      Payment(
        paymentId: newUuid,
        isDone: true,
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        details: Details.salaryBristol.copyWith(money: 326000),
      ),
      Payment(
        isDone: true,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: PaymentDetails(
          name: 'Возврат из налогов',
          type: PaymentType.income,
          currency: AppCurrencies.ru,
          money: 4100,
        ),
      ),
      Payment(
        isEnabled: false,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.twoWeek,
        details: Details.salaryUzumHalf,
      ),
      Payment(
        isEnabled: false,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        details: Details.salaryCopix,
      ),
    ];
  }
}
