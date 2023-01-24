// ignore_for_file: prefer_collection_literals

import 'dart:collection';

import 'package:moniplan_core/moniplan_core.dart';

import '_usecase.dart';

class ComputeBudgetUseCaseArgs {
  final double initialBudget;
  final Iterable<Operation> operations;
  final DateTime dateStart;
  final DateTime dateEnd;

  const ComputeBudgetUseCaseArgs({
    this.initialBudget = 0,
    required this.operations,
    required this.dateStart,
    required this.dateEnd,
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

    if (operations.isEmpty) {
      throw Exception('Operations list is empty');
    }

    // if (operations.any((e) => e.receipt.name.contains('OhSofia'))) {
    //   print('');
    // }

    final dateStart = args.dateStart;
    final dateEnd = args.dateEnd;

    final allOperations = operations
        .map(
          (e) => GenerateRepeatOperationsUseCase(
            operation: e,
            dateStart: dateStart,
            dateEnd: dateEnd,
          ).run().combined,
        )
        .expand((e) => e)
        .toList();

    allOperations.sort((a, b) => a.date.compareTo(b.date));

    final budget = LinkedHashMap<Operation, double>();

    var tempBudget = args.initialBudget;
    for (final item in allOperations) {
      tempBudget += item.enabled ? item.normalizedMoney : 0;
      budget[item] = tempBudget;
    }

    final result = ComputeBudgetUseCaseResult(
      operationsOriginal: operations,
      operationsGenerated: budget.keys,
      mediateBudget: budget,
      dateStart: dateStart,
      dateEnd: dateEnd,
    );

    return result;
  }
}
