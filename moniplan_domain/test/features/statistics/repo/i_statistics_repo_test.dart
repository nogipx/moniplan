import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

// Тестовая реализация репозитория
class TestStatisticsRepo implements IStatisticsRepo {
  final Map<String, BudgetStatistics> _statistics = {};
  
  void addStatistics(String plannerId, BudgetStatistics statistics) {
    _statistics[plannerId] = statistics;
  }
  
  @override
  Future<BudgetStatistics> getStatistics({required String plannerId}) async {
    return _statistics[plannerId] ?? createEmptyStatistics();
  }
  
  @override
  Future<BudgetStatistics> getStatisticsForPeriod({
    required String plannerId,
    required DateTime start,
    required DateTime end,
  }) async {
    final stats = _statistics[plannerId];
    if (stats == null) return createEmptyStatistics();
    
    // Фильтруем статистику по периоду
    final filteredTotalBudget = <DateTime, ({num totalBudget, bool allCompleted})>{};
    final filteredIncomes = <DateTime, num>{};
    final filteredExpenses = <DateTime, num>{};
    
    for (final entry in stats.totalBudget.entries) {
      if (entry.key.compareTo(start) >= 0 && entry.key.compareTo(end) <= 0) {
        filteredTotalBudget[entry.key] = entry.value;
      }
    }
    
    for (final entry in stats.incomes.entries) {
      if (entry.key.compareTo(start) >= 0 && entry.key.compareTo(end) <= 0) {
        filteredIncomes[entry.key] = entry.value;
      }
    }
    
    for (final entry in stats.expenses.entries) {
      if (entry.key.compareTo(start) >= 0 && entry.key.compareTo(end) <= 0) {
        filteredExpenses[entry.key] = entry.value;
      }
    }
    
    return BudgetStatistics(
      totalBudget: filteredTotalBudget,
      incomes: filteredIncomes,
      expenses: filteredExpenses,
    );
  }
}

// Вспомогательная функция для создания пустой статистики
BudgetStatistics createEmptyStatistics() {
  return BudgetStatistics(
    totalBudget: {},
    incomes: {},
    expenses: {},
  );
}

void main() {
  group('IStatisticsRepo', () {
    // Фабричные методы для создания тестовых данных
    BudgetStatistics createTestStatistics() {
      final totalBudget = <DateTime, ({num totalBudget, bool allCompleted})>{
        DateTime(2023, 1, 1): (totalBudget: 1000, allCompleted: true),
        DateTime(2023, 1, 2): (totalBudget: 1500, allCompleted: false),
      };
      
      final incomes = <DateTime, num>{
        DateTime(2023, 1, 1): 500,
        DateTime(2023, 1, 2): 700,
      };
      
      final expenses = <DateTime, num>{
        DateTime(2023, 1, 1): 200,
        DateTime(2023, 1, 2): 300,
      };
      
      return BudgetStatistics(
        totalBudget: totalBudget,
        incomes: incomes,
        expenses: expenses,
      );
    }
    
    test('получение_статистики_по_id_планировщика', () async {
      // Arrange
      final plannerId = 'test-planner-id';
      final statistics = createTestStatistics();
      
      final repo = TestStatisticsRepo();
      repo.addStatistics(plannerId, statistics);
      
      // Act
      final sut = repo;
      final result = await sut.getStatistics(plannerId: plannerId);
      
      // Assert
      expect(result.totalBudget.length, 2);
      expect(result.incomes.length, 2);
      expect(result.expenses.length, 2);
      expect(result.isEmpty, isFalse);
      
      // Проверяем, что данные соответствуют ожидаемым
      final day1 = DateTime(2023, 1, 1);
      final day2 = DateTime(2023, 1, 2);
      
      expect(result.totalBudget[day1]?.totalBudget, 1000);
      expect(result.totalBudget[day1]?.allCompleted, isTrue);
      expect(result.totalBudget[day2]?.totalBudget, 1500);
      expect(result.totalBudget[day2]?.allCompleted, isFalse);
      
      expect(result.incomes[day1], 500);
      expect(result.incomes[day2], 700);
      
      expect(result.expenses[day1], 200);
      expect(result.expenses[day2], 300);
    });
    
    test('получение_пустой_статистики_при_отсутствии_данных', () async {
      // Arrange
      final plannerId = 'non-existent-id';
      final repo = TestStatisticsRepo();
      
      // Act
      final sut = repo;
      final result = await sut.getStatistics(plannerId: plannerId);
      
      // Assert
      expect(result.isEmpty, isTrue);
      expect(result.totalBudget, isEmpty);
      expect(result.incomes, isEmpty);
      expect(result.expenses, isEmpty);
    });
    
    test('получение_статистики_за_период', () async {
      // Arrange
      final plannerId = 'test-planner-id';
      final statistics = createTestStatistics();
      
      final repo = TestStatisticsRepo();
      repo.addStatistics(plannerId, statistics);
      
      final start = DateTime(2023, 1, 1);
      final end = DateTime(2023, 1, 1); // Только первый день
      
      // Act
      final sut = repo;
      final result = await sut.getStatisticsForPeriod(
        plannerId: plannerId,
        start: start,
        end: end,
      );
      
      // Assert
      expect(result.totalBudget.length, 1);
      expect(result.incomes.length, 1);
      expect(result.expenses.length, 1);
      
      // Проверяем, что данные соответствуют ожидаемым
      final day1 = DateTime(2023, 1, 1);
      
      expect(result.totalBudget[day1]?.totalBudget, 1000);
      expect(result.totalBudget[day1]?.allCompleted, isTrue);
      
      expect(result.incomes[day1], 500);
      expect(result.expenses[day1], 200);
      
      // Проверяем, что данные за второй день отсутствуют
      final day2 = DateTime(2023, 1, 2);
      expect(result.totalBudget.containsKey(day2), isFalse);
      expect(result.incomes.containsKey(day2), isFalse);
      expect(result.expenses.containsKey(day2), isFalse);
    });
    
    test('получение_пустой_статистики_за_период_при_отсутствии_данных', () async {
      // Arrange
      final plannerId = 'non-existent-id';
      final repo = TestStatisticsRepo();
      
      final start = DateTime(2023, 1, 1);
      final end = DateTime(2023, 1, 31);
      
      // Act
      final sut = repo;
      final result = await sut.getStatisticsForPeriod(
        plannerId: plannerId,
        start: start,
        end: end,
      );
      
      // Assert
      expect(result.isEmpty, isTrue);
      expect(result.totalBudget, isEmpty);
      expect(result.incomes, isEmpty);
      expect(result.expenses, isEmpty);
    });
  });
} 