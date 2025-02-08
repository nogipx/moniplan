class BudgetStatistics {
  final Map<DateTime, double> totalBudget;
  final Map<DateTime, double> incomes;
  final Map<DateTime, double> expenses;

  const BudgetStatistics({
    required this.totalBudget,
    required this.incomes,
    required this.expenses,
  });

  bool get isEmpty => totalBudget.isEmpty && incomes.isEmpty && expenses.isEmpty;
}
