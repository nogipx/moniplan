class BudgetStatistics {
  final Map<DateTime, num> totalBudget;
  final Map<DateTime, num> incomes;
  final Map<DateTime, num> expenses;

  const BudgetStatistics({
    required this.totalBudget,
    required this.incomes,
    required this.expenses,
  });

  bool get isEmpty => totalBudget.isEmpty && incomes.isEmpty && expenses.isEmpty;
}
