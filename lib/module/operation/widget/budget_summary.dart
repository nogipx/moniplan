import 'package:flutter/material.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/_widget/export.dart';
import 'package:moniplan/module/operation/export.dart';

class BudgetSummaryWidget extends StatelessWidget {
  final Prediction data;
  final Currency currency;

  const BudgetSummaryWidget({
    Key? key,
    required this.data,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black87;
    final eventTotal = data.operations.total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                "Имеется",
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                (data.budget - eventTotal).currency(currency),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.caption?.copyWith(
                      color: textColor,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              Text(
                "Итог за день",
                style: Theme.of(context).textTheme.caption,
              ),
              CurrencyColorWidget(
                value: eventTotal,
                currency: currency,
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              Text(
                "Общий итог",
                style: Theme.of(context).textTheme.caption,
              ),
              CurrencyColorWidget(
                value: data.budget,
                currency: currency,
                textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
