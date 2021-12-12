import 'dart:developer' show log;

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:money2/money2.dart';

export 'package:money2/money2.dart';

class CurrencyConverter
    implements JsonConverter<Currency, Map<dynamic, dynamic>?> {
  const CurrencyConverter();

  @override
  Currency fromJson(Map<dynamic, dynamic>? json) {
    if (json != null) {
      return Currency.create(
        json['code'] as String,
        json['precision'] as int,
      );
    } else {
      return CommonCurrencies().usd;
    }
  }

  @override
  Map<String, dynamic> toJson(Currency object) {
    return <String, dynamic>{
      'code': object.code,
      'precision': object.scale,
    };
  }
}

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
    "RUB": r"₽",
  };

  static final currencies = numberFormatSymbols.map<String, NumberSymbols>(
      (dynamic key, dynamic value) =>
          MapEntry((value as NumberSymbols).DEF_CURRENCY_CODE, value));

  NumberSymbols? get numberSymbols => currencies[code];

  Locale? getLocale() {
    final locale = Locale.tryParse(numberSymbols?.NAME ?? "");
    if (locale == null) {
      log("No found locale for Currency($code, $symbol)",
          name: "CurrencyDouble");
    }
    return locale;
  }

  String get intlSymbol =>
      _overrideSimpleCurrency[code] ?? _format.simpleCurrencySymbol(code);

  String get intlPattern => numberSymbols?.CURRENCY_PATTERN ?? "";
}
