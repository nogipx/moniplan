// ignore_for_file: invalid_annotation_target
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_app/core/_index.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment, EquatableMixin {
  static const virtualPaymentId = 'virtual_payment_id';

  @CurrencyConverter()
  @JsonSerializable()
  const factory Payment({
    /// UUID identifier.
    required String paymentId,

    /// Info about payment.
    required PaymentDetails details,

    /// Date of payment.
    /// Indicates calendar day which payment proceed.
    required DateTime date,

    /// Related planner id.
    @Default('') String plannerId,

    /// It shows is this payment will be counted in process.
    @Default(true) bool isEnabled,

    /// It shows is this payment proceeded.
    @Default(false) bool isDone,

    /// Date of money reservation.
    /// Indicates calendar day which amount of money reserved.
    @Deprecated('Unused field') DateTime? dateMoneyReserved,

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
    @Default(DateTimeRepeat.noRepeat) @DateTimeRepeatConverter() DateTimeRepeat repeat,
  }) = _Payment;

  const Payment._();

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

  PaymentType get type => details.type;

  bool get isNotParent => originalPaymentId != null && originalPaymentId!.isNotEmpty;
  bool get isParent =>
      originalPaymentId == null || (originalPaymentId != null && originalPaymentId!.isEmpty);

  bool get isRepeat => repeat != DateTimeRepeat.noRepeat;
  bool get isRepeatParent => isRepeat && isParent;

  num get normalizedMoney => details.normalizedMoney;

  Payment copyBaseData() =>
      Payment(paymentId: '', details: details, date: date, plannerId: plannerId);

  @override
  List<Object?> get props => [
    paymentId,
    originalPaymentId,
    isEnabled,
    isDone,
    details,
    date,
    dateStart,
    dateEnd,
  ];
}
