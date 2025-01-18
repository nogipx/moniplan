// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/features/_common/_index.dart';
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
    final shouldGrayscale = !payment.isEnabled || payment.isDone;

    final budgetPredictWidget = mediateSummary != null
        ? MoneyColoredWidget(
            value: mediateSummary,
            currency: payment.details.currency,
            showPlusSign: false,
            overridePositiveColor: context.color.tertiary,
          )
        : const SizedBox();

    final repeatWidget = SizedBox(
      child: payment.isRepeat
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payment.repeat.shortName,
                  style: context.theme.textTheme.labelMedium,
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.refresh_rounded,
                  size: 18,
                ),
              ],
            )
          : const SizedBox(),
    );

    final controlsWidget = Padding(
      padding: EdgeInsets.only(right: shouldGrayscale ? 4 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (payment.isDone)
            Icon(
              Icons.done_outlined,
              size: 16,
              color: context.ext<MoniplanExtraColors>()?.moneyPositive,
            ),
          if (!payment.isEnabled)
            Icon(
              Icons.power_settings_new_rounded,
              size: 16,
              color: context.ext<MoniplanExtraColors>()?.moneyNegative,
            ),
        ],
      ),
    );

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: controlsWidget,
                ),
                Expanded(
                  child: Grayscale(
                    grayscale: shouldGrayscale,
                    child: Text(
                      payment.details.name,
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: payment.isEnabled ? null : context.color.onSurface,
                      ),
                    ),
                  ),
                ),
                Grayscale(
                  grayscale: shouldGrayscale,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: repeatWidget,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Grayscale(
              grayscale: shouldGrayscale,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: MoneyColoredWidget(
                        value: payment.normalizedMoney,
                        currency: payment.details.currency,
                      ),
                    ),
                  ),
                  if (payment.isEnabled)
                    Expanded(
                      child: budgetPredictWidget,
                    ),
                  Expanded(child: const SizedBox())
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
