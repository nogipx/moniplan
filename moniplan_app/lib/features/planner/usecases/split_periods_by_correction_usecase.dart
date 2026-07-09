import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/usecases/build_balance_series_usecase.dart';
import 'package:moniplan_app/utils/_index.dart';

/// Один период планера между коррекциями (коррекция — раздел периодов).
class PlannerPeriod {
  PlannerPeriod({
    required this.start,
    required this.end,
    required this.startBalance,
    required this.endBalance,
    required this.lowestBalance,
    required this.lowestBalanceDate,
    required this.hasShortfall,
    required this.startedByCorrection,
  });

  final DateTime start;
  final DateTime end;

  /// Баланс в начале периода (значение коррекции либо стартовый бюджет).
  final num startBalance;
  final num endBalance;
  final num lowestBalance;
  final DateTime lowestBalanceDate;
  final bool hasShortfall;

  /// Период открыт коррекцией (а не началом планера).
  final bool startedByCorrection;

  /// Итоговое изменение баланса за период.
  num get netChange => endBalance - startBalance;
}

/// Делит материализованную кривую баланса на периоды по коррекциям.
/// Коррекция начинает новый период (в этот день баланс приравнивается к её
/// значению — см. [BuildBalanceSeriesUseCase]).
class SplitPeriodsByCorrectionUseCase {
  const SplitPeriodsByCorrectionUseCase({
    required this.series,
    required this.payments,
  });

  final List<BalancePoint> series;
  final List<Payment> payments;

  List<PlannerPeriod> call() {
    if (series.isEmpty) {
      return const [];
    }

    final seriesStart = series.first.date.dayBound;
    final seriesEnd = series.last.date.dayBound;

    final correctionDates = payments
        .where((p) => p.isEnabled && p.type == PaymentType.correction)
        .map((p) => p.date.dayBound)
        .where((d) => !d.isBefore(seriesStart) && !d.isAfter(seriesEnd))
        .toSet()
        .toList()
      ..sort();

    // Каждый период начинается со старта планера либо с даты коррекции.
    final starts = <DateTime>[seriesStart];
    for (final d in correctionDates) {
      if (!starts.last.isSameDay(d)) {
        starts.add(d);
      }
    }

    final periods = <PlannerPeriod>[];
    for (var i = 0; i < starts.length; i++) {
      final from = starts[i];
      final toExclusive = i + 1 < starts.length
          ? starts[i + 1]
          : seriesEnd.add(const Duration(days: 1));

      final slice = series
          .where((p) =>
              !p.date.dayBound.isBefore(from) &&
              p.date.dayBound.isBefore(toExclusive))
          .toList();
      if (slice.isEmpty) {
        continue;
      }

      var low = slice.first;
      var hasShortfall = false;
      for (final p in slice) {
        if (p.balance < low.balance) {
          low = p;
        }
        if (p.balance < 0) {
          hasShortfall = true;
        }
      }

      periods.add(PlannerPeriod(
        start: from,
        end: slice.last.date,
        startBalance: slice.first.balance,
        endBalance: slice.last.balance,
        lowestBalance: low.balance,
        lowestBalanceDate: low.date,
        hasShortfall: hasShortfall,
        startedByCorrection: i > 0,
      ));
    }
    return periods;
  }
}
