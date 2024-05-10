import 'package:moniplan/our_budget/_details.dart';
import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SoderzhankiReceipts implements PaymentsProvider {
  @override
  List<Payment> get payments {
    return [
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        details: Details.daryaLifeMonth,
        isDone: true,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 7),
        repeat: DateTimeRepeat.month,
        details: Details.natashaLifeMonth,
        isDone: true,
      ),
    ];
  }
}
