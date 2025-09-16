// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_app/core/_index.dart';

part 'payment_details.freezed.dart';
part 'payment_details.g.dart';

/// Payment details.
///
/// Financial data and description of the Payment.
@freezed
class PaymentDetails with _$PaymentDetails {
  @CurrencyConverter()
  @JsonSerializable()
  @Assert('tax >= 0.0 && tax <= 1.0')
  const factory PaymentDetails({
    required String name,
    required PaymentType type,
    required CurrencyData currency,
    @Default('') String note,
    @Default(0) num money,
    @Default({}) Set<String> tags,
    @Default(0.0) double tax,
  }) = _PaymentDetails;
  const PaymentDetails._();

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => _$PaymentDetailsFromJson(json);

  num get normalizedMoney => money.abs() * type.modifier * (1.0 - tax);

  num get normalizedMoneyWithoutTax => money.abs() * type.modifier;
}
