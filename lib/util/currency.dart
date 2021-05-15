import 'dart:developer' show log;

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:money2/money2.dart';

extension CurrencyDouble on double {
  bool get isWhole => this % 1 == 0;

  static final currencies = numberFormatSymbols.map<String, NumberSymbols>(
      (dynamic key, dynamic value) =>
          MapEntry((value as NumberSymbols).DEF_CURRENCY_CODE, value));

  String currency(Currency currency, {Locale? locale}) {
    final localeTag = locale?.toLanguageTag();
    final value = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: this % 1 == 0 ? 0 : currency.precision,
      locale: localeTag ?? currencies[currency.code]?.NAME,
    ).format(abs());
    if (this >= 0) {
      return value;
    } else {
      return "- $value";
    }
  }

  static Locale? getLocale(Currency currency) {
    final locale = Locale.tryParse(currencies[currency.code]?.NAME ?? "");
    if (locale == null) {
      log("No found locale for Currency(${currency.code}, ${currency.symbol})",
          name: "CurrencyDouble");
    }
    return locale;
  }
}
