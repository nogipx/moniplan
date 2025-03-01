import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('Payment', () {
    // Фабричные методы для создания тестовых данных
    PaymentDetails createIncomeDetails() {
      return PaymentDetails(
        name: 'Income',
        type: PaymentType.income,
        money: 1000,
        currency: CurrencyData.create('RUB', 2, symbol: '₽'),
      );
    }
    
    PaymentDetails createExpenseDetails() {
      return PaymentDetails(
        name: 'Expense',
        type: PaymentType.expense,
        money: 500,
        currency: CurrencyData.create('RUB', 2, symbol: '₽'),
      );
    }
    
    DateTime createTestDate() {
      return DateTime(2023, 6, 15);
    }
    
    Payment createPayment({
      required String paymentId,
      required PaymentDetails details,
      required DateTime date,
      String originalPaymentId = '',
      DateTimeRepeat repeat = DateTimeRepeat.noRepeat,
      bool isEnabled = true,
      bool isDone = false,
    }) {
      return Payment(
        paymentId: paymentId,
        details: details,
        date: date,
        originalPaymentId: originalPaymentId,
        repeat: repeat,
        isEnabled: isEnabled,
        isDone: isDone,
      );
    }
    
    test('создание_с_базовыми_параметрами', () {
      // Arrange
      final sut = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
      );
      
      // Assert
      expect(sut.paymentId, '1');
      expect(sut.details.name, 'Income');
      expect(sut.details.type, PaymentType.income);
      expect(sut.details.money, 1000);
      expect(sut.date, createTestDate());
      expect(sut.isEnabled, isTrue);
      expect(sut.isDone, isFalse);
      expect(sut.plannerId, '');
      expect(sut.repeat, DateTimeRepeat.noRepeat);
    });
    
    test('определение_типа_платежа', () {
      // Arrange
      final incomePayment = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
      );
      
      final expensePayment = createPayment(
        paymentId: '2',
        details: createExpenseDetails(),
        date: createTestDate(),
      );
      
      // Assert
      expect(incomePayment.type, PaymentType.income);
      expect(expensePayment.type, PaymentType.expense);
    });
    
    test('определение_родительского_платежа', () {
      // Arrange
      final parentPayment = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
      );
      
      final childPayment = createPayment(
        paymentId: '2',
        details: createIncomeDetails(),
        date: createTestDate(),
        originalPaymentId: '1',
      );
      
      final emptyOriginalIdPayment = createPayment(
        paymentId: '3',
        details: createIncomeDetails(),
        date: createTestDate(),
        originalPaymentId: '',
      );
      
      // Assert
      expect(parentPayment.isParent, isTrue);
      expect(parentPayment.isNotParent, isFalse);
      
      expect(childPayment.isParent, isFalse);
      expect(childPayment.isNotParent, isTrue);
      
      expect(emptyOriginalIdPayment.isParent, isTrue);
      expect(emptyOriginalIdPayment.isNotParent, isFalse);
    });
    
    test('определение_повторяющегося_платежа', () {
      // Arrange
      final nonRepeatPayment = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
        repeat: DateTimeRepeat.noRepeat,
      );
      
      final repeatPayment = createPayment(
        paymentId: '2',
        details: createIncomeDetails(),
        date: createTestDate(),
        repeat: DateTimeRepeat.month,
      );
      
      // Assert
      expect(nonRepeatPayment.isRepeat, isFalse);
      expect(repeatPayment.isRepeat, isTrue);
    });
    
    test('определение_родительского_повторяющегося_платежа', () {
      // Arrange
      final parentRepeatPayment = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
        repeat: DateTimeRepeat.month,
      );
      
      final childRepeatPayment = createPayment(
        paymentId: '2',
        details: createIncomeDetails(),
        date: createTestDate(),
        repeat: DateTimeRepeat.month,
        originalPaymentId: '1',
      );
      
      final nonRepeatPayment = createPayment(
        paymentId: '3',
        details: createIncomeDetails(),
        date: createTestDate(),
        repeat: DateTimeRepeat.noRepeat,
      );
      
      // Assert
      expect(parentRepeatPayment.isRepeatParent, isTrue);
      expect(childRepeatPayment.isRepeatParent, isFalse);
      expect(nonRepeatPayment.isRepeatParent, isFalse);
    });
    
    test('вычисление_нормализованной_суммы', () {
      // Arrange
      final incomePayment = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
      );
      
      final expensePayment = createPayment(
        paymentId: '2',
        details: createExpenseDetails(),
        date: createTestDate(),
      );
      
      // Assert
      expect(incomePayment.normalizedMoney, 1000);
      expect(expensePayment.normalizedMoney, -500);
    });
    
    test('сравнение_платежей_с_помощью_equatable', () {
      // Arrange
      final payment1 = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
      );
      
      final payment2 = createPayment(
        paymentId: '1',
        details: createIncomeDetails(),
        date: createTestDate(),
      );
      
      final payment3 = createPayment(
        paymentId: '2',
        details: createIncomeDetails(),
        date: createTestDate(),
      );
      
      // Assert
      expect(payment1 == payment2, isTrue);
      expect(payment1 == payment3, isFalse);
    });
  });
} 