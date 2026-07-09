import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/usecases/build_balance_series_usecase.dart';
import 'package:moniplan_app/utils/_index.dart';

/// Период без поступлений и его влияние на баланс.
class IncomeGap {
  IncomeGap({
    required this.start,
    required this.end,
    required this.days,
    required this.spend,
    required this.lowestBalance,
  });

  /// Дата предыдущего поступления (или начало периода планера).
  final DateTime start;

  /// Дата следующего поступления (или конец периода планера).
  final DateTime end;
  final int days;

  /// Суммарный расход за период (по модулю).
  final num spend;

  /// Минимальный баланс внутри периода.
  final num lowestBalance;
}

/// Прогноз рисков материализованного планера от текущего дня до конца периода.
class PlannerRisk {
  PlannerRisk({
    required this.analyzedFrom,
    required this.lowestBalance,
    required this.lowestBalanceDate,
    required this.hasShortfall,
    required this.avgDailyExpense,
    this.shortfallDate,
    this.bufferDays,
    this.longestGap,
    this.nextGap,
  });

  final DateTime analyzedFrom;

  /// Самый низкий баланс на отрезке [analyzedFrom, конец периода].
  final num lowestBalance;
  final DateTime lowestBalanceDate;

  /// Баланс уходит ниже нуля (кассовый разрыв).
  final bool hasShortfall;
  final DateTime? shortfallDate;

  final num avgDailyExpense;

  /// На сколько дней среднего расхода хватит дна баланса (если оно > 0).
  final double? bufferDays;

  /// Самый длинный период без дохода впереди.
  final IncomeGap? longestGap;

  /// Ближайший (текущий) период без дохода.
  final IncomeGap? nextGap;
}

/// Анализ рисков над готовой кривой баланса. Ничего не пересчитывает в
/// планере — работает только с материализованными данными.
class AnalyzePlannerRiskUseCase {
  const AnalyzePlannerRiskUseCase({
    required this.series,
    required this.payments,
    required this.today,
  });

  final List<BalancePoint> series;
  final List<Payment> payments;
  final DateTime today;

  PlannerRisk? call() {
    if (series.isEmpty) {
      return null;
    }

    final from = _clampFrom();
    final forward =
        series.where((p) => !p.date.dayBound.isBefore(from)).toList();
    if (forward.isEmpty) {
      return null;
    }

    var trough = forward.first;
    DateTime? shortfallDate;
    num totalExpense = 0;
    for (final p in forward) {
      if (p.balance < trough.balance) {
        trough = p;
      }
      if (shortfallDate == null && p.balance < 0) {
        shortfallDate = p.date;
      }
      totalExpense += p.outcome.abs();
    }

    final avgDailyExpense = totalExpense / forward.length;
    double? bufferDays;
    if (trough.balance > 0 && avgDailyExpense > 0) {
      bufferDays = trough.balance / avgDailyExpense;
    }

    final forwardGaps = _incomeGaps()
        .where((g) => g.end.isAfter(today.dayBound))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    IncomeGap? longestGap;
    for (final g in forwardGaps) {
      if (longestGap == null || g.days > longestGap.days) {
        longestGap = g;
      }
    }
    final nextGap = forwardGaps.isNotEmpty ? forwardGaps.first : null;

    return PlannerRisk(
      analyzedFrom: from,
      lowestBalance: trough.balance,
      lowestBalanceDate: trough.date,
      hasShortfall: shortfallDate != null,
      shortfallDate: shortfallDate,
      avgDailyExpense: avgDailyExpense,
      bufferDays: bufferDays,
      longestGap: longestGap,
      nextGap: nextGap,
    );
  }

  DateTime _clampFrom() {
    final t = today.dayBound;
    final first = series.first.date.dayBound;
    final last = series.last.date.dayBound;
    if (t.isBefore(first) || t.isAfter(last)) {
      // Весь период либо ещё не начался, либо уже прошёл — анализируем целиком.
      return first;
    }
    return t;
  }

  List<IncomeGap> _incomeGaps() {
    final start = series.first.date.dayBound;
    final end = series.last.date.dayBound;

    // Поступления и коррекции одинаково закрывают период без денег:
    // коррекция — раздел периодов.
    final moneyDates = payments
        .where((p) =>
            p.isEnabled &&
            (p.type == PaymentType.income || p.type == PaymentType.correction))
        .map((p) => p.date.dayBound)
        .where((d) => !d.isBefore(start) && !d.isAfter(end))
        .toSet()
        .toList()
      ..sort();

    // Границы периодов без денег: старт планера, поступление/коррекция, конец.
    final boundaries = <DateTime>[];
    for (final d in [start, ...moneyDates, end]) {
      if (boundaries.isEmpty || !boundaries.last.isSameDay(d)) {
        boundaries.add(d);
      }
    }

    final balanceByDay = {for (final p in series) p.date.dayBound: p.balance};

    final gaps = <IncomeGap>[];
    for (var i = 0; i < boundaries.length - 1; i++) {
      final a = boundaries[i];
      final b = boundaries[i + 1];
      final days = b.difference(a).inDays;
      if (days <= 0) {
        continue;
      }

      num spend = 0;
      for (final p in payments) {
        if (!p.isEnabled || p.type != PaymentType.expense) {
          continue;
        }
        final d = p.date.dayBound;
        if (!d.isBefore(a) && d.isBefore(b)) {
          spend += p.normalizedMoney.abs();
        }
      }

      num? low;
      var cursor = a;
      while (!cursor.isAfter(b)) {
        final bal = balanceByDay[cursor];
        if (bal != null && (low == null || bal < low)) {
          low = bal;
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      gaps.add(IncomeGap(
        start: a,
        end: b,
        days: days,
        spend: spend,
        lowestBalance: low ?? 0,
      ));
    }
    return gaps;
  }
}
