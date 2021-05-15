import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'operation.dart';

part 'prediction.g.dart';

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

extension PredictionList on List<BudgetPrediction> {
  double get total => map((e) => e.operations.total)
      .reduce((value, element) => value + element);
}
