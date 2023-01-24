import 'package:freezed_annotation/freezed_annotation.dart';

import '_index.dart';

part 'operation_date.g.dart';
part 'operation_date.freezed.dart';

@Freezed()
class OperationDate with _$OperationDate {
  const OperationDate._();

  const factory OperationDate({
    int? year,
    int? month,
    required int day,
    @Default(DateTimeRepeat.noRepeat) DateTimeRepeat repeat,
  }) = _OperationDate;

  factory OperationDate.fromJson(Map<String, dynamic> json) =>
      _$OperationDateFromJson(json);
}
