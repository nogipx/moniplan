import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:moniplan/sdk/domain/currency/currency.dart';
import 'package:moniplan/sdk/hive_types.dart';
import 'package:uuid/uuid.dart';
import 'package:dartx/dartx.dart';
export 'operation_collection.dart';

part 'operation.g.dart';

enum OperationType { Income, Outcome }

@CopyWith(generateCopyWithNull: true)
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypes.Operation, adapterName: 'OperationAdapter')
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
  String get currencyString => result.currency(currency);

  @JsonKey(fromJson: Operation.dateFromJson, toJson: Operation.dateToJson)
  @HiveField(6)
  final DateTime date;

  static DateTime dateFromJson(String json) => DateTime.parse(json).date;
  static String dateToJson(DateTime instance) =>
      instance.date.toIso8601String();

  double get result => enabled ? actualValue ?? expectedValue : 0;

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
  }) : id = Uuid().v4().toString();

  factory Operation.fromJson(Map<String, dynamic> json) =>
      _$OperationFromJson(json);
  Map<String, dynamic> toJson() => _$OperationToJson(this);

  static Operation get stub => Operation.create(
        expectedValue: 0,
        date: DateTime.now().date,
        reason: '',
        currency: CommonCurrencies().rub,
      );

  @override
  List<Object?> get props => [id, expectedValue, date, currency, reason];
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
