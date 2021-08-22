import 'package:flutter/material.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/app/theme.dart';
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
    final eventTotal = data.operations.total;
    final hintStyle = Theme.of(context).textTheme.caption!.copyWith(
          fontSize: 11,
          color: secondaryTextColor,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                "Имеется",
                style: hintStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                (data.budget - eventTotal).currency(currency),
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: primaryTextColor),
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
                style: hintStyle,
                textAlign: TextAlign.center,
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
                style: hintStyle,
                textAlign: TextAlign.center,
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
