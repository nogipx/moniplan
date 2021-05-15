// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension OperationCopyWith on Operation {
  Operation copyWith({
    Currency? currency,
    DateTime? date,
    bool? enabled,
    String? reason,
    OperationType? type,
    double? value,
  }) {
    return Operation(
      currency: currency ?? this.currency,
      date: date ?? this.date,
      enabled: enabled ?? this.enabled,
      id: id,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      value: value ?? this.value,
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
    currency: const CurrencyConverter().fromJson(json['currency'] as Map?),
    enabled: json['enabled'] as bool,
  );
}

Map<String, dynamic> _$OperationToJson(Operation instance) => <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'reason': instance.reason,
      'type': _$OperationTypeEnumMap[instance.type],
      'enabled': instance.enabled,
      'currency': const CurrencyConverter().toJson(instance.currency),
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
