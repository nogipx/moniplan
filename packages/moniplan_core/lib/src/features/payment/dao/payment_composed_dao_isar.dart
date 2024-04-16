import 'dart:core';

import 'package:moniplan_core/moniplan_core.dart';

part 'payment_composed_dao_isar.g.dart';

@Collection()
class PaymentComposedDaoIsar {
  String id;
  Id get isarId => fastHash(id!);

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

  final planner = IsarLink<PaymentPlannerDaoIsar>();

  PaymentComposedDaoIsar({
    required this.id,
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
