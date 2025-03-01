import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('BudgetStatistics', () {
    test('создание_экземпляра', () {
      // Arrange
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
      
      // Act
      final sut = BudgetStatistics(
        totalBudget: totalBudget,
        incomes: incomes,
        expenses: expenses,
      );
      
      // Assert
      expect(sut.totalBudget, equals(totalBudget));
      expect(sut.incomes, equals(incomes));
      expect(sut.expenses, equals(expenses));
      expect(sut.isEmpty, isFalse);
    });
    
    test('пустая_статистика', () {
      // Arrange
      final emptyMap1 = <DateTime, ({num totalBudget, bool allCompleted})>{};
      final emptyMap2 = <DateTime, num>{};
      final emptyMap3 = <DateTime, num>{};
      
      // Act
      final sut = BudgetStatistics(
        totalBudget: emptyMap1,
        incomes: emptyMap2,
        expenses: emptyMap3,
      );
      
      // Assert
      expect(sut.totalBudget, isEmpty);
      expect(sut.incomes, isEmpty);
      expect(sut.expenses, isEmpty);
      expect(sut.isEmpty, isTrue);
    });
    
    test('частично_заполненная_статистика_не_пуста', () {
      // Arrange
      final emptyMap1 = <DateTime, ({num totalBudget, bool allCompleted})>{};
      final emptyMap2 = <DateTime, num>{};
      final nonEmptyMap = <DateTime, num>{
        DateTime(2023, 1, 1): 200,
      };
      
      // Act
      final sut = BudgetStatistics(
        totalBudget: emptyMap1,
        incomes: emptyMap2,
        expenses: nonEmptyMap,
      );
      
      // Assert
      expect(sut.isEmpty, isFalse);
    });
  });
} 