import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

// Создаем тестовую модель с датой
class TestItem {
  final DateTime date;
  final String name;

  TestItem({required this.date, required this.name});

  @override
  String toString() => '$name: $date';
}

void main() {
  group('ConstrainItemsInPeriodUseCase', () {
    // Фиксированные даты для тестов
    final startDate = DateTime(2023, 6, 1); // 1 июня 2023
    final endDate = DateTime(2023, 6, 30); // 30 июня 2023

    // Тестовые данные
    final testItems = [
      TestItem(date: DateTime(2023, 5, 15), name: 'До периода'), // До периода
      TestItem(date: DateTime(2023, 6, 1), name: 'Начало периода'), // Начало периода
      TestItem(date: DateTime(2023, 6, 15), name: 'Внутри периода'), // Внутри периода
      TestItem(date: DateTime(2023, 6, 30), name: 'Конец периода'), // Конец периода
      TestItem(date: DateTime(2023, 7, 15), name: 'После периода'), // После периода
    ];

    test('должен фильтровать элементы в заданном периоде', () {
      // Arrange
      final useCase = ConstrainItemsInPeriodUseCase<TestItem>(
        items: testItems,
        dateStart: startDate,
        dateEnd: endDate,
        dateExtractor: (item) => item.date,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result.length, 3); // Должны остаться только элементы в периоде
      
      // Проверяем, что все даты находятся в заданном диапазоне
      for (final item in result) {
        final itemDate = item.date.dayBound;
        expect(itemDate.compareTo(startDate.dayBound) >= 0, isTrue);
        expect(itemDate.compareTo(endDate.dayBound) <= 0, isTrue);
      }
      
      // Проверяем, что в результате есть конкретные элементы
      expect(result.any((item) => item.name == 'Начало периода'), isTrue);
      expect(result.any((item) => item.name == 'Внутри периода'), isTrue);
      expect(result.any((item) => item.name == 'Конец периода'), isTrue);
      
      // Проверяем, что в результате нет элементов вне периода
      expect(result.any((item) => item.name == 'До периода'), isFalse);
      expect(result.any((item) => item.name == 'После периода'), isFalse);
    });

    test('должен возвращать пустой список, если нет элементов в периоде', () {
      // Arrange
      final itemsOutsidePeriod = [
        TestItem(date: DateTime(2023, 5, 15), name: 'До периода'),
        TestItem(date: DateTime(2023, 7, 15), name: 'После периода'),
      ];
      
      final useCase = ConstrainItemsInPeriodUseCase<TestItem>(
        items: itemsOutsidePeriod,
        dateStart: startDate,
        dateEnd: endDate,
        dateExtractor: (item) => item.date,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isEmpty);
    });

    test('должен возвращать пустой список, если входной список пуст', () {
      // Arrange
      final useCase = ConstrainItemsInPeriodUseCase<TestItem>(
        items: [],
        dateStart: startDate,
        dateEnd: endDate,
        dateExtractor: (item) => item.date,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isEmpty);
    });

    test('должен корректно обрабатывать граничные случаи с временем', () {
      // Arrange - элементы с временем в тот же день
      final itemsWithTime = [
        TestItem(date: DateTime(2023, 6, 1, 0, 0), name: 'Начало дня'),
        TestItem(date: DateTime(2023, 6, 1, 12, 30), name: 'Середина дня'),
        TestItem(date: DateTime(2023, 6, 1, 23, 59), name: 'Конец дня'),
      ];
      
      final useCase = ConstrainItemsInPeriodUseCase<TestItem>(
        items: itemsWithTime,
        dateStart: startDate,
        dateEnd: startDate, // Тот же день
        dateExtractor: (item) => item.date,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result.length, 3); // Все элементы должны быть включены
      
      // Проверяем, что все элементы присутствуют
      expect(result.any((item) => item.name == 'Начало дня'), isTrue);
      expect(result.any((item) => item.name == 'Середина дня'), isTrue);
      expect(result.any((item) => item.name == 'Конец дня'), isTrue);
    });

    test('должен корректно обрабатывать случай, когда начальная дата позже конечной', () {
      // Arrange - начальная дата позже конечной
      final useCase = ConstrainItemsInPeriodUseCase<TestItem>(
        items: testItems,
        dateStart: endDate, // 30 июня
        dateEnd: startDate, // 1 июня
        dateExtractor: (item) => item.date,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isEmpty); // Не должно быть элементов, так как период некорректен
    });
  });
}