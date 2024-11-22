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
      child: payment.isRepeat
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payment.repeat.shortName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.theme.app.colors.text.secondary,
                      ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: context.theme.app.colors.text.secondary,
                ),
              ],
            )
          : const SizedBox(),
    );

    final controlsWidget = SizedBox(
      width: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (payment.isDone)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.done_outlined,
                size: 16,
                color: payment.isDone
                    ? context.theme.app.colors.palette.primary
                    : context.theme.app.colors.text.secondary,
              ),
            ),
          if (!payment.isEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.power_settings_new_rounded,
                size: 16,
                color: context.theme.app.colors.palette.primary,
              ),
            ),
        ],
      ),
    );

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Grayscale(
                grayscale: !payment.isEnabled || payment.isDone,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      payment.details.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: payment.isEnabled
                                ? context.theme.app.colors.text.primary
                                : context.theme.app.colors.text.secondary,
                            fontSize: 16,
                            decoration: !payment.isEnabled ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    const SizedBox(height: 8),
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
                          color: context.theme.app.colors.text.secondary,
                        ),
                        const SizedBox(width: 4),
                        budgetPredictWidget,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                controlsWidget,
                const SizedBox(height: 4),
                repeatWidget,
              ],
            )
          ],
        ),
      ),
    );
  }
}
