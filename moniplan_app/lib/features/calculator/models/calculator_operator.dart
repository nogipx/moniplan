/// Перечисление операторов калькулятора
enum CalculatorOperator {
  /// Сложение (+)
  add('+'),

  /// Вычитание (-)
  subtract('-'),

  /// Умножение (×)
  multiply('×'),

  /// Деление (÷)
  divide('÷'),

  /// Равно (=)
  equals('='),

  /// Очистка (C)
  clear('C'),

  /// Сброс (AC)
  reset('R'),

  /// Пустой оператор (для сброса)
  none('');

  /// Символьное представление оператора
  final String symbol;

  const CalculatorOperator(this.symbol);

  /// Получить оператор из символа
  static CalculatorOperator fromSymbol(String symbol) {
    return CalculatorOperator.values.firstWhere(
      (op) => op.symbol == symbol,
      orElse: () => CalculatorOperator.none,
    );
  }

  /// Получить символ для отображения в выражении
  String get displaySymbol => symbol;

  /// Получить символ для использования в выражениях
  String get expressionSymbol {
    switch (this) {
      case CalculatorOperator.clear:
      case CalculatorOperator.reset:
        return '';
      case CalculatorOperator.multiply:
        return '*';
      case CalculatorOperator.divide:
        return '/';
      default:
        return symbol;
    }
  }

  @override
  String toString() => symbol;
}
