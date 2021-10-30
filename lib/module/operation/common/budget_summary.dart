import 'package:flutter/material.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/module/operation/export.dart';

class BudgetSummaryWidget extends StatelessWidget {
  final double summaryValue;
  final Currency currency;

  const BudgetSummaryWidget({
    Key? key,
    required this.summaryValue,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final eventTotal = data.operations.total;
    // final hintStyle =
    //     Theme.of(context).textTheme.caption!.copyWith(fontSize: 11);

    return Row(
      children: [
        // Text(
        //   "Общий итог",
        //   style: hintStyle,
        //   textAlign: TextAlign.center,
        // ),
        // SizedBox(width: 8),
        CurrencyColorWidget(
          value: summaryValue,
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
