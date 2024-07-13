import 'package:flutter/material.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentListSeparator extends StatelessWidget {
  final Payment currentPayment;
  final Payment nextPayment;
  final DateTime today;

  const PaymentListSeparator({
    required this.currentPayment,
    required this.nextPayment,
    required this.today,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currDate = currentPayment.date.onlyDate;
    final nextDate = nextPayment.date.onlyDate;

    final isMonthEdge = nextDate.month != currDate.month;
    final isHalfMonth = !isMonthEdge && nextDate.day > 15 && currDate.day <= 15;
    final isNextDay = nextDate.day != currDate.day;

    final isTodayBetweenCurrAndNext = currDate.compareTo(today) <= 0 &&
        nextDate.compareTo(today) >= 0 &&
        currDate != today &&
        nextDate != today;

    Widget result = SizedBox(height: 2);

    if (isMonthEdge) {
      result = Column(
        children: [
          _monthSeparator(nextDate),
          _daySeparator(nextDate, today),
        ],
      );
    } else if (isHalfMonth) {
      result = Column(
        children: [
          _medianSeparator(nextDate),
          _daySeparator(nextDate, today),
        ],
      );
    } else if (isNextDay) {
      result = _daySeparator(nextDate, today);

      if (isTodayBetweenCurrAndNext) {
        result = Column(
          children: [
            _daySeparator(today, today),
            _noPaymentsDay(),
            _daySeparator(nextDate, today),
          ],
        );
      }
    }
    return result;
  }

  Widget _daySeparator(DateTime date, DateTime today) {
    return PaymentListDaySeparator(date: date, today: today);
  }

  Widget _monthSeparator(DateTime date) {
    return PaymentListMonthSeparator(date: date);
  }

  Widget _medianSeparator(DateTime date) {
    return PaymentListMonthMedianSeparator(date: date);
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
