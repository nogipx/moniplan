import 'package:moniplan_app/core/_index.dart';

/// Вычисляет денежный поток для набора платежей.
/// Не зависит от генерации планера.
/// Может быть использован для любого списка платежей.
class MoneyFlowUseCase {
  final num initialBudget;
  final Iterable<Payment> payments;

  const MoneyFlowUseCase({this.payments = const [], this.initialBudget = 0});

  MoneyFlowUseCaseResult run() {
    num totalIncome = 0;
    num totalOutcome = 0;
    var balance = initialBudget;

    for (final e in payments) {
      if (!e.isEnabled) {
        continue;
      }
      if (e.type == PaymentType.income) {
        totalIncome += e.normalizedMoney;
      } else if (e.type == PaymentType.expense) {
        totalOutcome += e.normalizedMoney;
      }
      balance += e.normalizedMoney;
    }

    return MoneyFlowUseCaseResult(
      totalIncome: totalIncome,
      totalOutcome: totalOutcome,
      balance: balance,
      initialBalance: initialBudget,
    );
  }
}

class MoneyFlowUseCaseResult {
  final num totalIncome;
  final num totalOutcome;
  final num balance;
  final num initialBalance;
  final Map<String, dynamic>? additionalData;

  const MoneyFlowUseCaseResult({
    this.totalIncome = 0,
    this.totalOutcome = 0,
    this.balance = 0,
    this.initialBalance = 0,
    this.additionalData,
  });
}
