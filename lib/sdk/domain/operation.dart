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

  double get result => type == OperationType.Income ? value : value * -1;

  const Operation({
    required this.value,
    required this.type,
    required this.id,
    required this.reason,
    this.enabled = true,
  }) : assert(value >= 0);

  Operation.income({
    required this.value,
    required this.reason,
    this.enabled = true,
  })  : assert(value >= 0),
        id = Uuid().v4().toString(),
        type = OperationType.Income;

  Operation.outcome({
    required this.value,
    required this.reason,
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
  void addOperation(Operation operation) {
    final index = indexWhere((e) => e.id == operation.id);
    if (index != -1) {
      this[index] = operation;
    } else {
      add(operation);
    }
  }

  void deleteOperation(Operation operation) {
    remove(operation);
  }
}

@CopyWith()
@JsonSerializable(explicitToJson: true, anyMap: true)
class BudgetEvent extends Equatable {
  @CopyWithField(immutable: true)
  final String id;

  final List<Operation> _operations;
  final DateTime dateStart;
  final DateTime dateEnd;

  List<Operation> get operations => _operations;

  const BudgetEvent({
    required List<Operation> operations,
    required this.dateStart,
    required this.dateEnd,
    required this.id,
  }) : _operations = operations;

  BudgetEvent.single({
    required List<Operation> operations,
    required DateTime date,
  })   : dateStart = date,
        dateEnd = date,
        _operations = operations,
        id = Uuid().v4().toString();

  BudgetEvent.period({
    required List<Operation> operations,
    required this.dateStart,
    required this.dateEnd,
  })   : _operations = operations,
        id = Uuid().v4();

  void editOperation(Operation operation) =>
      copyWith(operations: List.of(_operations..addOperation(operation)));

  void deleteOperation(Operation operation) =>
      copyWith(operations: _operations..deleteOperation(operation));

  factory BudgetEvent.fromJson(Map<String, dynamic> json) =>
      _$BudgetEventFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetEventToJson(this);

  bool get isSingle => dateStart.isAtSameDayAs(dateEnd);

  double get total => operations.isNotEmpty
      ? operations
          .where((e) => e.enabled)
          .map((e) => e.result)
          .fold(0, (a, b) => a + b)
      : 0;

  @override
  List<Object> get props => [
        id,
        dateStart.year,
        dateStart.month,
        dateStart.day,
        dateEnd.year,
        dateEnd.month,
        dateEnd.day,
        _operations
      ];
}

class BudgetPrediction extends BudgetEvent {
  final double predictionValue;

  BudgetPrediction(this.predictionValue, BudgetEvent event)
      : super(
          operations: event.operations,
          dateEnd: event.dateEnd,
          dateStart: event.dateStart,
          id: event.id,
        );
}

extension RecordList on List<BudgetEvent> {
  double get total =>
      map((e) => e.total).reduce((value, element) => value + element);
}
