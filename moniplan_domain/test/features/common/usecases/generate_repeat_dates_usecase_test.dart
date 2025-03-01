import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('GenerateRepeatDatesUseCase', () {
    // Фиксированная дата для тестов, чтобы избежать зависимости от текущего времени
    final baseDate = DateTime(2023, 6, 15); // 15 июня 2023
    final startDate = DateTime(2023, 6, 1); // 1 июня 2023
    final endDate = DateTime(2023, 7, 31); // 31 июля 2023

    test('должен генерировать даты с ежедневным повторением', () {
      // Arrange
      final useCase = GenerateRepeatDatesUseCase(
        repeat: DateTimeRepeat.day,
        base: baseDate,
        dateStart: startDate,
        dateEnd: endDate,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isNotEmpty);
      expect(result.first, baseDate);

      // Проверяем, что каждая следующая дата отличается от предыдущей на 1 день
      for (int i = 0; i < result.length - 1; i++) {
        final difference = result[i + 1].difference(result[i]).inDays;
        expect(difference, 1);
      }

      // Проверяем, что все даты находятся в заданном диапазоне
      for (final date in result) {
        expect(date.compareTo(startDate) >= 0, isTrue);
        expect(date.compareTo(endDate) <= 0, isTrue);
      }
    });

    test('должен генерировать даты с еженедельным повторением', () {
      // Arrange
      final useCase = GenerateRepeatDatesUseCase(
        repeat: DateTimeRepeat.week,
        base: baseDate,
        dateStart: startDate,
        dateEnd: endDate,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isNotEmpty);
      expect(result.first, baseDate);

      // Проверяем, что каждая следующая дата отличается от предыдущей на 7 дней
      for (int i = 0; i < result.length - 1; i++) {
        final difference = result[i + 1].difference(result[i]).inDays;
        expect(difference, 7);
      }

      // Проверяем, что все даты находятся в заданном диапазоне
      for (final date in result) {
        expect(date.compareTo(startDate) >= 0, isTrue);
        expect(date.compareTo(endDate) <= 0, isTrue);
      }
    });

    test('должен генерировать даты с ежемесячным повторением', () {
      // Arrange
      final useCase = GenerateRepeatDatesUseCase(
        repeat: DateTimeRepeat.month,
        base: baseDate,
        dateStart: startDate,
        dateEnd: DateTime(2023, 12, 31), // Расширяем период до конца года
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isNotEmpty);
      expect(result.first, baseDate);

      // Проверяем, что каждая следующая дата имеет тот же день месяца, но следующий месяц
      for (int i = 0; i < result.length - 1; i++) {
        expect(result[i + 1].day, result[i].day);
        expect(result[i + 1].month - result[i].month, 1);
      }

      // Проверяем, что все даты находятся в заданном диапазоне
      for (final date in result) {
        expect(date.compareTo(startDate) >= 0, isTrue);
        expect(date.compareTo(DateTime(2023, 12, 31)) <= 0, isTrue);
      }
    });

    test('должен генерировать прошлые даты при включенном флаге generatePastDates', () {
      // Arrange
      final midDate = DateTime(2023, 6, 15);
      final useCase = GenerateRepeatDatesUseCase(
        repeat: DateTimeRepeat.week,
        base: midDate,
        dateStart: DateTime(2023, 5, 1), // Начало периода в прошлом
        dateEnd: DateTime(2023, 7, 31),
        generatePastDates: true,
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isNotEmpty);

      // Проверяем, что есть даты до базовой даты
      final pastDates = result.where((date) => date.isBefore(midDate)).toList();
      expect(pastDates, isNotEmpty);

      // Проверяем, что все даты находятся в заданном диапазоне
      for (final date in result) {
        expect(date.compareTo(DateTime(2023, 5, 1)) >= 0, isTrue);
        expect(date.compareTo(DateTime(2023, 7, 31)) <= 0, isTrue);
      }
    });

    test('не должен генерировать прошлые даты при выключенном флаге generatePastDates', () {
      // Arrange
      final midDate = DateTime(2023, 6, 15);
      final useCase = GenerateRepeatDatesUseCase(
        repeat: DateTimeRepeat.week,
        base: midDate,
        dateStart: DateTime(2023, 5, 1), // Начало периода в прошлом
        dateEnd: DateTime(2023, 7, 31),
        generatePastDates: false, // По умолчанию false
      );

      // Act
      final result = useCase.run();

      // Assert
      expect(result, isNotEmpty);

      // Проверяем, что нет дат до базовой даты (кроме самой базовой)
      final pastDates = result.where((date) => date.isBefore(midDate)).toList();
      expect(pastDates, isEmpty);

      // Проверяем, что все даты находятся в заданном диапазоне
      for (final date in result) {
        expect(date.compareTo(DateTime(2023, 5, 1)) >= 0, isTrue);
        expect(date.compareTo(DateTime(2023, 7, 31)) <= 0, isTrue);
      }
    });

    test('должен корректно обрабатывать граничные случаи', () {
      // Arrange - базовая дата совпадает с началом периода
      final useCase1 = GenerateRepeatDatesUseCase(
        repeat: DateTimeRepeat.week,
        base: startDate,
        dateStart: startDate,
        dateEnd: endDate,
      );

      // Act
      final result1 = useCase1.run();

      // Assert
      expect(result1, isNotEmpty);
      expect(result1.first, startDate);

      // Arrange - базовая дата совпадает с концом периода
      final useCase2 = GenerateRepeatDatesUseCase(
        repeat: DateTimeRepeat.week,
        base: endDate,
        dateStart: startDate,
        dateEnd: endDate,
      );

      // Act
      final result2 = useCase2.run();

      // Assert
      expect(result2, isNotEmpty);
      expect(result2.first, endDate);

      // Проверяем, что все даты находятся в заданном диапазоне
      for (final date in [...result1, ...result2]) {
        expect(date.compareTo(startDate) >= 0, isTrue);
        expect(date.compareTo(endDate) <= 0, isTrue);
      }
    });
  });
}
