import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:planimon/sdk/domain.dart';
import 'package:planimon/util/export.dart';

class OperationWidget extends StatelessWidget {
  final Operation operation;
  final Color? textColor;

  const OperationWidget({
    Key? key,
    required this.operation,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final operationSign = operation.type == OperationType.Income ? "+" : "-";
    final money = Money.from(
      operation.value,
      operation.value.rubCurrency,
    );
    final textStyle = Theme.of(context).textTheme.caption?.copyWith(
          decorationThickness: 3,
          decorationStyle: TextDecorationStyle.solid,
          decoration: operation.enabled
              ? TextDecoration.none
              : TextDecoration.lineThrough,
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            operation.reason.isNotEmpty ? operation.reason : "No reason",
            style: textStyle?.apply(color: textColor),
          ),
        ),
        SizedBox(width: 8),
        Text(
          "$operationSign $money",
          style: textStyle?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
