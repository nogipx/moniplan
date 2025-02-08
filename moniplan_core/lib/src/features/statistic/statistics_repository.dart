import 'package:moniplan_domain/moniplan_domain.dart';

class StatisticsRepoImpl implements IStatisticsRepo {
  final IPlannerRepo plannerRepo;

  const StatisticsRepoImpl({required this.plannerRepo});

  @override
  Future<BudgetStatistics> getStatistics({required String plannerId}) async {
    // Получаем планнер по ID
    final planner = await plannerRepo.getPlannerById(plannerId, withActualInfo: true);

    if (planner == null) {
      return BudgetStatistics(totalBudget: {}, incomes: {}, expenses: {});
    }

    return _computeStatisticsFromPlanner(planner);
  }

  @override
  Future<BudgetStatistics> getStatisticsForPeriod({
    required String plannerId,
    required DateTime start,
    required DateTime end,
  }) async {
    // Получаем планнер по ID
    final planner = await plannerRepo.getPlannerById(plannerId, withActualInfo: true);

    if (planner == null) {
      return BudgetStatistics(totalBudget: {}, incomes: {}, expenses: {});
    }

    return _computeStatisticsFromPlanner(planner, start: start, end: end);
  }

  Future<BudgetStatistics> _computeStatisticsFromPlanner(Planner planner, {DateTime? start, DateTime? end}) async {
    final payments = planner.payments;

    // Фильтруем платежи по периоду, если он задан

    final filteredPayments = payments.where((payment) {
      final date = payment.date;
      if (start != null && end != null) {
        return date.isAfter(start) && date.isBefore(end);
      }
      return true;
    }).toList();

    // Группируем платежи по дню
    final groupedIncomes = <DateTime, double>{};
    final groupedExpenses = <DateTime, double>{};

    for (var payment in filteredPayments) {
      final date = DateTime(payment.date.year, payment.date.month, payment.date.day);
      final amount = payment.details.money.toDouble();

      if (amount > 0) {
        groupedIncomes.update(
          date,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      } else {
        groupedExpenses.update(
          date,
          (value) => value + amount.abs(),
          ifAbsent: () => amount.abs(),
        );
      }
    }

    // Вычисляем общий бюджет
    final totalBudget = <DateTime, double>{};
    for (var date in {...groupedIncomes.keys, ...groupedExpenses.keys}) {
      final income = groupedIncomes[date] ?? 0;
      final expense = groupedExpenses[date] ?? 0;
      totalBudget[date] = income - expense;
    }

    return BudgetStatistics(
      totalBudget: totalBudget,
      incomes: groupedIncomes,
      expenses: groupedExpenses,
    );
  }
}

extension on Iterable<MapEntry<DateTime, double>> {
  Map<DateTime, double> toMap() {
    return Map.fromEntries(this);
  }
}
