// ignore_for_file: invalid_annotation_target

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:money2/money2.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'operation_virtual.freezed.dart';
part 'operation_virtual.g.dart';

@freezed
class Operation with _$Operation, EquatableMixin {
  static const virtualOperationId = 'virtual_operation_id';

  const Operation._();

  @CurrencyConverter()
  @JsonSerializable()
  const factory Operation({
    required String id,
    required OperationType type,
    required Currency currency,
    String? originalOperationId,
    @Default(0) double money,
    @Default(OperationRepeat.noRepeat) OperationRepeat repeat,
    required DateTime date,
  }) = _Operation;

  bool get isNotOriginal => !isOriginal;
  bool get isOriginal =>
      id != virtualOperationId && originalOperationId == null;

  @override
  List<Object?> get props => [id, date, originalOperationId];

  IList<Operation> getPeriodOperationsToDate(DateTime end) {
    if (repeat == OperationRepeat.noRepeat || id == virtualOperationId) {
      return IList();
    }

    final firstNext = repeat.next(date);
    if (firstNext.isAfter(end)) {
      return IList();
    }

    final forward = IList([
      copyWith(
        id: virtualOperationId,
        date: repeat.next(date),
      )
    ]).unlock;

    while (forward.last.date.isBefore(end)) {
      forward.add(copyWith(
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

  IList<Operation> getPeriodOperationsFromDate(DateTime start) {
    if (repeat == OperationRepeat.noRepeat || id == virtualOperationId) {
      return IList();
    }

    final firstPrevious = repeat.previous(date);
    if (firstPrevious.isBefore(start)) {
      return IList();
    }

    final backward = IList([
      copyWith(
        id: virtualOperationId,
        date: firstPrevious,
        originalOperationId: id,
      )
    ]).unlock;

    while (backward.last.date.isAfter(start)) {
      backward.add(copyWith(
        id: virtualOperationId,
        date: repeat.previous(backward.last.date),
      ));
    }

    if (backward.last.date.isBefore(start)) {
      backward.removeLast();
    }

    return backward.reversedView.lock;
  }

  IList<Operation> getPeriodOperations(DateTime start, DateTime end) {
    if (repeat == OperationRepeat.noRepeat) {
      return IList();
    } else {
      final backward = getPeriodOperationsFromDate(start);
      final forward = getPeriodOperationsToDate(end);

      return IList([
        ...backward,
        ...forward,
      ]);
    }
  }

  @override
  String toString() => 'Operation('
      '\n  id: $id, type: $type, '
      '\n  money: $money, date: $date, repeat: $repeat'
      '\n)';
}
