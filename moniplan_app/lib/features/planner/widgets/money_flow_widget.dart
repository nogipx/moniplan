// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MoneyFlowWidget extends StatelessWidget {
  final MoneyFlowUseCaseResult state;

  const MoneyFlowWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = context.theme.textTheme.labelSmall;
    final divider = SizedBox(
      height: 30,
      child: VerticalDivider(
        thickness: 1,
        width: 1,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: SizedBox(
        height: 30,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start',
                  style: textStyle,
                ),
                MoneyColoredWidget(
                  value: state.initialBalance,
                  currency: CurrencyDataCommon.rub,
                  showPlusSign: false,
                  textStyle: textStyle,
                ),
              ],
            ),
            divider,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Income',
                  style: textStyle,
                ),
                MoneyColoredWidget(
                  value: state.totalIncome,
                  currency: CurrencyDataCommon.rub,
                  textStyle: textStyle,
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Expense',
                  style: textStyle,
                ),
                MoneyColoredWidget(
                  value: state.totalOutcome,
                  currency: CurrencyDataCommon.rub,
                  textStyle: textStyle,
                ),
              ],
            ),
            divider,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Result',
                  style: textStyle,
                ),
                MoneyColoredWidget(
                  value: state.balance,
                  currency: CurrencyDataCommon.rub,
                  showPlusSign: false,
                  textStyle: textStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
