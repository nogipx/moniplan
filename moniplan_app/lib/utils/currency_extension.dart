import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:moniplan_core/moniplan_core.dart';

extension CurrencyDouble on num {
  bool get isWhole => this % 1 == 0;

  String currency(CurrencyData currencyData, {Locale? locale}) {
    final localeTag = locale?.toLanguageTag();
    final value = NumberFormat.currency(
      symbol: currencyData.intlSymbol,
      decimalDigits: this % 1 == 0 ? 0 : currencyData.decimalDigits,
      locale: localeTag ?? currencyData.getLocale()?.toLanguageTag(),
    ).format(abs());
    if (this >= 0) {
      return value;
    } else {
      return '- $value';
    }
  }
}

extension CurrencyExt on CurrencyData {
  static final _format = NumberFormat();

  static const _overrideSimpleCurrency = <String, String>{
    'RUB': '₽',
  };

  static final currencies =
      (numberFormatSymbols as Map<String, NumberSymbols>).map<String, NumberSymbols>(
    (key, value) => MapEntry<String, NumberSymbols>(
      value.DEF_CURRENCY_CODE,
      value,
    ),
  );

  NumberSymbols? get numberSymbols => currencies[isoCode];

  Locale? getLocale() {
    final locale = Locale.tryParse(numberSymbols?.NAME ?? '');
    if (locale == null) {
      AppLog('getLocale()').warning(
        'No found locale for Currency($isoCode, $symbol)',
      );
    }
    return locale;
  }

  String get intlSymbol =>
      _overrideSimpleCurrency[isoCode] ?? _format.simpleCurrencySymbol(isoCode);

  String get intlPattern => numberSymbols?.CURRENCY_PATTERN ?? '';
}
