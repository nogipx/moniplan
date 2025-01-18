// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MoneyColoredWidget extends StatelessWidget {
  final num? value;
  final TextStyle? textStyle;
  final CurrencyData currency;
  final Color? overridePositiveColor;
  final Color? overrideNegativeColor;
  final bool showPlusSign;

  const MoneyColoredWidget({
    required this.value,
    required this.currency,
    this.textStyle,
    this.overridePositiveColor,
    this.overrideNegativeColor,
    this.showPlusSign = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = value == 0 || value == null
        ? context.color.onSurfaceVariant
        : (value ?? 0) > 0
            ? overridePositiveColor ?? context.extra.moneyPositive
            : overrideNegativeColor ?? context.extra.moneyNegative;

    final text =
        value != null ? (value! > 0 && showPlusSign ? '+ ' : '') + value!.currency(currency) : '-';

    return Text(
      text,
      textAlign: TextAlign.center,
      style: textStyle ?? context.text.bodyMedium?.copyWith(color: color),
    );
  }
}
