enum PaymentType {
  income(1),
  expense(-1),
  transfer(0);

  final double modifier;

  const PaymentType(this.modifier);
}
