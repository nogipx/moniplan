import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/usecases/_usecase.dart';

class MoneyFlowUseCaseArgs {
  final double initialBudget;
  final Iterable<Operation> operations;

  const MoneyFlowUseCaseArgs({
    this.operations = const [],
    this.initialBudget = 0,
  });
}

class MoneyFlowUseCaseResult {
  final double totalIncome;
  final double totalOutcome;
  final double balance;

  const MoneyFlowUseCaseResult({
    this.totalIncome = 0,
    this.totalOutcome = 0,
    this.balance = 0,
  });
}

class MoneyFlowUseCase extends UseCase<MoneyFlowUseCaseResult> {
  final MoneyFlowUseCaseArgs args;

  const MoneyFlowUseCase({
    required this.args,
  });

  @override
  MoneyFlowUseCaseResult run() {
    double totalIncome = 0;
    double totalOutcome = 0;
    double balance = args.initialBudget;

    for (var e in args.operations) {
      if (!e.enabled) {
        continue;
      }
      if (e.type == ReceiptType.income) {
        totalIncome += e.normalizedMoney;
      } else if (e.type == ReceiptType.outcome) {
        totalOutcome += e.normalizedMoney;
      }
      balance += e.normalizedMoney;
    }

    return MoneyFlowUseCaseResult(
      totalIncome: totalIncome,
      totalOutcome: totalOutcome,
      balance: balance,
    );
  }
}
