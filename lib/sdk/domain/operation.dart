import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:dartx/dartx.dart';

part 'operation.g.dart';

enum OperationType { Income, Outcome }

@CopyWith()
@JsonSerializable(explicitToJson: true)
class Operation extends Equatable {
  @CopyWithField(immutable: true)
  final String id;

  final double value;
  final String reason;
  final OperationType type;
  final bool enabled;

  @JsonKey(fromJson: Operation.dateFromJson, toJson: Operation.dateToJson)
  final DateTime date;

  static DateTime dateFromJson(String json) => DateTime.parse(json).date;
  static String dateToJson(DateTime instance) =>
      instance.date.toIso8601String();

  double get result => type == OperationType.Income ? value : value * -1;

  const Operation({
    required this.value,
    required this.date,
    required this.type,
    required this.id,
    required this.reason,
    this.enabled = true,
  }) : assert(value >= 0);

  Operation.income({
    required this.value,
    required this.reason,
    required this.date,
    this.enabled = true,
  })  : assert(value >= 0),
        id = Uuid().v4().toString(),
        type = OperationType.Income;

  Operation.outcome({
    required this.value,
    required this.reason,
    required this.date,
    this.enabled = true,
  })  : assert(value >= 0),
        id = Uuid().v4().toString(),
        type = OperationType.Outcome;

  factory Operation.fromJson(Map<String, dynamic> json) =>
      _$OperationFromJson(json);
  Map<String, dynamic> toJson() => _$OperationToJson(this);

  @override
  List<Object?> get props => [id, type, value];
}

extension OperationList on List<Operation> {
  void replaceOperation(Operation operation) {
    final index = indexWhere((e) => e.id == operation.id);
    if (index != -1) {
      this[index] = operation;
    } else {
      add(operation);
    }
  }

  void deleteOperation(Operation operation) => remove(operation);

  double get total => isNotEmpty
      ? where((e) => e.enabled).map((e) => e.result).fold(0, (a, b) => a + b)
      : 0;
}

@CopyWith()
@JsonSerializable(explicitToJson: true, anyMap: true)
class BudgetPrediction extends Equatable {
  @CopyWithField(immutable: true)
  final String id;
  final double predictionValue;

  final List<Operation> operations;

  const BudgetPrediction({
    required this.predictionValue,
    required this.operations,
    required this.id,
  });

  factory BudgetPrediction.fromJson(Map<String, dynamic> json) =>
      _$BudgetPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetPredictionToJson(this);

  @override
  List<Object> get props => [id, operations];
}

extension RecordList on List<BudgetPrediction> {
  double get total => map((e) => e.operations.total)
      .reduce((value, element) => value + element);
}
