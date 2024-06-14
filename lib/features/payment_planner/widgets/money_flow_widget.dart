import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

class MoneyFlowWidget extends StatelessWidget {
  final MoneyFlowUseCaseResult state;

  const MoneyFlowWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall;
    final divider = SizedBox(
      height: 30,
      child: VerticalDivider(
        thickness: 1,
        width: 1,
        color: MoniplanColors.inactiveTextColor,
      ),
    );

    return Material(
      color: MoniplanColors.white,
      elevation: .5,
      child: Padding(
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
                    currency: AppCurrencies.ru,
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
                    currency: AppCurrencies.ru,
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
                    currency: AppCurrencies.ru,
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
                    currency: AppCurrencies.ru,
                    showPlusSign: false,
                    textStyle: textStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
