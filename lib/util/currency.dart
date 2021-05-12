import 'package:intl/intl.dart';

extension CurrencyDouble on double {
  bool get isWhole => this % 1 == 0;

  String get rubCurrencyString {
    final value = NumberFormat.currency(
      locale: "RU",
      symbol: "₽",
      decimalDigits: this % 1 == 0 ? 0 : 2,
    ).format(abs());
    if (this >= 0) {
      return value;
    } else {
      return "- $value";
    }
  }
}
