import 'package:moniplan_domain/moniplan_domain.dart';

/// Use case для генерации статистики бюджета.
///
/// Этот класс отвечает за вычисление статистики бюджета на основе платежей,
/// связанных с определенным планировщиком. Он позволяет ограничивать период
/// выборки платежей, чтобы получить статистику за определенный временной интервал.
///
/// Конструктор:
/// - [plannerRepo]: Репозиторий, используемый для получения данных о планировщике и платежах.
/// - [plannerId]: Идентификатор планировщика, для которого будет сгенерирована статистика.
/// - [dateStart]: (необязательно) Начальная дата для ограничения периода выборки платежей.
/// - [dateEnd]: (необязательно) Конечная дата для ограничения периода выборки платежей.
///
/// Метод [run]:
/// - Возвращает объект [BudgetStatistics], содержащий общую сумму бюджета, доходы и расходы
///   за указанный период.
/// - Если [dateStart] или [dateEnd] указаны, они используются для дополнительного ограничения
///   периода выборки платежей. Эти даты должны находиться в рамках дат планировщика.
///
/// Исключения:
/// - Выбрасывает исключение, если планировщик с указанным [plannerId] не найден.
class GenerateBudgetStatisticsUseCase implements IUseCaseAsync<BudgetStatistics> {
  final IPlannerRepo plannerRepo;
  final String plannerId;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  GenerateBudgetStatisticsUseCase({
    required this.plannerRepo,
    required this.plannerId,
    this.dateStart,
    this.dateEnd,
  });

  @override
  Future<BudgetStatistics> run() async {
    final planner = await plannerRepo.getPlannerById(plannerId, withActualInfo: false);
    if (planner == null) {
      throw Exception('Planner not found');
    }

    final payments = await plannerRepo.getPaymentsByPlannerId(plannerId: plannerId);
    if (payments.isEmpty) {
      return BudgetStatistics(totalBudget: {}, incomes: {}, expenses: {});
    }

    final targetPlanner = GenerateNewPlannerUseCase(
      customPlannerId: planner.id,
      payments: payments,
      dateStart: dateStart ?? planner.dateStart,
      dateEnd: dateEnd ?? planner.dateEnd,
      initialBudget: planner.initialBudget,
    ).run().planner;

    final paymentsByDate = GroupPaymentsByDateUsecase(
      today: DateTime.now(),
      payments: ConstrainItemsInPeriodUseCase(
        items: targetPlanner.payments,
        dateStart: targetPlanner.dateStart,
        dateEnd: targetPlanner.dateEnd,
        dateExtractor: (item) => item.date.dayBound,
      ).run(),
    ).run();

    final Map<DateTime, num> totalBudget = {};
    final Map<DateTime, num> incomes = {};
    final Map<DateTime, num> expenses = {};

    num runningTotal = planner.initialBudget;

    for (var i = 0; i < paymentsByDate.length; i++) {
      final group = paymentsByDate[i];

      final dayDate = group.date;
      final dayPayments = group.payments;

      double dailyIncome = 0;
      double dailyExpense = 0;

      for (final payment in dayPayments) {
        if (payment.isEnabled) {
          final normalizedMoney = payment.normalizedMoney.toDouble();
          if (payment.type == PaymentType.income) {
            dailyIncome += normalizedMoney;
          } else if (payment.type == PaymentType.expense) {
            dailyExpense += normalizedMoney.abs();
          }
        }
      }

      final dailyTotal = dailyIncome - dailyExpense;
      runningTotal += dailyTotal;
      totalBudget[dayDate] = runningTotal;
      if (dailyIncome > 0) {
        incomes[dayDate] = dailyIncome;
      }
      if (dailyExpense > 0) {
        expenses[dayDate] = dailyExpense;
      }
    }

    return BudgetStatistics(
      totalBudget: totalBudget,
      incomes: incomes,
      expenses: expenses,
    );
  }
}
