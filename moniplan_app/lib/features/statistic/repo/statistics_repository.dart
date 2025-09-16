import 'package:moniplan_app/features/payment/repo/i_payment_planner_repo.dart';

import '../models/_index.dart';
import '../usecases/_index.dart';
import 'i_statistics_repo.dart';

class StatisticsRepoImpl implements IStatisticsRepo {
  final IPlannerRepo plannerRepo;

  const StatisticsRepoImpl({required this.plannerRepo});

  @override
  Future<BudgetStatistics> getStatistics({required String plannerId}) async {
    final useCase = GenerateBudgetStatisticsUseCase(plannerRepo: plannerRepo, plannerId: plannerId);

    return useCase.run();
  }

  @override
  Future<BudgetStatistics> getStatisticsForPeriod({
    required String plannerId,
    required DateTime start,
    required DateTime end,
  }) async {
    final useCase = GenerateBudgetStatisticsUseCase(
      plannerRepo: plannerRepo,
      plannerId: plannerId,
      dateStart: start,
      dateEnd: end,
    );

    return useCase.run();
  }
}
