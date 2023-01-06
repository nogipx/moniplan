// ignore_for_file: invalid_annotation_target

import 'package:equatable/equatable.dart';
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
    @Default(true) bool enabled,
    String? originalOperationId,
    String? operationCategoryId,
    @Default(0) double money,
    @Default(OperationRepeat.noRepeat) OperationRepeat repeat,
    required DateTime date,
    @Default('') String note,
  }) = _Operation;

  factory Operation.fromJson(Map<String, dynamic> json) =>
      _$OperationFromJson(json);

  bool get isNotParent => !isParent;
  bool get isParent => id != virtualOperationId && originalOperationId == null;

  bool get isRepeat => repeat != OperationRepeat.noRepeat;

  bool get isRepeatParent => isRepeat && isParent;

  double get normalizedMoney => money.abs() * type.modifier;

  @override
  List<Object?> get props => [id, date, originalOperationId];

  @override
  String toString() => 'Operation('
      '\n  date: $date, money: $normalizedMoney, note: $note,'
      '\n  repeat: $repeat, type: $type, '
      '\n)';
}
