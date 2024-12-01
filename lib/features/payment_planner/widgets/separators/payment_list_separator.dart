import 'package:flutter/material.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentListSeparator extends StatelessWidget {
  final PaymentsDateGrouped datePayments;
  final Widget child;
  final DateTime? prevDate;
  final DateTime? nextDate;
  final DateTime today;

  const PaymentListSeparator({
    required this.today,
    required this.datePayments,
    required this.child,
    this.prevDate,
    this.nextDate,
    super.key,
  }) : assert(prevDate != null || nextDate != null);

  @override
  Widget build(BuildContext context) {
    final currDate = datePayments.date;

    final isMonthEdge = () {
      if (prevDate == null && nextDate != null) {
        return true;
      } else if (prevDate != null && nextDate == null) {
        return false;
      } else if (prevDate != null && prevDate!.month != currDate.month) {
        return true;
      }

      return false;
    }();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMonthEdge) _monthSeparator(currDate),
        Align(
          alignment: Alignment.bottomCenter,
          child: _daySeparator(currDate, today),
        ),
        if (datePayments.payments.isEmpty) _noPaymentsDay(),
        child,
      ],
    );
  }

  Widget _daySeparator(DateTime date, DateTime today) {
    return PaymentListDaySeparator(date: date, today: today);
  }

  Widget _monthSeparator(DateTime date) {
    return PaymentListMonthSeparator(date: date);
  }

  Widget _noPaymentsDay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
      child: Text('Нет платежей на сегодня'),
    );
  }
}
