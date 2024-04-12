import 'package:moniplan_core/moniplan_core.dart';

class MoneyFlowUseCaseArgs {
  final num initialBudget;
  final Iterable<Payment> payments;

  const MoneyFlowUseCaseArgs({
    this.payments = const [],
    this.initialBudget = 0,
  });
}

class MoneyFlowUseCaseResult {
  final num totalIncome;
  final num totalOutcome;
  final num balance;
  final num initialBalance;

  const MoneyFlowUseCaseResult({
    this.totalIncome = 0,
    this.totalOutcome = 0,
    this.balance = 0,
    this.initialBalance = 0,
  });
}

class MoneyFlowUseCase extends UseCase<MoneyFlowUseCaseResult> {
  final MoneyFlowUseCaseArgs args;

  const MoneyFlowUseCase({
    required this.args,
  });

  @override
  MoneyFlowUseCaseResult run() {
    num totalIncome = 0;
    num totalOutcome = 0;
    num balance = args.initialBudget;

    for (var e in args.payments) {
      if (!e.enabled) {
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
      initialBalance: args.initialBudget,
    );
  }
}
