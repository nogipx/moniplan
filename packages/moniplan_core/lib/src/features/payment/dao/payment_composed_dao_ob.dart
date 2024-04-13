import 'dart:core';

import 'package:moniplan_core/moniplan_core.dart';

@Entity()
class PaymentComposedDaoOB {
  @Id()
  int id;

  @Unique()
  @Index()
  String? paymentId;

  String? paymentName;
  String? paymentNote;
  double? paymentMoney;

  int? paymentTypeId;
  String? currencyCode;
  int? currencyPrecision;

  bool? isEnabled;
  bool? isDone;

  DateTime? date;
  DateTime? dateMoneyReserved;

  int? dateTimeRepeatId;
  String? originalPaymentId;
  DateTime? dateStart;
  DateTime? dateEnd;

  final planner = ToOne<PaymentPlannerDaoOB>();

  PaymentComposedDaoOB({
    this.id = 0,
    this.paymentId,
    this.paymentName,
    this.paymentNote,
    this.paymentMoney,
    this.paymentTypeId = 0,
    this.currencyCode,
    this.currencyPrecision,
    this.isEnabled = true,
    this.isDone = false,
    this.date,
    this.dateMoneyReserved,
    this.dateTimeRepeatId = 0,
    this.originalPaymentId,
    this.dateStart,
    this.dateEnd,
  });
}
