import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SalaryReceipts implements PaymentsProvider {
  @override
  List<Payment> get payments {
    return [
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        details: Details.salaryBristol,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 5),
        repeat: DateTimeRepeat.month,
        details: Details.salaryUzumHalf,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 20),
        repeat: DateTimeRepeat.month,
        details: Details.salaryUzumHalf,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 15),
        repeat: DateTimeRepeat.month,
        details: Details.salaryCopix,
      ),
    ];
  }
}
