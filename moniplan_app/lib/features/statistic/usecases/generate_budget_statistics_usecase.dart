import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/repo/i_payment_planner_repo.dart';
import 'package:moniplan_app/features/payment/usecases/generate_new_planner_usecase.dart';
import 'package:moniplan_app/features/payment/usecases/group_payments_by_date_usecase.dart';
import 'package:moniplan_app/utils/_index.dart';

import '../models/_index.dart';

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
class GenerateBudgetStatisticsUseCase {
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

  Future<BudgetStatistics> run() async {
    final planner = await plannerRepo.getPlannerById(plannerId);
    if (planner == null) {
      throw Exception('Planner not found');
    }

    final payments = await plannerRepo.getPaymentsByPlannerId(plannerId: plannerId);
    if (payments.isEmpty) {
      return const BudgetStatistics(totalBudget: {}, incomes: {}, expenses: {});
    }

    final targetPlanner =
        GenerateNewPlannerUseCase(
          customPlannerId: planner.id,
          payments: payments,
          dateStart: dateStart ?? planner.dateStart,
          dateEnd: dateEnd ?? planner.dateEnd,
          initialBudget: planner.initialBudget,
        ).run().planner;

    final paymentsByDate =
        GroupPaymentsByDateUsecase(
          today: DateTime.now(),
          payments:
              ConstrainItemsInPeriodUseCase(
                items: targetPlanner.payments,
                dateStart: targetPlanner.dateStart,
                dateEnd: targetPlanner.dateEnd,
                dateExtractor: (item) => item.date.dayBound,
              ).run(),
        ).run();

    // ignore:omit_local_variable_types
    final BudgetStatisticsTotal totalBudget = {};
    final incomes = <DateTime, num>{};
    final expenses = <DateTime, num>{};
    final corrections = <DateTime, num>{};

    var runningTotal = planner.initialBudget;

    for (var i = 0; i < paymentsByDate.length; i++) {
      final group = paymentsByDate[i];

      final dayDate = group.date;
      final dayPayments = group.payments;

      double dailyIncome = 0;
      double dailyExpense = 0;
      double dailyCorrection = 0;
      var allCompleted = true;

      for (final payment in dayPayments) {
        if (payment.isEnabled) {
          final normalizedMoney = payment.normalizedMoney.toDouble();
          if (payment.type == PaymentType.income) {
            dailyIncome += normalizedMoney;
          } else if (payment.type == PaymentType.expense) {
            dailyExpense += normalizedMoney.abs();
          } else if (payment.type == PaymentType.correction) {
            dailyCorrection += payment.details.money.toDouble();
          }
        }
        if (payment.isEnabled && !payment.isDone) {
          allCompleted = false;
        }
      }

      final dailyTotal = dailyIncome - dailyExpense;
      if (dailyTotal == 0 && dailyIncome == 0 && dailyExpense == 0 && dailyCorrection == 0) {
        continue;
      }

      runningTotal += dailyTotal;

      // Если в этот день была коррекция, устанавливаем значение из последней коррекции
      final lastCorrection =
          dayPayments.where((p) => p.isEnabled && p.type == PaymentType.correction).lastOrNull;

      if (lastCorrection != null) {
        runningTotal = lastCorrection.details.money.toDouble();
        corrections[dayDate] = lastCorrection.details.money.toDouble();
      }

      totalBudget[dayDate] = (totalBudget: runningTotal, allCompleted: allCompleted);
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
      corrections: corrections,
    );
  }
}
