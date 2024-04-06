// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:money2/money2.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'operation_receipt.g.dart';
part 'operation_receipt.freezed.dart';

/// Operation receipt
///
/// Financial data and description of the Operation.
@Freezed()
class OperationReceipt with _$OperationReceipt {
  const OperationReceipt._();

  @CurrencyConverter()
  @JsonSerializable()
  const factory OperationReceipt({
    required String name,
    @Default('') String note,
    required ReceiptType type,
    required Currency currency,
    @Default(0) double money,
  }) = _OperationReceipt;

  factory OperationReceipt.fromJson(Map<String, dynamic> json) =>
      _$OperationReceiptFromJson(json);

  double get normalizedMoney => money.abs() * type.modifier;
}

enum ReceiptType {
  income(1),
  outcome(-1),
  transfer(0);

  final double modifier;

  const ReceiptType(this.modifier);
}
