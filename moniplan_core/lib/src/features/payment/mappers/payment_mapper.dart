// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_core/moniplan_core.dart';

class PaymentMapperDrift implements IMapper<Payment, PaymentsComposedDriftTableData> {
  const PaymentMapperDrift();

  static const _tagsSplitSeparator = '|';

  @override
  Payment toDomain(PaymentsComposedDriftTableData data) {
    final paymentId = data.paymentId;
    final currencyCode = data.currencyCode;
    final currencyPrecision = data.currencyPrecision;
    final date = data.date;

    if (currencyCode == null || currencyPrecision == null || date == null) {
      throw Exception('Cannot compose Payment');
    }

    final details = PaymentDetails(
      name: data.paymentName,
      note: data.paymentNote,
      type: PaymentType.from(data.paymentTypeId),
      currency: CurrencyData.create(currencyCode, currencyPrecision),
      money: data.paymentMoney,
      tax: data.paymentTax,
      tags: Set.from(data.paymentTags.split(_tagsSplitSeparator)),
    );

    return Payment(
      paymentId: paymentId,
      plannerId: data.plannerId ?? '',
      isEnabled: data.isEnabled,
      isDone: data.isDone,
      details: details,
      date: date,
      dateMoneyReserved: data.dateMoneyReserved,
      originalPaymentId: data.originalPaymentId,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
      repeat: DateTimeRepeat.from(data.dateTimeRepeatId),
    );
  }

  @override
  PaymentsComposedDriftTableData toDto(Payment data) {
    return PaymentsComposedDriftTableData(
      paymentId: data.paymentId,
      plannerId: data.plannerId,
      paymentName: data.details.name,
      paymentNote: data.details.note,
      paymentTags: data.details.tags.join(_tagsSplitSeparator),
      paymentMoney: data.details.money.toDouble(),
      paymentTax: data.details.tax,
      paymentTypeId: data.details.type.id,
      currencyCode: data.details.currency.isoCode,
      currencyPrecision: data.details.currency.decimalDigits,
      isEnabled: data.isEnabled,
      isDone: data.isDone,
      date: data.date,
      dateMoneyReserved: data.dateMoneyReserved,
      dateTimeRepeatId: data.repeat.id,
      originalPaymentId: data.originalPaymentId,
      dateStart: data.dateStart,
      dateEnd: data.dateEnd,
    );
  }
}
