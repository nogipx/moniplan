import 'dart:developer' show log;

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:money2/money2.dart';

extension CurrencyDouble on double {
  bool get isWhole => this % 1 == 0;

  String currency(Currency currency, {Locale? locale}) {
    final localeTag = locale?.toLanguageTag();
    final value = NumberFormat.currency(
      symbol: currency.intlSymbol,
      decimalDigits: this % 1 == 0 ? 0 : currency.scale,
      locale: localeTag ?? currency.getLocale()?.toLanguageTag(),
    ).format(abs());
    if (this >= 0) {
      return value;
    } else {
      return '- $value';
    }
  }
}

extension CurrencyExt on Currency {
  static final _format = NumberFormat();

  static const _overrideSimpleCurrency = <String, String>{
    'RUB': '₽',
  };

  static final currencies = (numberFormatSymbols as Map<String, NumberSymbols>)
      .map<String, NumberSymbols>(
    (key, value) => MapEntry<String, NumberSymbols>(
      value.DEF_CURRENCY_CODE,
      value,
    ),
  );

  NumberSymbols? get numberSymbols => currencies[code];

  Locale? getLocale() {
    final locale = Locale.tryParse(numberSymbols?.NAME ?? '');
    if (locale == null) {
      log(
        'No found locale for Currency($code, $symbol)',
        name: 'CurrencyDouble',
      );
    }
    return locale;
  }

  String get intlSymbol =>
      _overrideSimpleCurrency[code] ?? _format.simpleCurrencySymbol(code);

  String get intlPattern => numberSymbols?.CURRENCY_PATTERN ?? '';
}
