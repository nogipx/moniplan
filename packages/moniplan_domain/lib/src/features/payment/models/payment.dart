// ignore_for_file: invalid_annotation_target
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

part 'payment.g.dart';
part 'payment.freezed.dart';

@freezed
class Payment with _$Payment, EquatableMixin {
  static const virtualPaymentId = 'virtual_payment_id';

  const Payment._();

  @CurrencyConverter()
  @JsonSerializable()
  const factory Payment({
    /// UUID identifier.
    required String id,

    /// It shows is this payment will be counted in process.
    @Default(true) bool enabled,

    /// Info about payment.
    required PaymentDetails details,

    /// Date of payment.
    /// Indicates calendar day which payment proceed.
    required DateTime date,

    /// Date of money reservation.
    /// Indicates calendar day which amount of money reserved.
    DateTime? dateMoneyReserved,

    /// Field for repeated payments.
    /// It shows which payment this payment was generated from.
    String? originalPaymentId,

    /// Field for repeated payments.
    /// It shows where need to stop generate repeated payments.
    DateTime? dateStart,

    /// Field for repeated payments.
    /// It shows where need to stop generate repeated payments.
    DateTime? dateEnd,

    /// Field for repeated payments.
    /// It shows which period payment will be repeated.
    /// No repeat, by default.
    @Default(DateTimeRepeat.noRepeat) DateTimeRepeat repeat,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

  PaymentType get type => details.type;

  bool get isNotParent => !isParent;
  bool get isParent => id != virtualPaymentId && originalPaymentId == null;
  bool get isRepeat => repeat != DateTimeRepeat.noRepeat;
  bool get isRepeatParent => isRepeat && isParent;

  num get normalizedMoney => details.normalizedMoney;

  @override
  List<Object?> get props => [
        id,
        date,
        dateMoneyReserved,
        originalPaymentId,
      ];
}
