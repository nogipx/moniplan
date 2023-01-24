import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:moniplan_core/moniplan_core.dart';

class MoneyColoredWidget extends StatelessWidget {
  final double? value;
  final TextStyle? textStyle;
  final Currency currency;
  final Color? overrideColor;
  final bool showPlusSign;

  const MoneyColoredWidget({
    required this.value,
    required this.currency,
    this.textStyle,
    this.overrideColor,
    this.showPlusSign = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = value == 0 || value == null
        ? Colors.blueGrey.shade300
        : (value ?? 0) > 0
            ? Colors.green
            : Colors.red.shade400;

    final text = value != null
        ? (value! > 0 && showPlusSign ? '+ ' : '') + value!.currency(currency)
        : '-';

    return Text(
      text,
      textAlign: TextAlign.center,
      style: (textStyle ?? Theme.of(context).textTheme.bodyText1)
          ?.apply(color: overrideColor ?? color),
    );
  }
}
