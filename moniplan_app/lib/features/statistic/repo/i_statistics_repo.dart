import '../models/_index.dart';

abstract class IStatisticsRepo {
  Future<BudgetStatistics> getStatistics({required String plannerId});

  Future<BudgetStatistics> getStatisticsForPeriod({
    required String plannerId,
    required DateTime start,
    required DateTime end,
  });
}
