import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/money_colored_widget.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan/useful/grayscale.dart';
import 'package:moniplan_core/moniplan_core.dart';

class OperationListItem extends StatelessWidget {
  final Operation operation;
  final double? mediateSummary;

  const OperationListItem({
    Key? key,
    required this.operation,
    this.mediateSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetPredictWidget = mediateSummary != null
        ? MoneyColoredWidget(
            value: mediateSummary,
            currency: operation.receipt.currency,
            showPlusSign: false,
          )
        : const SizedBox();

    final repeatWidget = operation.isRepeat
        ? Row(
            children: [
              Transform.scale(
                scaleX: -1,
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: MoniplanColors.disabledColor,
                ),
              ),
              // const SizedBox(width: 2),
              Text(operation.repeat.shortName)
            ],
          )
        : const SizedBox();

    return Grayscale(
      grayscale: !operation.enabled,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              operation.receipt.name,
              style: Theme.of(context).textTheme.subtitle2,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, 'RU')
                      .format(operation.date),
                  style: Theme.of(context).textTheme.caption?.copyWith(
                        fontSize: 14,
                      ),
                ),
                // const SizedBox(width: 8),
                // repeatWidget
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                MoneyColoredWidget(
                  value: operation.normalizedMoney,
                  currency: operation.receipt.currency,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_right,
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
    );
  }
}
