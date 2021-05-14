// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension OperationCopyWith on Operation {
  Operation copyWith({
    DateTime? date,
    bool? enabled,
    String? reason,
    OperationType? type,
    double? value,
  }) {
    return Operation(
      date: date ?? this.date,
      enabled: enabled ?? this.enabled,
      id: id,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }
}

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

Operation _$OperationFromJson(Map<String, dynamic> json) {
  return Operation(
    value: (json['value'] as num).toDouble(),
    date: Operation.dateFromJson(json['date'] as String),
    type: _$enumDecode(_$OperationTypeEnumMap, json['type']),
    id: json['id'] as String,
    reason: json['reason'] as String,
    enabled: json['enabled'] as bool,
  );
}

Map<String, dynamic> _$OperationToJson(Operation instance) => <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'reason': instance.reason,
      'type': _$OperationTypeEnumMap[instance.type],
      'enabled': instance.enabled,
      'date': Operation.dateToJson(instance.date),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$OperationTypeEnumMap = {
  OperationType.Income: 'Income',
  OperationType.Outcome: 'Outcome',
};

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
