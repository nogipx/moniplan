import 'package:flutter/material.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/util/export.dart';

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
    final textStyle = Theme.of(context).textTheme.bodyText2?.copyWith(
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
            style: textStyle?.copyWith(color: textColor),
          ),
        ),
        SizedBox(width: 8),
        Text(
          (operation.result > 0 ? '+ ' : '') +
              operation.result.rubCurrencyString,
          style: textStyle?.copyWith(
            color: textColor,
          ),
        )
      ],
    );
  }
}
