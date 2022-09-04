import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:moniplan_core/moniplan_core.dart';
import '_usecase.dart';

enum GenerateRepeatOperationsMode {
  beforeOnly,
  afterOnly,
  beforeAndAfter,
}

class GenerateRepeatOperations extends UseCase<IList<Operation>> {
  final Operation operation;
  final DateTime? startPeriod;
  final DateTime? endPeriod;

  final GenerateRepeatOperationsMode mode;

  const GenerateRepeatOperations({
    required this.operation,
    this.startPeriod,
    this.endPeriod,
    this.mode = GenerateRepeatOperationsMode.beforeAndAfter,
  });

  @override
  IList<Operation> run() {
    final start = startPeriod;
    final end = endPeriod;

    final result = IList<Operation>().unlock;

    if (operation.repeat == OperationRepeat.noRepeat) {
      return result.lock;
    }

    if (start != null && mode != GenerateRepeatOperationsMode.afterOnly) {
      result.addAll(_getPeriodOperationsFromDate(start));
    }
    if (end != null && mode != GenerateRepeatOperationsMode.beforeOnly) {
      result.addAll(_getPeriodOperationsToDate(end));
    }

    return result.lock;
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
