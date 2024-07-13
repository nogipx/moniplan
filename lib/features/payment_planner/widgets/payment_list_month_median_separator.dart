import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListMonthMedianSeparator extends StatelessWidget {
  final DateTime date;

  const PaymentListMonthMedianSeparator({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        'Середина ${DateFormat(DateFormat.MONTH, 'ru').format(date)}',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: MoniplanColors.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
