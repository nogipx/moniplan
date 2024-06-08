// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

part 'payment_details.g.dart';
part 'payment_details.freezed.dart';

/// Payment details.
///
/// Financial data and description of the Payment.
@freezed
class PaymentDetails with _$PaymentDetails {
  const PaymentDetails._();

  @CurrencyConverter()
  @JsonSerializable()
  @Assert('tax >= 0.0 && tax <= 1.0')
  const factory PaymentDetails({
    required String name,
    @Default('') String note,
    required PaymentType type,
    required Currency currency,
    @Default(0) num money,
    @Default({}) Set<String> tags,
    @Default(0.0) double tax,
  }) = _PaymentDetails;

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => _$PaymentDetailsFromJson(json);

  num get normalizedMoney => money.abs() * type.modifier * (1.0 - tax);
}
