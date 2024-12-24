import 'package:flutter/material.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MoneyColoredWidget extends StatelessWidget {
  final num? value;
  final TextStyle? textStyle;
  final CurrencyData currency;
  final Color? overrideColor;
  final bool showPlusSign;

  const MoneyColoredWidget({
    required this.value,
    required this.currency,
    this.textStyle,
    this.overrideColor,
    this.showPlusSign = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = value == 0 || value == null
        ? context.color.onSurfaceVariant
        : (value ?? 0) > 0
            ? context.extra.moneyPositive
            : context.extra.moneyNegative;

    final text =
        value != null ? (value! > 0 && showPlusSign ? '+ ' : '') + value!.currency(currency) : '-';

    return Text(
      text,
      textAlign: TextAlign.center,
      style: textStyle ?? context.text.bodyMedium?.copyWith(color: color),
    );
  }
}
