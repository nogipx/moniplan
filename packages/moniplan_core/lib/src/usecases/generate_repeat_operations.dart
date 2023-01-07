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
  final DateTime dateStart;
  final DateTime dateEnd;

  const GenerateRepeatOperationsUseCase({
    required this.operation,
    required this.dateStart,
    required this.dateEnd,
  });

  @override
  GenerateRepeatOperationsUseCaseResult run() {
    final start = dateStart;
    final end = dateEnd;

    if (!operation.isRepeat) {
      return GenerateRepeatOperationsUseCaseResult(
        baseOperation: operation,
        dateStart: start,
        dateEnd: end,
      );
    }

    final generatedDates = GenerateRepeatDatesUseCase(
      repeat: operation.repeat,
      base: operation.date,
      dateStart: dateStart,
      dateEnd: dateEnd,
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
