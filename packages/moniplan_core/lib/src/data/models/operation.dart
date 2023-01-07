// ignore_for_file: invalid_annotation_target

import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'operation.freezed.dart';
part 'operation.g.dart';

@freezed
class Operation with _$Operation, EquatableMixin {
  static const virtualOperationId = 'virtual_operation_id';

  const Operation._();

  @CurrencyConverter()
  @JsonSerializable()
  const factory Operation({
    required String id,
    @Default(true) bool enabled,
    String? originalOperationId,
    required OperationReceipt receipt,
    required DateTime date,
    @Default(DateTimeRepeat.noRepeat) DateTimeRepeat repeat,
  }) = _Operation;

  factory Operation.fromJson(Map<String, dynamic> json) =>
      _$OperationFromJson(json);

  ReceiptType get type => receipt.type;

  bool get isNotParent => !isParent;
  bool get isParent => id != virtualOperationId && originalOperationId == null;

  bool get isRepeat => repeat != DateTimeRepeat.noRepeat;

  bool get isRepeatParent => isRepeat && isParent;

  double get normalizedMoney => receipt.normalizedMoney;

  @override
  List<Object?> get props => [id, date, originalOperationId];

  // @override
  // String toString() => 'Operation('
  //     '\n  date: $date, money: $normalizedMoney, note: $note,'
  //     '\n  repeat: $repeat, type: $type, '
  //     '\n)';
}
