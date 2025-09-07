typedef BudgetStatisticsTotal = Map<DateTime, ({num totalBudget, bool allCompleted})>;

class BudgetStatistics {
  final BudgetStatisticsTotal totalBudget;
  final Map<DateTime, num> incomes;
  final Map<DateTime, num> expenses;
  final Map<DateTime, num> corrections;

  const BudgetStatistics({
    required this.totalBudget,
    required this.incomes,
    required this.expenses,
    this.corrections = const {},
  });

  bool get isEmpty =>
      totalBudget.isEmpty && incomes.isEmpty && expenses.isEmpty && corrections.isEmpty;
}
