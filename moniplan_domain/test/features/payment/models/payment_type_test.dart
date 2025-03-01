import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('PaymentType', () {
    test('значения_модификаторов', () {
      // Arrange
      final sut = PaymentType.values;
      
      // Assert
      expect(sut.firstWhere((type) => type == PaymentType.unknown).modifier, -100);
      expect(sut.firstWhere((type) => type == PaymentType.income).modifier, 1);
      expect(sut.firstWhere((type) => type == PaymentType.expense).modifier, -1);
    });

    test('значения_id', () {
      // Arrange
      final sut = PaymentType.values;
      
      // Assert
      expect(sut.firstWhere((type) => type == PaymentType.unknown).id, 0);
      expect(sut.firstWhere((type) => type == PaymentType.income).id, 1);
      expect(sut.firstWhere((type) => type == PaymentType.expense).id, 2);
    });

    test('создание_экземпляра_из_id', () {
      // Arrange
      final validIds = [0, 1, 2];
      final invalidId = 999;
      final nullId = null;
      
      // Act & Assert
      expect(PaymentType.from(validIds[0]), PaymentType.unknown);
      expect(PaymentType.from(validIds[1]), PaymentType.income);
      expect(PaymentType.from(validIds[2]), PaymentType.expense);
      
      // Несуществующий id должен возвращать unknown
      expect(PaymentType.from(invalidId), PaymentType.unknown);
      expect(PaymentType.from(nullId), PaymentType.unknown);
    });
  });
} 