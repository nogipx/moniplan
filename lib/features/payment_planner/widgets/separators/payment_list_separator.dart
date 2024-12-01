import 'package:flutter/material.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListSeparator extends StatelessWidget {
  final DateTime currDate;
  final List<Payment>? payments;
  final DateTime today;
  final double animationValue;
  final double stuckAmount;
  final bool isMonthEdge;

  const PaymentListSeparator({
    required this.today,
    required this.currDate,
    this.payments,
    this.animationValue = 0,
    this.stuckAmount = 0,
    this.isMonthEdge = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const shrink = SizedBox.shrink();

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.color.surface,
              context.color.surface.withOpacity(.8),
              context.color.surface.withOpacity(0),
            ],
            stops: [0, .8, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMonthEdge) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isMonthEdge)
                    Expanded(
                      child: Visibility(
                        visible: isMonthEdge,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${DateFormat(DateFormat.MONTH).format(currDate).capitalize()} '
                                '${currDate.year}',
                                style: context.text.displaySmall?.copyWith(
                                  color: context.color.surfaceTint,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(child: shrink),
                  PaymentListDaySeparator(date: currDate, today: today),
                  Expanded(child: shrink),
                ],
              ),
            ),
            if (payments != null && payments!.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 8, 24),
                child: Text('Нет платежей на сегодня'),
              ),
          ],
        ),
      ),
    );
  }
}
