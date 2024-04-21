import 'package:moniplan_core/moniplan_core.dart';

import '../dao/payment_composed_dao_ob.dart';

class PaymentMapperOB implements IMapper<Payment, PaymentComposedDaoOB> {
  const PaymentMapperOB();

  @override
  Payment toDomain(PaymentComposedDaoOB data) {
    final paymentId = data.paymentId;
    final currencyCode = data.currencyCode;
    final currencyPrecision = data.currencyPrecision;
    final date = data.date;

    if (paymentId == null || currencyCode == null || currencyPrecision == null || date == null) {
      throw Exception('Cannot compose Payment');
    }

    final details = PaymentDetails(
      name: data.paymentName ?? '',
      note: data.paymentNote ?? '',
      type: PaymentType.from(data.paymentTypeId),
      currency: Currency.create(currencyCode, currencyPrecision),
      money: data.paymentMoney ?? 0.0,
    );

    return Payment(
      id: paymentId,
      intId: data.id,
      isEnabled: data.isEnabled ?? true,
      isDone: data.isDone ?? false,
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
  PaymentComposedDaoOB toDto(Payment data) {
    return PaymentComposedDaoOB(
      id: data.intId,
      paymentId: data.id,
      paymentName: data.details.name,
      paymentNote: data.details.note,
      paymentMoney: data.details.money.toDouble(),
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
