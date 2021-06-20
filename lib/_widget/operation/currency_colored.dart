import 'package:flutter/material.dart';
import 'package:moniplan/_sdk/domain/currency.dart';

class CurrencyColorWidget extends StatelessWidget {
  final double? value;
  final TextStyle? textStyle;
  final Currency currency;
  final Color? overrideColor;

  const CurrencyColorWidget({
    Key? key,
    required this.value,
    required this.currency,
    this.textStyle,
    this.overrideColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = value == 0 || value == null
        ? Colors.grey
        : (value ?? 0) > 0
            // ? Color(0xff00B64F)
            ? Color(0xff00A287)
            : Color(0xffFB000D);
    // : Colors.red;

    final _text = value != null
        ? (value! > 0 ? '+ ' : '') + value!.currency(currency)
        : "-";

    return Container(
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: (textStyle ?? Theme.of(context).textTheme.caption)
            ?.apply(color: overrideColor ?? color),
      ),
    );
  }
}
