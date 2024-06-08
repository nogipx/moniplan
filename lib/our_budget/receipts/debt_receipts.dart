import 'package:moniplan_core/moniplan_core.dart';

import '../_index.dart';

class DebtReceipts implements PaymentsProvider {
  @override
  List<Payment> get payments {
    return [
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 16),
        repeat: DateTimeRepeat.month,
        details: Details.ipotekaLower,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        details: Details.ipotekaGreater,
      ),
      Payment(
        isEnabled: false,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 6),
        dateStart: PeriodDateTime.currentYear(day: 5, month: 9),
        repeat: DateTimeRepeat.month,
        details: Details.refinanceCredit,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 14),
        repeat: DateTimeRepeat.month,
        details: Details.creditCardTinkoff,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        details: Details.creditCardAlfa,
      ),
      Payment(
        isEnabled: false,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 6, month: 6),
        details: Details.splitGooglePixelForce,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 6, month: 6),
        details: Details.creditTashkent,
      ),
      Payment(
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 15),
        details: Details.creditCar,
        repeat: DateTimeRepeat.month,
      ),
      Payment(
        isEnabled: false,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 6, month: 6),
        details: Details.kubishkaFullfill,
      ),
    ];
  }
}
