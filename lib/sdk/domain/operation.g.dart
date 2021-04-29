// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension OperationCopyWith on Operation {
  Operation copyWith({
    bool? enabled,
    String? reason,
    OperationType? type,
    double? value,
  }) {
    return Operation(
      enabled: enabled ?? this.enabled,
      id: id,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }
}

extension BudgetEventCopyWith on BudgetEvent {
  BudgetEvent copyWith({
    DateTime? dateEnd,
    DateTime? dateStart,
    List<Operation>? operations,
  }) {
    return BudgetEvent(
      dateEnd: dateEnd ?? this.dateEnd,
      dateStart: dateStart ?? this.dateStart,
      id: id,
      operations: operations ?? this.operations,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Operation _$OperationFromJson(Map<String, dynamic> json) {
  return Operation(
    value: (json['value'] as num).toDouble(),
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

BudgetEvent _$BudgetEventFromJson(Map json) {
  return BudgetEvent(
    operations: (json['operations'] as List<dynamic>)
        .map((e) => Operation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    dateStart: DateTime.parse(json['dateStart'] as String),
    dateEnd: DateTime.parse(json['dateEnd'] as String),
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$BudgetEventToJson(BudgetEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dateStart': instance.dateStart.toIso8601String(),
      'dateEnd': instance.dateEnd.toIso8601String(),
      'operations': instance.operations.map((e) => e.toJson()).toList(),
    };
