import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListDaySeparator extends StatelessWidget {
  final DateTime date;
  final DateTime today;

  const PaymentListDaySeparator({
    required this.date,
    required this.today,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSameDay = today.isSameDay(date);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Material(
        elevation: 2,
        color: isSameDay ? context.color.scheme.primary : context.color.scheme.secondary,
        borderRadius: const BorderRadius.all(AppRadius.r16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: Text(
                DateFormat.MMMMd('ru').format(date),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSameDay
                          ? context.color.scheme.onPrimary
                          : context.color.scheme.onSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
