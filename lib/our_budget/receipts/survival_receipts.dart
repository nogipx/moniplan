import 'package:moniplan/our_budget/_details.dart';
import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class SurvivalReceipts implements PaymentsProvider {
  @override
  List<Payment> get payments {
    return [
      Payment(
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        details: Details.rentHomeSuvorova,
      ),
      Payment(
        isDone: true,
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: Details.communalBelichenko,
      ),
      Payment(
        isDone: true,
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: Details.communalGondarya,
      ),
      Payment(
        isDone: true,
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 10),
        repeat: DateTimeRepeat.month,
        details: Details.communalSuvorova,
      ),
      Payment(
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.month,
        details: Details.catsSummary,
      ),
      Payment(
        paymentId: const Uuid().v4(),
        date: PeriodDateTime.currentYear(day: 8),
        repeat: DateTimeRepeat.month,
        details: Details.internet,
      ),
    ];
  }
}
