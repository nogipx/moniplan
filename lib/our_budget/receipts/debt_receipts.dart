import 'package:moniplan/our_budget/_details.dart';
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
        repeat: DateTimeRepeat.month,
        details: Details.refinanceCredit,
      ),
      Payment(
        isDone: true,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 14),
        repeat: DateTimeRepeat.month,
        details: Details.creditCardTinkoff,
      ),
      Payment(
        isDone: true,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 21),
        repeat: DateTimeRepeat.month,
        details: Details.creditCardAlfa,
      ),
      Payment(
        isDone: true,
        paymentId: newUuid,
        date: PeriodDateTime.currentYear(day: 26),
        dateStart: DateTime(2024, 4, 12),
        dateEnd: DateTime(2024, 8, 26),
        repeat: DateTimeRepeat.month,
        details: Details.splitGooglePixel,
      ),
      Payment(
        isDone: true,
        paymentId: newUuid,
        date: DateTime(2024, 5, 10),
        details: PaymentDetails(
          name: 'Погашение кубышки',
          type: PaymentType.expense,
          currency: AppCurrencies.ru,
          money: 36500,
        ),
      ),
      Payment(
        isDone: true,
        paymentId: newUuid,
        date: DateTime(2024, 5, 10),
        details: PaymentDetails(
          name: 'Вывел в кошелек',
          type: PaymentType.expense,
          currency: AppCurrencies.ru,
          money: 1500,
        ),
      ),
    ];
  }
}
