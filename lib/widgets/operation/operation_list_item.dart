import 'package:flutter/material.dart';
import 'package:moniplan/money_colored_widget.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan/useful/grayscale.dart';
import 'package:moniplan_core/moniplan_core.dart';

class OperationListItem extends StatelessWidget {
  final Operation operation;
  final double? mediateSummary;

  const OperationListItem({
    super.key,
    required this.operation,
    this.mediateSummary,
  });

  @override
  Widget build(BuildContext context) {
    final budgetPredictWidget = mediateSummary != null
        ? MoneyColoredWidget(
            value: mediateSummary,
            currency: operation.receipt.currency,
            showPlusSign: false,
          )
        : const SizedBox();

    final repeatWidget = SizedBox(
      width: 40,
      child: operation.isRepeat
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  operation.repeat.shortName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: MoniplanColors.secondaryTextColor,
                      ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: MoniplanColors.secondaryTextColor,
                ),
              ],
            )
          : const SizedBox(),
    );

    return Grayscale(
      grayscale: !operation.enabled,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    operation.receipt.name,
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: const Color(0xff1f1f1f),
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Row(
                  //   children: [
                  //     Text(
                  //       DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, 'RU')
                  //           .format(operation.date),
                  //       style: Theme.of(context).textTheme.caption?.copyWith(
                  //             fontSize: 14,
                  //           ),
                  //     ),
                  //     // const SizedBox(width: 8),
                  //     // repeatWidget
                  //   ],
                  // ),
                  // const SizedBox(height: 8),
                  Row(
                    children: [
                      MoneyColoredWidget(
                        value: operation.normalizedMoney,
                        currency: operation.receipt.currency,
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_right_alt_rounded,
                        size: 20,
                        color: MoniplanColors.disabledColor,
                      ),
                      const SizedBox(width: 4),
                      budgetPredictWidget,
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                repeatWidget,
              ],
            )
          ],
        ),
      ),
    );
  }
}
