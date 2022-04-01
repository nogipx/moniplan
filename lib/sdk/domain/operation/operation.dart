import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:moniplan/sdk/domain/currency/currency.dart';
import 'package:moniplan/sdk/hive_types.dart';
import 'package:uuid/uuid.dart';

export 'operation_collection.dart';

part 'operation.g.dart';

enum OperationType { income, outcome }

@CopyWith(generateCopyWithNull: true)
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypes.operation, adapterName: 'OperationAdapter')
class Operation extends Equatable {
  //
  @CopyWithField(immutable: true)
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double expectedValue;

  @HiveField(2)
  final double? actualValue;

  @HiveField(3)
  final String reason;

  @HiveField(4)
  final bool enabled;

  @JsonKey(includeIfNull: true)
  @CurrencyConverter()
  @HiveField(5)
  final Currency currency;

  @JsonKey(fromJson: Operation.dateFromJson, toJson: Operation.dateToJson)
  @HiveField(6)
  final DateTime date;

  String get currencyString => result.currency(currency);

  double get result => enabled ? actualValue ?? expectedValue : 0;

  @override
  List<Object?> get props => [id, expectedValue, date, currency, reason];

  const Operation({
    required this.expectedValue,
    required this.date,
    required this.id,
    required this.reason,
    required this.currency,
    this.actualValue,
    this.enabled = true,
  });

  Operation.create({
    required this.expectedValue,
    required this.reason,
    required this.date,
    required this.currency,
    this.actualValue,
    this.enabled = true,
  }) : id = const Uuid().v4().toString();

  factory Operation.stub() {
    return Operation.create(
      expectedValue: 0,
      date: DateTime.now().date,
      reason: '',
      currency: CommonCurrencies().rub,
    );
  }

  factory Operation.fromJson(Map<String, dynamic> json) =>
      _$OperationFromJson(json);

  static DateTime dateFromJson(String json) => DateTime.parse(json).date;
  static String dateToJson(DateTime instance) =>
      instance.date.toIso8601String();

  Map<String, dynamic> toJson() => _$OperationToJson(this);
}

extension OperationList on List<Operation> {
  void replaceOperation(Operation operation) {
    final index = indexWhere((e) => e.id == operation.id);
    if (index != -1) {
      this[index] = operation;
    } else {
      add(operation);
    }
  }

  void deleteOperation(Operation operation) => remove(operation);

  double get total => isNotEmpty
      ? where((e) => e.enabled).map((e) => e.result).fold(0, (a, b) => a + b)
      : 0;
}

class RepeatConfig {}
