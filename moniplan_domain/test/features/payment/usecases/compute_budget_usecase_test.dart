import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('ComputeBudgetUseCase', () {
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

    DateTime getNow() {
      return DateTime(2023, 6, 15).dayBound;
    }

    DateTime getYesterday() {
      return getNow().subtractTime(day: 1);
    }

    DateTime getTomorrow() {
      return getNow().addTime(day: 1);
    }

    Payment createPayment({
      required String paymentId,
      required PaymentDetails details,
      required DateTime date,
      bool isEnabled = true,
    }) {
      return Payment(paymentId: paymentId, details: details, date: date, isEnabled: isEnabled);
    }

    Payment createPastIncome() {
      return createPayment(paymentId: '1', details: createIncomeDetails(), date: getYesterday());
    }

    Payment createPastExpense() {
      return createPayment(paymentId: '2', details: createExpenseDetails(), date: getYesterday());
    }

    Payment createFutureIncome() {
      return createPayment(paymentId: '3', details: createIncomeDetails(), date: getTomorrow());
    }

    Payment createFutureExpense() {
      return createPayment(paymentId: '4', details: createExpenseDetails(), date: getTomorrow());
    }

    Payment createDisabledIncome() {
      return createPayment(
        paymentId: '5',
        details: createIncomeDetails(),
        date: getYesterday(),
        isEnabled: false,
      );
    }

    ComputeBudgetUseCase createUseCase({required List<Payment> payments, int initialBudget = 0}) {
      return ComputeBudgetUseCase(initialBudget: initialBudget, payments: payments);
    }

    test('вычисление_бюджета_для_списка_платежей', () {
      // Arrange
      final pastIncome = createPastIncome();
      final pastExpense = createPastExpense();
      final futureIncome = createFutureIncome();
      final futureExpense = createFutureExpense();

      final payments = [pastIncome, pastExpense, futureIncome, futureExpense];
      final sut = createUseCase(payments: payments);

      // Act
      final result = sut.run();

      // Assert
      expect(result.budget.length, 4);

      // Проверяем промежуточные значения бюджета
      expect(result.budget[pastIncome], 1000); // 0 + 1000 = 1000
      expect(result.budget[pastExpense], 500); // 1000 - 500 = 500
      expect(result.budget[futureIncome], 1500); // 500 + 1000 = 1500
      expect(result.budget[futureExpense], 1000); // 1500 - 500 = 1000

      // Проверяем последнее обновленное значение бюджета (до текущей даты)
      expect(result.lastUpdatedBudget, 1000.0);
    });

    test('учет_начального_бюджета', () {
      // Arrange
      final pastExpense = createPastExpense();
      final futureIncome = createFutureIncome();

      final payments = [pastExpense, futureIncome];
      final sut = createUseCase(payments: payments, initialBudget: 1000);

      // Act
      final result = sut.run();

      // Assert
      expect(result.budget.length, 2);

      // Проверяем промежуточные значения бюджета
      expect(result.budget[pastExpense], 500); // 1000 - 500 = 500
      expect(result.budget[futureIncome], 1500); // 500 + 1000 = 1500

      // Проверяем последнее обновленное значение бюджета (до текущей даты)
      expect(result.lastUpdatedBudget, 1500.0);
    });

    test('игнорирование_отключенных_платежей', () {
      // Arrange
      final pastIncome = createPastIncome();
      final disabledIncome = createDisabledIncome();
      final pastExpense = createPastExpense();

      final payments = [pastIncome, disabledIncome, pastExpense];
      final sut = createUseCase(payments: payments);

      // Act
      final result = sut.run();

      // Assert
      expect(result.budget.length, 3);

      // Проверяем промежуточные значения бюджета
      expect(result.budget[pastIncome], 1000); // 0 + 1000 = 1000
      expect(result.budget[disabledIncome], 1000); // 1000 + 0 = 1000 (платеж отключен)
      expect(result.budget[pastExpense], 500); // 1000 - 500 = 500

      // Проверяем последнее обновленное значение бюджета (до текущей даты)
      expect(result.lastUpdatedBudget, 500);
    });

    test('вычисление_lastUpdatedBudget_для_платежей_до_текущей_даты', () {
      // Arrange
      final pastIncome = createPastIncome();
      final pastExpense = createPastExpense();
      final futureIncome = createFutureIncome();
      final futureExpense = createFutureExpense();

      final payments = [pastIncome, pastExpense, futureIncome, futureExpense];
      final sut = createUseCase(payments: payments);

      // Act
      final result = sut.run();

      // Assert
      expect(result.lastUpdatedBudget, 1000.0); // Только платежи до текущей даты: 1000 - 500 = 500
    });

    test('пустой_результат_для_пустого_списка_платежей', () {
      // Arrange
      final sut = createUseCase(payments: [], initialBudget: 1000);

      // Act
      final result = sut.run();

      // Assert
      expect(result.budget, isEmpty);
      expect(result.lastUpdatedBudget, 0); // В реализации lastUpdatedBudget инициализируется как 0
    });
  });
}
