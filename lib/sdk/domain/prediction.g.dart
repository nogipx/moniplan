// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension BudgetPredictionCopyWith on BudgetPrediction {
  BudgetPrediction copyWith({
    List<Operation>? operations,
    double? predictionValue,
  }) {
    return BudgetPrediction(
      id: id,
      operations: operations ?? this.operations,
      predictionValue: predictionValue ?? this.predictionValue,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetPrediction _$BudgetPredictionFromJson(Map json) {
  return BudgetPrediction(
    predictionValue: (json['predictionValue'] as num).toDouble(),
    operations: (json['operations'] as List<dynamic>)
        .map((e) => Operation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$BudgetPredictionToJson(BudgetPrediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'predictionValue': instance.predictionValue,
      'operations': instance.operations.map((e) => e.toJson()).toList(),
    };
