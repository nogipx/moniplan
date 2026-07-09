/// Typed input error (spec 6). Not a bare string.
class PayrollInputError implements Exception {
  const PayrollInputError(this.code, this.message);

  /// Stable machine-readable code, e.g. `vacationEndBeforeStart`.
  final String code;

  /// Human-readable explanation.
  final String message;

  @override
  String toString() => 'PayrollInputError($code): $message';
}
