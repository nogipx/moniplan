// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/usecases/generate_repeat_operations.dart';

import '_usecase.dart';

class ComputeBudgetUseCaseArgs {
  final Iterable<Operation> operations;
  final DateTime? startPeriod;
  final DateTime? endPeriod;

  const ComputeBudgetUseCaseArgs({
    required this.operations,
    this.startPeriod,
    this.endPeriod,
  });
}

class ComputeBudgetUseCaseResult {
  final Iterable<Operation> operationsOriginal;
  final Iterable<Operation> operationsGenerated;
  final LinkedHashMap<Operation, double> mediateBudget;

  const ComputeBudgetUseCaseResult({
    required this.mediateBudget,
    this.operationsOriginal = const [],
    this.operationsGenerated = const [],
  });
}

class ComputeBudgetUseCase extends UseCase<ComputeBudgetUseCaseResult> {
  final ComputeBudgetUseCaseArgs args;

  const ComputeBudgetUseCase({
    required this.args,
  });

  @override
  ComputeBudgetUseCaseResult run() {
    final operations = args.operations;

    final startOperationDay = operations.fold(
      operations.first.date,
      (date, next) {
        return next.date.isBefore(date) ? next.date : date;
      },
    );
    final lastOperationDay = operations.fold(
      operations.first.date,
      (date, next) {
        return next.date.isAfter(date) ? next.date : date;
      },
    );

    final allOperations = operations
        .map(
          (e) => GenerateRepeatOperations(
            operation: e,
            startPeriod: args.startPeriod ?? startOperationDay,
            endPeriod: args.endPeriod ?? lastOperationDay,
            mode: GenerateRepeatOperationsMode.beforeAndAfter,
          ).run().unlock
            ..add(e),
        )
        .expand((e) => e)
        .toList();

    allOperations.sort((a, b) => a.date.compareTo(b.date));

    final budget = LinkedHashMap<Operation, double>();

    var tempBudget = 0.0;
    for (final item in allOperations) {
      tempBudget += item.normalizedValue;
      budget[item] = tempBudget;
    }

    final result = ComputeBudgetUseCaseResult(
      operationsOriginal: operations,
      operationsGenerated: budget.keys,
      mediateBudget: budget,
    );

    return result;
  }
}
