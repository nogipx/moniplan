import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_payroll/moniplan_payroll.dart';
import 'package:uuid/uuid.dart';

/// Maps engine output to plain [Payment]s for import (spec 5.7).
///
/// Key rule: `details.money = net`, `details.tax = 0` — the NDFL is already
/// subtracted by the engine, so [PaymentDetails.normalizedMoney] must not cut
/// it a second time. Origin is a single tag `import:vacation:<sessionId>`.
class MapProducedPaymentsUseCase {
  const MapProducedPaymentsUseCase({
    required this.result,
    required this.sessionId,
    this.currency,
  });

  final PayrollResult result;

  /// Session uuid; becomes the origin tag for batch delete / visual marking.
  final String sessionId;

  /// Currency stamped on produced payments. Defaults to RUB.
  final CurrencyData? currency;

  static const _uuid = Uuid();

  List<Payment> call() {
    final cur = currency ?? CurrencyDataCommon.rub;
    final tag = 'import:vacation:$sessionId';

    return result.payments.map((p) {
      return Payment(
        paymentId: _uuid.v4(),
        date: p.date,
        details: PaymentDetails(
          name: _name(p),
          type: PaymentType.income,
          currency: cur,
          money: p.net,
          note: _note(p),
          tags: {tag},
        ),
      );
    }).toList(growable: false);
  }

  String _name(ProducedPayment p) {
    switch (p.kind) {
      case ProducedPaymentKind.vacationPay:
        return 'Отпускные ${_range(p.periodStart, p.periodEnd)}';
      case ProducedPaymentKind.firstHalfSalary:
      case ProducedPaymentKind.secondHalfSalary:
        return 'Зарплата ${_range(p.periodStart, p.periodEnd)} (отпуск)';
      case ProducedPaymentKind.dismissalCompensation:
        return 'Компенсация отпуска при увольнении';
      case ProducedPaymentKind.latePaymentCompensation:
        return 'Компенсация за задержку выплаты';
    }
  }

  String _note(ProducedPayment p) {
    final rate = (p.marginalRate * 100).round();
    return 'Гросс ${_money(p.gross)} ₽, НДФЛ ${_money(p.ndfl)} ₽ (ставка $rate%)';
  }

  static String _money(num v) => v.toStringAsFixed(2);

  static String _range(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return '';
    }
    if (start.month == end.month && start.year == end.year) {
      return '${start.day}–${end.day} ${_monthGen(start.month)}';
    }
    return '${start.day} ${_monthGen(start.month)} – '
        '${end.day} ${_monthGen(end.month)}';
  }

  static String _monthGen(int month) => const [
        'января',
        'февраля',
        'марта',
        'апреля',
        'мая',
        'июня',
        'июля',
        'августа',
        'сентября',
        'октября',
        'ноября',
        'декабря',
      ][month - 1];
}
