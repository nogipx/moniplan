import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('GroupPaymentsByDateUsecase', () {
    // Фабричные методы для создания тестовых данных
    PaymentDetails createPaymentDetails() {
      return PaymentDetails(
        name: 'Test Payment',
        type: PaymentType.expense,
        money: 100,
        currency: CurrencyData.create('RUB', 2, symbol: '₽'),
      );
    }
    
    DateTime createDate1() {
      return DateTime(2023, 6, 15); // 15 июня 2023
    }
    
    DateTime createDate2() {
      return DateTime(2023, 6, 15, 12, 30); // 15 июня 2023, 12:30
    }
    
    DateTime createDate3() {
      return DateTime(2023, 6, 16); // 16 июня 2023
    }
    
    DateTime createDate4() {
      return DateTime(2023, 6, 14); // 14 июня 2023
    }
    
    Payment createPayment({
      required String paymentId,
      required DateTime date,
    }) {
      return Payment(
        paymentId: paymentId,
        details: createPaymentDetails(),
        date: date,
      );
    }
    
    List<Payment> createTestPayments() {
      return [
        createPayment(paymentId: '1', date: createDate1()),
        createPayment(paymentId: '2', date: createDate2()),
        createPayment(paymentId: '3', date: createDate3()),
      ];
    }
    
    GroupPaymentsByDateUsecase createUseCase({
      required List<Payment> payments,
      DateTime? today,
    }) {
      return GroupPaymentsByDateUsecase(
        payments: payments,
        today: today,
      );
    }
    
    test('группировка_платежей_по_дате', () {
      // Arrange
      final payments = createTestPayments();
      final sut = createUseCase(payments: payments);
      
      // Act
      final result = sut.run();
      
      // Assert
      expect(result.length, 2); // Должно быть 2 группы (15 и 16 июня)
      
      // Проверяем первую группу (15 июня)
      expect(result[0].date, createDate1().dayBound);
      expect(result[0].payments.length, 2);
      expect(result[0].payments.any((p) => p.paymentId == '1'), isTrue);
      expect(result[0].payments.any((p) => p.paymentId == '2'), isTrue);
      
      // Проверяем вторую группу (16 июня)
      expect(result[1].date, createDate3().dayBound);
      expect(result[1].payments.length, 1);
      expect(result[1].payments.any((p) => p.paymentId == '3'), isTrue);
    });
    
    test('добавление_пустой_группы_для_текущей_даты', () {
      // Arrange
      final payments = createTestPayments();
      final today = DateTime(2023, 6, 17); // 17 июня 2023
      final sut = createUseCase(payments: payments, today: today);
      
      // Act
      final result = sut.run();
      
      // Assert
      expect(result.length, 3); // Должно быть 3 группы (15, 16 и 17 июня)
      
      // Проверяем третью группу (17 июня)
      expect(result[2].date, today.dayBound);
      expect(result[2].payments, isEmpty);
    });
    
    test('отсутствие_дублирования_текущей_даты', () {
      // Arrange
      final payments = createTestPayments();
      final today = DateTime(2023, 6, 15); // 15 июня 2023 (совпадает с date1)
      final sut = createUseCase(payments: payments, today: today);
      
      // Act
      final result = sut.run();
      
      // Assert
      expect(result.length, 2); // Должно быть 2 группы (15 и 16 июня)
      
      // Проверяем первую группу (15 июня)
      expect(result[0].date, createDate1().dayBound);
      expect(result[0].payments.length, 2);
    });
    
    test('пустой_список_платежей', () {
      // Arrange
      final sut = createUseCase(payments: []);
      
      // Act
      final result = sut.run();
      
      // Assert
      expect(result, isEmpty);
    });
    
    test('пустой_список_с_текущей_датой', () {
      // Arrange
      final today = DateTime(2023, 6, 15);
      final sut = createUseCase(payments: [], today: today);
      
      // Act
      final result = sut.run();
      
      // Assert
      expect(result.length, 1);
      expect(result[0].date, today.dayBound);
      expect(result[0].payments, isEmpty);
    });
    
    test('сортировка_групп_по_дате', () {
      // Arrange
      final payment4 = createPayment(paymentId: '4', date: createDate4());
      final payments = [
        createPayment(paymentId: '3', date: createDate3()),
        createPayment(paymentId: '1', date: createDate1()),
        payment4,
        createPayment(paymentId: '2', date: createDate2()),
      ];
      final sut = createUseCase(payments: payments);
      
      // Act
      final result = sut.run();
      
      // Assert
      expect(result.length, 3); // Должно быть 3 группы (14, 15 и 16 июня)
      
      // Проверяем порядок групп
      expect(result[0].date, createDate4().dayBound); // 14 июня
      expect(result[1].date, createDate1().dayBound); // 15 июня
      expect(result[2].date, createDate3().dayBound); // 16 июня
    });
  });
} 