// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/usecases/generate_repeat_operations.dart';

import '_usecase.dart';

class ComputeBudgetUseCaseArgs {
  final Iterable<Operation> operations;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  const ComputeBudgetUseCaseArgs({
    required this.operations,
    this.dateStart,
    this.dateEnd,
  });
}

class ComputeBudgetUseCaseResult {
  final Iterable<Operation> operationsOriginal;
  final Iterable<Operation> operationsGenerated;
  final LinkedHashMap<Operation, double> mediateBudget;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  const ComputeBudgetUseCaseResult({
    required this.mediateBudget,
    this.operationsOriginal = const [],
    this.operationsGenerated = const [],
    this.dateStart,
    this.dateEnd,
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

    final dateStart = args.dateStart ?? startOperationDay;
    final dateEnd = args.dateEnd ?? lastOperationDay;

    final allOperations = operations
        .map(
          (e) => GenerateRepeatOperationsUseCase(
            operation: e,
            startPeriod: dateStart,
            endPeriod: dateEnd,
          ).run().combined,
        )
        .expand((e) => e)
        .toList();

    allOperations.sort((a, b) => a.date.compareTo(b.date));

    final budget = LinkedHashMap<Operation, double>();

    var tempBudget = 0.0;
    for (final item in allOperations) {
      tempBudget += item.enabled ? item.normalizedValue : 0;
      budget[item] = tempBudget;
    }

    budget.removeWhere(
      (key, value) => key.date.isAfter(dateEnd) || key.date.isBefore(dateStart),
    );

    final result = ComputeBudgetUseCaseResult(
      operationsOriginal: operations,
      operationsGenerated: budget.keys,
      mediateBudget: budget,
      dateStart: args.dateStart ?? startOperationDay,
      dateEnd: args.dateEnd ?? lastOperationDay,
    );

    return result;
  }
}
