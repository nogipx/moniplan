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
/// - [startDate]: (необязательно) Начальная дата для ограничения периода выборки платежей.
/// - [endDate]: (необязательно) Конечная дата для ограничения периода выборки платежей.
///
/// Метод [run]:
/// - Возвращает объект [BudgetStatistics], содержащий общую сумму бюджета, доходы и расходы
///   за указанный период.
/// - Если [startDate] или [endDate] указаны, они используются для дополнительного ограничения
///   периода выборки платежей. Эти даты должны находиться в рамках дат планировщика.
///
/// Исключения:
/// - Выбрасывает исключение, если планировщик с указанным [plannerId] не найден.
class GenerateBudgetStatisticsUseCase implements IUseCaseAsync<BudgetStatistics> {
  final IPlannerRepo plannerRepo;
  final String plannerId;
  final DateTime? startDate;
  final DateTime? endDate;

  GenerateBudgetStatisticsUseCase({
    required this.plannerRepo,
    required this.plannerId,
    this.startDate,
    this.endDate,
  });

  @override
  Future<BudgetStatistics> run() async {
    final payments = await plannerRepo.getPaymentsByPlannerId(plannerId: plannerId);
    final planner = await plannerRepo.getPlannerById(plannerId);

    if (planner == null) {
      throw Exception('Planner not found');
    }

    var constrainedPayments = ConstrainItemsInPeriodUseCase(
      items: payments,
      dateStart: planner.dateStart,
      dateEnd: planner.dateEnd,
      dateExtractor: (payment) => payment.date,
    ).run();

    if (startDate != null || endDate != null) {
      constrainedPayments = ConstrainItemsInPeriodUseCase(
        items: constrainedPayments,
        dateStart: startDate ?? planner.dateStart,
        dateEnd: endDate ?? planner.dateEnd,
        dateExtractor: (payment) => payment.date,
      ).run();
    }

    final computedBudget = ComputeBudgetUseCase(
      payments: constrainedPayments,
      initialBudget: planner.initialBudget,
    ).run();

    final paymentsByDate = GroupPaymentsByDateUsecase(
      payments: constrainedPayments,
      today: DateTime.now(),
    ).run();

    final Map<DateTime, double> totalBudget = Map.from(computedBudget.budget);
    final Map<DateTime, double> incomes = {};
    final Map<DateTime, double> expenses = {};

    for (var entry in paymentsByDate) {
      final date = entry.date;
      final payments = entry.payments;
      for (var payment in payments) {
        final money = payment.normalizedMoney;

        if (money > 0) {
          incomes[date] = (incomes[date] ?? 0) + money;
        } else {
          expenses[date] = (expenses[date] ?? 0) + money.abs();
        }
      }
    }

    return BudgetStatistics(
      totalBudget: totalBudget,
      incomes: incomes,
      expenses: expenses,
    );
  }
}
