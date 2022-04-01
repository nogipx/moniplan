import 'package:flutter/material.dart';
import 'package:moniplan/app/app_theme.dart';
import 'package:moniplan/sdk/domain/currency/currency.dart';

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
        ? AppTheme.disabledColor
        : (value ?? 0) > 0
            ? AppTheme.positiveMoneyColor
            : AppTheme.negativeMoneyColor;

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
