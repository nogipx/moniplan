// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/services.dart';

class CurrencyTextInputFormatter extends TextInputFormatter {
  CurrencyTextInputFormatter({
    this.decimalDigits,
    this.allowNegative = true,
  });

  final int? decimalDigits;
  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      _format(oldValue: oldValue, newValue: newValue);

  String formatInitial(
    String value,
  ) =>
      _format(newValue: TextEditingValue(text: value), override: true).text;

  RegExp get forbiddenCharacters => RegExp(allowNegative ? r'[^0-9,.-]' : r'[^0-9,.]');

  TextEditingValue _format({
    TextEditingValue oldValue = const TextEditingValue(text: ''),
    required TextEditingValue newValue,
    bool override = false,
  }) {
    final bool isInsertedCharacter =
        oldValue.text.length + 1 == newValue.text.length && newValue.text.startsWith(oldValue.text);
    final bool isRemovedCharacter =
        oldValue.text.length - 1 == newValue.text.length && oldValue.text.startsWith(newValue.text);

    if (forbiddenCharacters.hasMatch(newValue.text)) {
      return oldValue;
    }
    if (newValue.text.endsWith('.')) {
      newValue = newValue.copyWith(text: newValue.text.replaceFirst('.', ','));
    }

    final bool isNegative = newValue.text.startsWith('-');

    if (override) {
      final number = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (number != null) {
        final decimal = number / (isNegative ? -100 : 100);
        final numberString =
            decimal % 1 == 0 ? decimal.toInt().toString() : decimal.toString().replaceAll('.', ',');
        return TextEditingValue(text: numberString);
      }
    }

    if (isNegative && oldValue.text.isEmpty) {
      return newValue;
    }

    final int commasCount = ','.allMatches(newValue.text).length;
    if (isInsertedCharacter && commasCount > 1) {
      return oldValue;
    }

    final bool isDecimal = commasCount > 0;
    if (isRemovedCharacter && commasCount == 1 && newValue.text.endsWith(',')) {
      return TextEditingValue(
        text: newValue.text.replaceFirst(',', ''),
        selection: TextSelection.fromPosition(
          TextPosition(offset: newValue.text.length - 1),
        ),
      );
    }

    if (isDecimal) {
      final newDecimalDigitsCount = newValue.text.split(',')[1].length;
      if (newDecimalDigitsCount > (decimalDigits ?? 0)) {
        return oldValue;
      }
    }
    return newValue;
  }
}
