import 'dart:math' as math;

import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/goals/models/savings_goal.dart';
import 'package:moniplan_app/features/planner/usecases/build_balance_series_usecase.dart';
import 'package:moniplan_app/utils/_index.dart';

/// Дневной лимит трат до следующей зарплаты (spec: подсистема «Цели»).
class DailyAllowance {
  DailyAllowance({
    required this.hasNextSalary,
    required this.nextSalaryDate,
    required this.daysUntilSalary,
    required this.todayBalance,
    required this.scheduledOutflows,
    required this.target,
    required this.bindingBalance,
    required this.bindingDate,
    required this.bindingBeyondSalary,
    required this.free,
    required this.perDay,
  });

  /// Есть ли поступление впереди (иначе окно — до конца периода).
  final bool hasNextSalary;
  final DateTime? nextSalaryDate;

  /// Число дней от сегодня до зарплаты (не меньше 1).
  final int daysUntilSalary;

  /// Баланс сегодня.
  final num todayBalance;

  /// Списания от сегодня до самой тугой точки прогноза, по модулю.
  final num scheduledOutflows;

  /// Сколько хочется оставить к зарплате.
  final num target;

  /// Минимум прогноза от сегодня до конца плана — связывающая точка.
  /// Трата сейчас опускает всю будущую кривую, поэтому провал после
  /// ближайшей зарплаты тоже ограничивает лимит.
  final num bindingBalance;
  final DateTime bindingDate;

  /// Связывающий минимум находится после ближайшей зарплаты.
  final bool bindingBeyondSalary;

  /// Свободно на гибкие траты = bindingBalance − target.
  final num free;

  /// Можно тратить в день = free / daysUntilSalary.
  final num perDay;

  bool get overspent => free < 0;
}

/// Считает дневной лимит по последнему периоду и цели «оставить X к зарплате».
/// Чистая функция над готовой кривой баланса; ничего не пересчитывает в планере.
class ComputeDailyAllowanceUseCase {
  const ComputeDailyAllowanceUseCase({
    required this.series,
    required this.payments,
    required this.today,
    required this.goal,
  });

  /// Кривая баланса последнего периода.
  final List<BalancePoint> series;
  final List<Payment> payments;
  final DateTime today;
  final SavingsGoal goal;

  DailyAllowance? call() {
    if (series.isEmpty) {
      return null;
    }
    final start = series.first.date.dayBound;
    final end = series.last.date.dayBound;
    final t = today.dayBound.isBefore(start)
        ? start
        : (today.dayBound.isAfter(end) ? end : today.dayBound);

    final balanceByDay = {for (final p in series) p.date.dayBound: p.balance};
    final todayBalance = balanceByDay[t] ?? series.last.balance;

    final salaryDates = payments
        .where((p) => p.isEnabled && p.type == PaymentType.income)
        .map((p) => p.date.dayBound)
        .where((d) => d.isAfter(t) && !d.isAfter(end))
        .toList()
      ..sort();
    final hasNext = salaryDates.isNotEmpty;
    final nextSalary =
        hasNext ? salaryDates.first : end.add(const Duration(days: 1));
    final days = math.max(1, nextSalary.difference(t).inDays);

    // Связывающая точка — минимум прогноза от сегодня до КОНЦА плана, а не
    // только до ближайшей зарплаты: трата сейчас опускает всю будущую кривую,
    // поэтому провал после зарплаты тоже ограничивает лимит.
    var bindingBalance = todayBalance;
    var bindingDate = t;
    for (final p in series) {
      final d = p.date.dayBound;
      if (!d.isBefore(t) && p.balance < bindingBalance) {
        bindingBalance = p.balance;
        bindingDate = d;
      }
    }

    final target = _resolveTarget();
    final free = bindingBalance - target;

    return DailyAllowance(
      hasNextSalary: hasNext,
      nextSalaryDate: hasNext ? nextSalary : null,
      daysUntilSalary: days,
      todayBalance: todayBalance,
      scheduledOutflows: todayBalance - bindingBalance,
      target: target,
      bindingBalance: bindingBalance,
      bindingDate: bindingDate,
      bindingBeyondSalary: hasNext && bindingDate.isAfter(nextSalary),
      free: free,
      perDay: free / days,
    );
  }

  num _resolveTarget() {
    if (goal.basis != GoalBasis.days) {
      return goal.amount;
    }
    final totalExpense = series.fold<num>(0, (sum, p) => sum + p.outcome.abs());
    final avgDaily = series.isEmpty ? 0 : totalExpense / series.length;
    return goal.days * avgDaily;
  }
}
