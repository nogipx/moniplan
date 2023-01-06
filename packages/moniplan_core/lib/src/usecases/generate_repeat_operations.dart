import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';
import '_usecase.dart';

enum GenerateRepeatOperationsMode {
  beforeOnly,
  afterOnly,
  beforeAndAfter,
}

class GenerateRepeatOperationsUseCaseResult {
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final IList<Operation> beforeOperations;
  final IList<Operation> afterOperations;
  final Operation baseOperation;

  GenerateRepeatOperationsUseCaseResult({
    required this.baseOperation,
    this.dateStart,
    this.dateEnd,
    this.beforeOperations = const IListConst([]),
    this.afterOperations = const IListConst([]),
  });

  IList<Operation> get combined => [
        ...beforeOperations,
        baseOperation,
        ...afterOperations,
      ].lock;
}

class GenerateRepeatOperationsUseCase
    extends UseCase<GenerateRepeatOperationsUseCaseResult> {
  final Operation operation;
  final DateTime startPeriod;
  final DateTime endPeriod;

  final GenerateRepeatOperationsMode mode;

  const GenerateRepeatOperationsUseCase({
    required this.operation,
    required this.startPeriod,
    required this.endPeriod,
    this.mode = GenerateRepeatOperationsMode.beforeAndAfter,
  });

  @override
  GenerateRepeatOperationsUseCaseResult run() {
    final start = startPeriod;
    final end = endPeriod;

    if (operation.repeat == OperationRepeat.noRepeat) {
      return GenerateRepeatOperationsUseCaseResult(
        baseOperation: operation,
        dateStart: start,
        dateEnd: end,
      );
    }

    final result = GenerateRepeatOperationsUseCaseResult(
      baseOperation: operation,
      dateStart: start,
      dateEnd: end,
      beforeOperations: mode != GenerateRepeatOperationsMode.afterOnly
          ? _filterOperationsInRange(_getPeriodOperationsFromDate(start))
          : const IListConst([]),
      afterOperations: mode != GenerateRepeatOperationsMode.beforeOnly
          ? _filterOperationsInRange(_getPeriodOperationsToDate(end))
          : const IListConst([]),
    );

    return result;
  }

  IList<Operation> _filterOperationsInRange(IList<Operation> data) {
    return data.where((e) {
      return e.date.compareTo(startPeriod) >= 0 &&
          e.date.compareTo(endPeriod) <= 0;
    }).toIList();
  }

  IList<Operation> _getPeriodOperationsToDate(DateTime end) {
    final repeat = operation.repeat;
    final id = operation.id;
    final date = operation.date;
    final virtualOperationId = Operation.virtualOperationId;

    if (repeat == OperationRepeat.noRepeat || id == virtualOperationId) {
      return IList();
    }

    final firstNext = repeat.next(date);
    if (firstNext.isAfter(end)) {
      return IList();
    }

    final forward = IList([
      operation.copyWith(
        id: virtualOperationId,
        date: repeat.next(date),
      )
    ]).unlock;

    while (forward.last.date.isBefore(end)) {
      forward.add(operation.copyWith(
        id: virtualOperationId,
        date: repeat.next(forward.last.date),
        originalOperationId: id,
      ));
    }

    if (forward.last.date.isAfter(end)) {
      forward.removeLast();
    }

    return forward.lock;
  }

  IList<Operation> _getPeriodOperationsFromDate(DateTime start) {
    final repeat = operation.repeat;
    final id = operation.id;
    final date = operation.date;
    final virtualOperationId = Operation.virtualOperationId;

    if (repeat == OperationRepeat.noRepeat || id == virtualOperationId) {
      return IList();
    }

    final firstPrevious = repeat.previous(date);
    if (firstPrevious.isBefore(start)) {
      return IList();
    }

    final backward = IList([
      operation.copyWith(
        id: Operation.virtualOperationId,
        date: firstPrevious,
        originalOperationId: id,
      )
    ]).unlock;

    while (backward.last.date.isAfter(start)) {
      backward.add(operation.copyWith(
        id: Operation.virtualOperationId,
        date: repeat.previous(backward.last.date),
      ));
    }

    if (backward.last.date.isBefore(start)) {
      backward.removeLast();
    }

    return backward.reversedView.lock;
  }
}
