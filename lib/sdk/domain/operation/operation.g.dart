// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension OperationCopyWith on Operation {
  Operation copyWith({
    double? actualValue,
    Currency? currency,
    DateTime? date,
    bool? enabled,
    double? expectedValue,
    String? reason,
  }) {
    return Operation(
      actualValue: actualValue ?? this.actualValue,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      enabled: enabled ?? this.enabled,
      expectedValue: expectedValue ?? this.expectedValue,
      id: id,
      reason: reason ?? this.reason,
    );
  }

  Operation copyWithNull({
    bool actualValue = false,
  }) {
    return Operation(
      actualValue: actualValue == true ? null : this.actualValue,
      currency: currency,
      date: date,
      enabled: enabled,
      expectedValue: expectedValue,
      id: id,
      reason: reason,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Operation _$OperationFromJson(Map<String, dynamic> json) {
  return Operation(
    expectedValue: (json['expectedValue'] as num).toDouble(),
    date: Operation.dateFromJson(json['date'] as String),
    id: json['id'] as String,
    reason: json['reason'] as String,
    currency: const CurrencyConverter().fromJson(json['currency'] as Map?),
    actualValue: (json['actualValue'] as num?)?.toDouble(),
    enabled: json['enabled'] as bool,
  );
}

Map<String, dynamic> _$OperationToJson(Operation instance) => <String, dynamic>{
      'id': instance.id,
      'expectedValue': instance.expectedValue,
      'actualValue': instance.actualValue,
      'reason': instance.reason,
      'enabled': instance.enabled,
      'currency': const CurrencyConverter().toJson(instance.currency),
      'date': Operation.dateToJson(instance.date),
    };
