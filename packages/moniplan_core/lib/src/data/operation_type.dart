enum OperationType {
  income(1),
  outcome(-1),
  transfer(0);

  final double modifier;

  const OperationType(this.modifier);
}
