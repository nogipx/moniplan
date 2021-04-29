import 'package:money2/money2.dart';

final rubExtendedCurrency =
    Currency.create("RUB", 2, symbol: "₽", pattern: "0.00 S");
final rubSimpleCurrency =
    Currency.create("RUB", 0, symbol: "₽", pattern: "0 S");

extension CurrencyDouble on double {
  bool get isWhole => this % 1 == 0;

  Currency get rubCurrency => isWhole ? rubSimpleCurrency : rubExtendedCurrency;
}
