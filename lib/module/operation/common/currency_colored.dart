import 'package:flutter/material.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/sdk/domain/currency.dart';

class CurrencyColorWidget extends StatelessWidget {
  final double? value;
  final TextStyle? textStyle;
  final Currency currency;
  final Color? overrideColor;
  final bool showPlusSign;

  const CurrencyColorWidget({
    Key? key,
    required this.value,
    required this.currency,
    this.textStyle,
    this.overrideColor,
    this.showPlusSign = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = value == 0 || value == null
        ? AppTheme.disabledColor
        : (value ?? 0) > 0
            ? AppTheme.positiveMoneyColor
            : AppTheme.negativeMoneyColor;

    final _text = value != null
        ? (value! > 0 && showPlusSign ? '+ ' : '') + value!.currency(currency)
        : "-";

    return Container(
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: (textStyle ?? Theme.of(context).textTheme.bodyText1)
            ?.apply(color: overrideColor ?? color),
      ),
    );
  }
}
