import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListMonthSeparator extends StatelessWidget {
  final DateTime date;

  const PaymentListMonthSeparator({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        '${DateFormat(DateFormat.MONTH, 'ru').format(date).capitalize()} ${date.year}',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: context.theme.app.colors.text.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
