import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MoneyColoredWidget extends StatelessWidget {
  final num? value;
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = value == 0 || value == null
        ? context.theme.app.colors.text.disabled
        : (value ?? 0) > 0
            ? context.theme.app.colors.text.accent
            : context.theme.app.colors.text.error;

    final text =
        value != null ? (value! > 0 && showPlusSign ? '+ ' : '') + value!.currency(currency) : '-';

    return Text(
      text,
      textAlign: TextAlign.center,
      style: (textStyle ?? Theme.of(context).textTheme.bodyLarge)
          ?.apply(color: overrideColor ?? color),
    );
  }
}
