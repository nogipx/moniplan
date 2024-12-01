import 'package:flutter/material.dart';
import 'package:moniplan/features/_common/_index.dart';
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
    const radius = AppRadius.r10;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: AppContourAnimation(
        isAnimated: isSameDay,
        customColor: context.color.surfaceTint,
        borderRadius: radius.value,
        duration: const Duration(seconds: 2),
        edgeInsets: const EdgeInsets.all(.4),
        minFraction: .05,
        maxFraction: .25,
        child: Container(
          decoration: BoxDecoration(
            color: isSameDay ? context.color.surfaceTint : context.color.surfaceContainer,
            borderRadius: BorderRadius.all(radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 8,
                ),
                child: Text(
                  DateFormat.MMMMd().format(date),
                  style: context.text.labelMedium?.copyWith(
                    color: isSameDay ? context.color.onInverseSurface : context.color.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
