import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/features/payment/dao/drift/_drift_database.dart';

import '../dao/ob/payment_composed_dao_ob.dart';

class PaymentMapperOB implements IMapper<Payment, PaymentsComposedDriftTableData> {
  const PaymentMapperOB();

  @override
  Payment toDomain(PaymentsComposedDriftTableData data) {
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
      paymentId: paymentId,
      plannerId: '',
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
  PaymentsComposedDriftTableData toDto(Payment data) {
    return PaymentsComposedDriftTableData(
      id: 0,
      paymentId: data.paymentId,
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
