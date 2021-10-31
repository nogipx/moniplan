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
// TypeAdapterGenerator
// **************************************************************************

class OperationAdapter extends TypeAdapter<Operation> {
  @override
  final int typeId = 0;

  @override
  Operation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Operation(
      expectedValue: fields[1] as double,
      date: fields[6] as DateTime,
      id: fields[0] as String,
      reason: fields[3] as String,
      currency: fields[5] as Currency,
      actualValue: fields[2] as double?,
      enabled: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Operation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expectedValue)
      ..writeByte(2)
      ..write(obj.actualValue)
      ..writeByte(3)
      ..write(obj.reason)
      ..writeByte(4)
      ..write(obj.enabled)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
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
