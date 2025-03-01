import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('PeriodDateTime Extension', () {
    test('monthBound должен возвращать дату с первым днем месяца и нулевым временем', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30, 45);

      // Act
      final result = date.monthBound;

      // Assert
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 1);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });

    test('dayBound должен возвращать дату с нулевым временем', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30, 45);

      // Act
      final result = date.dayBound;

      // Assert
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 15);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });

    test('minuteBound должен возвращать дату с нулевыми секундами', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30, 45);

      // Act
      final result = date.minuteBound;

      // Assert
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 15);
      expect(result.hour, 12);
      expect(result.minute, 30);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });

    test('isMonthEdge должен корректно определять границу месяца', () {
      // Arrange
      final date = DateTime(2023, 6, 15);
      final prevDateSameMonth = DateTime(2023, 6, 14);
      final prevDateDiffMonth = DateTime(2023, 5, 31);
      final nextDate = DateTime(2023, 6, 16);

      // Act & Assert
      // Случай 1: предыдущая дата в том же месяце
      expect(date.isMonthEdge(prevDate: prevDateSameMonth, nextDate: nextDate), isFalse);

      // Случай 2: предыдущая дата в другом месяце
      expect(date.isMonthEdge(prevDate: prevDateDiffMonth, nextDate: nextDate), isTrue);

      // Случай 3: нет предыдущей даты, но есть следующая
      expect(date.isMonthEdge(prevDate: null, nextDate: nextDate), isTrue);

      // Случай 4: есть предыдущая дата, но нет следующей
      expect(date.isMonthEdge(prevDate: prevDateSameMonth, nextDate: null), isFalse);

      // Случай 5: нет ни предыдущей, ни следующей даты
      expect(date.isMonthEdge(prevDate: null, nextDate: null), isFalse);
    });

    test('addTime должен корректно добавлять время', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30);

      // Act & Assert
      // Добавление дней
      final addedDays = date.addTime(day: 5);
      expect(addedDays.year, 2023);
      expect(addedDays.month, 6);
      expect(addedDays.day, 20);
      expect(addedDays.hour, 12);
      expect(addedDays.minute, 30);

      // Добавление месяцев
      final addedMonths = date.addTime(month: 3);
      expect(addedMonths.year, 2023);
      expect(addedMonths.month, 9);
      expect(addedMonths.day, 15);
      expect(addedMonths.hour, 12);
      expect(addedMonths.minute, 30);

      // Добавление лет
      final addedYears = date.addTime(year: 2);
      expect(addedYears.year, 2025);
      expect(addedYears.month, 6);
      expect(addedYears.day, 15);
      expect(addedYears.hour, 12);
      expect(addedYears.minute, 30);

      // Комбинированное добавление
      final addedCombined = date.addTime(year: 1, month: 2, day: 3);
      expect(addedCombined.year, 2024);
      expect(addedCombined.month, 8);
      expect(addedCombined.day, 18);
      expect(addedCombined.hour, 12);
      expect(addedCombined.minute, 30);
    });

    test('subtractTime должен корректно вычитать время', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30);

      // Act & Assert
      // Вычитание дней
      final subtractedDays = date.subtractTime(day: 5);
      expect(subtractedDays.year, 2023);
      expect(subtractedDays.month, 6);
      expect(subtractedDays.day, 10);
      expect(subtractedDays.hour, 12);
      expect(subtractedDays.minute, 30);

      // Вычитание месяцев
      final subtractedMonths = date.subtractTime(month: 3);
      expect(subtractedMonths.year, 2023);
      expect(subtractedMonths.month, 3);
      expect(subtractedMonths.day, 15);
      expect(subtractedMonths.hour, 12);
      expect(subtractedMonths.minute, 30);

      // Вычитание лет
      final subtractedYears = date.subtractTime(year: 2);
      expect(subtractedYears.year, 2021);
      expect(subtractedYears.month, 6);
      expect(subtractedYears.day, 15);
      expect(subtractedYears.hour, 12);
      expect(subtractedYears.minute, 30);

      // Комбинированное вычитание
      final subtractedCombined = date.subtractTime(year: 1, month: 2, day: 3);
      expect(subtractedCombined.year, 2022);
      expect(subtractedCombined.month, 4);
      expect(subtractedCombined.day, 12);
      expect(subtractedCombined.hour, 12);
      expect(subtractedCombined.minute, 30);
    });

    test('monthStart должен возвращать первый день месяца', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30);

      // Act
      final result = date.monthStart;

      // Assert
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 1);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('monthMedian должен возвращать середину месяца', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30);

      // Act
      final result = date.monthMedian;

      // Assert
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 15); // 1 + 14 = 15
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('monthEnd должен возвращать последний день месяца', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30);

      // Act
      final result = date.monthEnd;

      // Assert
      expect(result.year, 2023);
      expect(result.month, 6);
      expect(result.day, 30); // Июнь имеет 30 дней
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);

      // Проверка для месяца с 31 днем
      final dateJuly = DateTime(2023, 7, 15);
      expect(dateJuly.monthEnd.day, 31);

      // Проверка для февраля в невисокосном году
      final dateFeb = DateTime(2023, 2, 15);
      expect(dateFeb.monthEnd.day, 28);

      // Проверка для февраля в високосном году
      final dateFebLeap = DateTime(2024, 2, 15);
      expect(dateFebLeap.monthEnd.day, 29);
    });

    test('isSameDay должен корректно сравнивать даты', () {
      // Arrange
      final date = DateTime(2023, 6, 15, 12, 30);

      // Act & Assert
      // Та же дата, но другое время
      expect(date.isSameDay(DateTime(2023, 6, 15, 18, 45)), isTrue);

      // Другой день
      expect(date.isSameDay(DateTime(2023, 6, 16, 12, 30)), isFalse);

      // Другой месяц
      expect(date.isSameDay(DateTime(2023, 7, 15, 12, 30)), isFalse);

      // Другой год
      expect(date.isSameDay(DateTime(2024, 6, 15, 12, 30)), isFalse);
    });

    test('currentYear должен возвращать дату в текущем году', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final result1 = DateTimeStatic.currentYear(day: 15, month: 6);
      final result2 = DateTimeStatic.currentYear(day: 15); // Используем текущий месяц

      // Assert
      expect(result1.year, now.year);
      expect(result1.month, 6);
      expect(result1.day, 15);

      expect(result2.year, now.year);
      expect(result2.month, now.month);
      expect(result2.day, 15);
    });
  });
}
