import 'package:flutter/material.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/util/export.dart';

class CurrencyColorWidget extends StatelessWidget {
  final double value;
  final TextStyle? textStyle;

  const CurrencyColorWidget({Key? key, required this.value, this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = value == 0
        ? Colors.grey
        : value > 0
            ? Colors.green
            : Colors.red;
    return Container(
      child: Text(
        (value > 0 ? '+ ' : '') + value.rubCurrencyString,
        textAlign: TextAlign.center,
        style: (textStyle ?? Theme.of(context).textTheme.caption)
            ?.apply(color: color),
      ),
    );
  }
}

class BudgetSummaryWidget extends StatelessWidget {
  final BudgetPrediction data;

  const BudgetSummaryWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black87;
    final eventTotal = data.operations.total;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            (data.predictionValue - eventTotal).rubCurrencyString,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.caption?.copyWith(
                  color: textColor,
                ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(child: CurrencyColorWidget(value: eventTotal)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            data.predictionValue.rubCurrencyString,
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
