enum PaymentType {
  unknown(-100, 0),
  income(1, 1),
  expense(-1, 2),
  correction(0, 3),

  /// Пополнение накоплений: уходит из тратимого баланса в копилку.
  savings(-1, 4),

  /// Снятие из накоплений: возвращается в тратимый баланс.
  savingsWithdraw(1, 5);

  final double modifier;
  final int id;

  const PaymentType(this.modifier, this.id);

  /// Относится к накоплениям (пополнение или снятие).
  bool get isSavings =>
      this == PaymentType.savings || this == PaymentType.savingsWithdraw;

  static PaymentType from(int? id) {
    return switch (id) {
      0 => PaymentType.unknown,
      1 => PaymentType.income,
      2 => PaymentType.expense,
      3 => PaymentType.correction,
      4 => PaymentType.savings,
      5 => PaymentType.savingsWithdraw,
      _ => PaymentType.unknown,
    };
  }
}
