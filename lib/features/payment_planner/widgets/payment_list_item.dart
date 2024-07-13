import 'package:flutter/material.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentListItem extends StatelessWidget {
  const PaymentListItem({
    super.key,
    required this.payment,
    this.mediateSummary,
    this.onPressed,
  });

  final Payment payment;
  final num? mediateSummary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final budgetPredictWidget = mediateSummary != null
        ? MoneyColoredWidget(
            value: mediateSummary,
            currency: payment.details.currency,
            showPlusSign: false,
          )
        : const SizedBox();

    final repeatWidget = SizedBox(
      width: 40,
      child: payment.isRepeat
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payment.repeat.shortName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: MoniplanColors.secondaryTextColor,
                      ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: MoniplanColors.secondaryTextColor,
                ),
              ],
            )
          : const SizedBox(),
    );

    return Grayscale(
      grayscale: !payment.isEnabled || payment.isDone,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      payment.details.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: MoniplanColors.primaryTextColor,
                            fontWeight: FontWeight.w400,
                            decoration: payment.isDone ? TextDecoration.lineThrough : null,
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
                          value: payment.normalizedMoney,
                          currency: payment.details.currency,
                        ),
                        const SizedBox(width: 4),
                        Icon(
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
      ),
    );
  }
}
