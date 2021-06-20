import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:moniplan/_sdk/domain.dart';

part 'prediction.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true, anyMap: true)
class Prediction extends Equatable {
  @CopyWithField(immutable: true)
  final String id;
  final double budget;

  final List<Operation> operations;

  const Prediction({
    required this.budget,
    required this.operations,
    required this.id,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionToJson(this);

  @override
  List<Object> get props => [id, operations];
}

extension PredictionList on List<Prediction> {
  double get total => map((e) => e.operations.total)
      .reduce((value, element) => value + element);
}
