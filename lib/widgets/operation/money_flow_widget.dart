import 'package:flutter/material.dart';
import 'package:moniplan/money_colored_widget.dart';
import 'package:moniplan_core/moniplan_core.dart';

class MoneyFlowWidget extends StatelessWidget {
  final MoneyFlowUseCaseResult state;

  const MoneyFlowWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Поступления'),
        MoneyColoredWidget(
          value: state.totalIncome,
          currency: AppCurrencies.ru,
        ),
        const SizedBox(height: 8),
        const Text('Траты'),
        MoneyColoredWidget(
          value: state.totalOutcome,
          currency: AppCurrencies.ru,
        ),
        const SizedBox(height: 8),
        const Text('Баланс'),
        MoneyColoredWidget(
          value: state.balance,
          currency: AppCurrencies.ru,
          showPlusSign: false,
        ),
      ],
    );
  }
}
