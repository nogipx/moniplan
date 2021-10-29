import 'package:flutter/material.dart';
import 'package:moniplan/sdk/domain.dart';
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
    // final eventTotal = data.operations.total;
    final hintStyle =
        Theme.of(context).textTheme.caption!.copyWith(fontSize: 11);

    return Row(
      children: [
        Text(
          "Общий итог",
          style: hintStyle,
          textAlign: TextAlign.center,
        ),
        SizedBox(width: 8),
        CurrencyColorWidget(
          value: data.budget,
          currency: currency,
          showPlusSign: false,
          textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
