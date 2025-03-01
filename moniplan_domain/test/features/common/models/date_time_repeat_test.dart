import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('DateTimeRepeat', () {
    test('значения_id', () {
      // Arrange
      final sut = DateTimeRepeat.values;

      // Assert
      expect(sut.firstWhere((type) => type == DateTimeRepeat.noRepeat).id, 0);
      expect(sut.firstWhere((type) => type == DateTimeRepeat.day).id, 1);
      expect(sut.firstWhere((type) => type == DateTimeRepeat.week).id, 7);
      expect(sut.firstWhere((type) => type == DateTimeRepeat.month).id, 11);
      expect(sut.firstWhere((type) => type == DateTimeRepeat.year).id, 22);
    });

    test('создание_экземпляра_из_id', () {
      // Arrange
      final validIds = [0, 1, 7, 11, 22];
      final invalidId = 999;
      final nullId = null;

      // Act & Assert
      expect(DateTimeRepeat.from(validIds[0]), DateTimeRepeat.noRepeat);
      expect(DateTimeRepeat.from(validIds[1]), DateTimeRepeat.day);
      expect(DateTimeRepeat.from(validIds[2]), DateTimeRepeat.week);
      expect(DateTimeRepeat.from(validIds[3]), DateTimeRepeat.month);
      expect(DateTimeRepeat.from(validIds[4]), DateTimeRepeat.year);

      // Несуществующий id должен возвращать noRepeat
      expect(DateTimeRepeat.from(invalidId), DateTimeRepeat.noRepeat);
      expect(DateTimeRepeat.from(nullId), DateTimeRepeat.noRepeat);
    });

    test('previous_должен_корректно_вычислять_предыдущую_дату', () {
      // Arrange
      final baseDate = DateTime(2023, 6, 15); // 15 июня 2023

      // Act & Assert
      expect(DateTimeRepeat.noRepeat.previous(baseDate), baseDate);
      expect(DateTimeRepeat.day.previous(baseDate), DateTime(2023, 6, 14));
      expect(DateTimeRepeat.week.previous(baseDate), DateTime(2023, 6, 8));
      expect(DateTimeRepeat.month.previous(baseDate), DateTime(2023, 5, 15));
      expect(DateTimeRepeat.year.previous(baseDate), DateTime(2022, 6, 15));
    });

    test('next_должен_корректно_вычислять_следующую_дату', () {
      // Arrange
      final baseDate = DateTime(2023, 6, 15); // 15 июня 2023

      // Act & Assert
      expect(DateTimeRepeat.noRepeat.next(baseDate), baseDate);
      expect(DateTimeRepeat.day.next(baseDate), DateTime(2023, 6, 16));
      expect(DateTimeRepeat.week.next(baseDate), DateTime(2023, 6, 22));
      expect(DateTimeRepeat.month.next(baseDate), DateTime(2023, 7, 15));
      expect(DateTimeRepeat.year.next(baseDate), DateTime(2024, 6, 15));
    });
  });
}
