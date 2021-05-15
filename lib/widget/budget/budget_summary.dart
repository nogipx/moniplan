import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/util/export.dart';

class CurrencyColorWidget extends StatelessWidget {
  final double value;
  final TextStyle? textStyle;
  final Currency currency;

  const CurrencyColorWidget({
    Key? key,
    required this.value,
    required this.currency,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = value == 0
        ? Colors.grey
        : value > 0
            ? Colors.green
            : Colors.red;

    return Container(
      child: Text(
        (value > 0 ? '+ ' : '') + value.currency(currency),
        textAlign: TextAlign.center,
        style: (textStyle ?? Theme.of(context).textTheme.caption)
            ?.apply(color: color),
      ),
    );
  }
}

class BudgetSummaryWidget extends StatelessWidget {
  final BudgetPrediction data;
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
          child: Text(
            (data.predictionValue - eventTotal).currency(currency),
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.caption?.copyWith(
                  color: textColor,
                ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: CurrencyColorWidget(
            value: eventTotal,
            currency: currency,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            data.predictionValue.currency(currency),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
