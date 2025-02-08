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

    // Вычисляем общие бюджеты, доходы и расходы
    final totalBudget = <DateTime, double>{};
    final incomes = <DateTime, double>{};
    final expenses = <DateTime, double>{};

    for (var payment in filteredPayments) {
      final date = payment.date;
      final amount = payment.details.money.toDouble();

      totalBudget.update(
        date,
        (value) => value + amount,
        ifAbsent: () => amount,
      );

      if (amount > 0) {
        incomes.update(
          date,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      } else {
        expenses.update(
          date,
          (value) => value + amount.abs(),
          ifAbsent: () => amount.abs(),
        );
      }
    }

    return BudgetStatistics(
      totalBudget: totalBudget,
      incomes: incomes,
      expenses: expenses,
    );
  }
}

extension on Iterable<MapEntry<DateTime, double>> {
  Map<DateTime, double> toMap() {
    return Map.fromEntries(this);
  }
}
