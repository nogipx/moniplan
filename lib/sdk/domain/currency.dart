import 'package:json_annotation/json_annotation.dart';
import 'package:money2/money2.dart';
export "package:money2/money2.dart";

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
      'precision': object.precision,
    };
  }
}
