import 'package:flutter/material.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentListSeparator extends StatelessWidget {
  final Payment? previousPayment;
  final Payment? nextPayment;
  final DateTime today;

  const PaymentListSeparator({
    this.previousPayment,
    this.nextPayment,
    required this.today,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final prevDate = previousPayment?.date.dayBound ?? DateTime(0);
    final nextDate = nextPayment?.date.dayBound;

    final isMonthEdge = previousPayment == null ||
        (nextDate != null && prevDate != DateTime(0) && nextDate.month != prevDate.month);
    final isNextDay = previousPayment == null ||
        (nextDate != null && prevDate != DateTime(0) && nextDate.day != prevDate.day);

    final isTodayBetweenPrevAndNextDay = previousPayment == null ||
        (nextDate != null &&
            prevDate.compareTo(today) <= 0 &&
            nextDate.compareTo(today) >= 0 &&
            prevDate != today &&
            nextDate != today);

    final isTodayBetweenPrevAndNextMonth = previousPayment == null ||
        (nextDate != null &&
            prevDate.monthBound.compareTo(today) <= 0 &&
            nextDate.monthBound.compareTo(today) >= 0 &&
            prevDate != today &&
            nextDate != today);

    Widget result = SizedBox.shrink();
    final emptyToday = isTodayBetweenPrevAndNextDay
        ? Column(
            children: [
              _daySeparator(today, today),
              _noPaymentsDay(),
            ],
          )
        : const SizedBox.shrink();

    final month = isTodayBetweenPrevAndNextMonth || isMonthEdge
        ? _monthSeparator(nextDate ?? today)
        : const SizedBox.shrink();

    if (previousPayment == null && nextDate != null) {
      result = Column(
        children: [
          if (previousPayment == null) _monthSeparator(nextDate),
          _daySeparator(nextDate, today),
        ],
      );
    } else if (isMonthEdge) {
      result = Column(
        children: [
          if (previousPayment == null) _monthSeparator(today),
          month,
          emptyToday,
          _daySeparator(nextDate ?? today, today),
        ],
      );
    } else if (isNextDay) {
      result = Column(
        children: [
          if (previousPayment == null) _daySeparator(today, today),
          emptyToday,
          _daySeparator(nextDate ?? today, today),
        ],
      );
    }
    return result;
  }

  Widget _daySeparator(DateTime date, DateTime today) {
    return PaymentListDaySeparator(date: date, today: today);
  }

  Widget _monthSeparator(DateTime date) {
    return PaymentListMonthSeparator(date: date);
  }

  Widget _noPaymentsDay() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
          child: Text('Нет платежей на сегодня'),
        );
      },
    );
  }
}
