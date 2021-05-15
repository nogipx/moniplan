import 'package:money2/money2.dart';
export "package:money2/money2.dart";

extension SerializableCurrency on Currency {
  static Currency fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return Currency.create(
        json['code'] as String,
        json['precision'] as int,
        symbol: json['symbol'] as String,
        pattern: json['pattern'] as String,
        invertSeparators: json['invertSeparators'] as bool,
      );
    } else {
      return CommonCurrencies().usd;
    }
  }

  static Map<String, dynamic> toJson(Currency currency) {
    return <String, dynamic>{
      'code': currency.code,
      'precision': currency.precision,
      'symbol': currency.symbol,
      'pattern': currency.pattern,
      'invertSeparators': currency.invertSeparators
    };
  }
}
