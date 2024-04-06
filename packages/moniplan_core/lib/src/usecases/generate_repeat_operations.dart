import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';
import '_usecase.dart';

class GenerateRepeatOperationsUseCaseResult {
  final DateTime dateStart;
  final DateTime dateEnd;
  final Operation baseOperation;
  final IList<Operation> operations;

  GenerateRepeatOperationsUseCaseResult({
    required this.baseOperation,
    required this.dateStart,
    required this.dateEnd,
    this.operations = const IListConst([]),
  });

  IList<Operation> get combined => operations;
}

class GenerateRepeatOperationsUseCase
    extends UseCase<GenerateRepeatOperationsUseCaseResult> {
  final Operation operation;
  final DateTime startPeriod;
  final DateTime endPeriod;

  const GenerateRepeatOperationsUseCase({
    required this.operation,
    required this.startPeriod,
    required this.endPeriod,
  });

  @override
  GenerateRepeatOperationsUseCaseResult run() {
    final start = startPeriod;
    final end = endPeriod;

    if (!operation.isRepeat) {
      return GenerateRepeatOperationsUseCaseResult(
        baseOperation: operation,
        dateStart: start,
        dateEnd: end,
      );
    }
    final operationDateStart = operation.dateStart;
    final operationDateEnd = operation.dateEnd;

    final targetDateStart = operationDateStart != null
        ? startPeriod.isAfter(operationDateStart)
            ? startPeriod
            : operationDateStart
        : startPeriod;

    final targetDateEnd = operationDateEnd != null
        ? endPeriod.isBefore(operationDateEnd)
            ? endPeriod
            : operationDateEnd
        : endPeriod;

    final generatedDates = GenerateRepeatDatesUseCase(
      repeat: operation.repeat,
      base: operation.date,
      dateStart: targetDateStart,
      dateEnd: targetDateEnd,
    ).run();

    final operations =
        generatedDates.map((e) => operation.copyWith(date: e)).toIList();

    final result = GenerateRepeatOperationsUseCaseResult(
      baseOperation: operation,
      dateStart: start,
      dateEnd: end,
      operations: operations,
    );

    return result;
  }
}
