import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/utils/_index.dart';

/// Итоги копилки: накоплено на сегодня и прогноз к концу плана.
class SavingsSummary {
  SavingsSummary({
    required this.today,
    required this.projected,
    required this.deposits,
    required this.withdrawals,
  });

  /// Накоплено на сегодня (пополнения − снятия с датой ≤ сегодня).
  final num today;

  /// Прогноз к концу плана (все пополнения − все снятия).
  final num projected;

  /// Фактически отложено на сегодня (пополнения с датой ≤ сегодня).
  final num deposits;

  /// Фактически снято на сегодня (снятия с датой ≤ сегодня).
  final num withdrawals;
}

/// Считает копилку по savings-платежам планера. Пополнение увеличивает,
/// снятие уменьшает. Чистая функция над списком платежей.
class ComputeSavingsUseCase {
  const ComputeSavingsUseCase({required this.payments, required this.today});

  final List<Payment> payments;
  final DateTime today;

  SavingsSummary call() {
    final t = today.dayBound;
    num depTotal = 0;
    num wdrTotal = 0;
    num depToday = 0;
    num wdrToday = 0;

    for (final p in payments) {
      if (!p.isEnabled || !p.type.isSavings) {
        continue;
      }
      final amount = p.details.money.abs();
      final counted = !p.date.dayBound.isAfter(t);
      if (p.type == PaymentType.savings) {
        depTotal += amount;
        if (counted) {
          depToday += amount;
        }
      } else {
        wdrTotal += amount;
        if (counted) {
          wdrToday += amount;
        }
      }
    }

    return SavingsSummary(
      today: depToday - wdrToday,
      projected: depTotal - wdrTotal,
      deposits: depToday,
      withdrawals: wdrToday,
    );
  }
}
