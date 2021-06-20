// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PredictionCopyWith on Prediction {
  Prediction copyWith({
    double? budget,
    List<Operation>? operations,
  }) {
    return Prediction(
      budget: budget ?? this.budget,
      id: id,
      operations: operations ?? this.operations,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prediction _$PredictionFromJson(Map json) {
  return Prediction(
    budget: (json['budget'] as num).toDouble(),
    operations: (json['operations'] as List<dynamic>)
        .map((e) => Operation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'budget': instance.budget,
      'operations': instance.operations.map((e) => e.toJson()).toList(),
    };
