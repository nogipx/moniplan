enum PaymentType {
  unknown(-100, 0),
  income(1, 1),
  expense(-1, 2),
  correction(0, 3);

  final double modifier;
  final int id;

  const PaymentType(this.modifier, this.id);

  static PaymentType from(int? id) {
    return switch (id) {
      0 => PaymentType.unknown,
      1 => PaymentType.income,
      2 => PaymentType.expense,
      3 => PaymentType.correction,
      _ => PaymentType.unknown,
    };
  }
}
