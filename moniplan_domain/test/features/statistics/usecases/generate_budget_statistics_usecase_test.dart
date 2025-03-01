import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

// Тестовый репозиторий, который соответствует принципам классического тестирования
class TestPlannerRepo implements IPlannerRepo {
  final Planner? planner;
  final List<Payment> payments;

  TestPlannerRepo({this.planner, this.payments = const []});

  @override
  Future<Planner?> getPlannerById(String id, {bool withActualInfo = true}) async {
    if (planner?.id == id) {
      return planner;
    }
    return null;
  }

  @override
  Future<List<Payment>> getPaymentsByPlannerId({required String plannerId}) async {
    if (planner?.id == plannerId) {
      return payments;
    }
    return [];
  }

  // Реализация остальных методов интерфейса
  @override
  Future<List<Planner>> getPlanners({
    bool withActualInfo = false,
    bool withPayments = false,
  }) async => [if (planner != null) planner!];

  @override
  Future<Planner?> savePlanner(Planner planner) async => planner;

  @override
  Future<Payment?> savePayment({
    bool allowCreate = true,
    required Payment payment,
    required String plannerId,
  }) async => payment;

  @override
  Future<void> deletePayment({required String paymentId, required String plannerId}) async {}

  @override
  Future<void> deletePlanner(String id) async {}

  @override
  Future<void> updatePaymentStatus({required String id, required bool isDone}) async {}

  @override
  Future<void> updatePaymentEnabled({required String id, required bool isEnabled}) async {}

  @override
  Future<Payment?> getPaymentById({required String paymentId, required String plannerId}) async {
    return payments.firstWhere((p) => p.paymentId == paymentId, orElse: () => null as Payment);
  }

  @override
  Future<PlannerActualInfo?> getPlannerActualInfo({required String plannerId}) async => null;

  @override
  Future<PlannerActualInfo?> updatePlannerActualInfo({
    required PlannerActualInfo plannerActualInfo,
    required String plannerId,
  }) async => null;

  @override
  Future<Payment?> fixateRepeatedPayment({
    required String paymentId,
    required String plannerId,
  }) async => null;
}

void main() {
  group('GenerateBudgetStatisticsUseCase', () {
    // Фабричные методы для создания тестовых данных
    Planner createPlanner({
      String id = 'test-planner-id',
      DateTime? dateStart,
      DateTime? dateEnd,
      num initialBudget = 1000,
    }) {
      return Planner(
        id: id,
        name: 'Test Planner',
        dateStart: dateStart ?? DateTime(2023, 1, 1),
        dateEnd: dateEnd ?? DateTime(2023, 1, 31),
        initialBudget: initialBudget,
        isGenerationAllowed: true,
      );
    }

    Payment createPayment({
      required String id,
      required DateTime date,
      required PaymentType type,
      required num money,
      bool isEnabled = true,
      bool isDone = false,
    }) {
      final details = PaymentDetails(
        name: 'Test Payment',
        type: type,
        money: money,
        currency: CurrencyData.create('RUB', 2, symbol: '₽'),
      );

      return Payment(
        paymentId: id,
        details: details,
        date: date,
        isEnabled: isEnabled,
        isDone: isDone,
        plannerId: 'test-planner-id',
        repeat: DateTimeRepeat.noRepeat,
      );
    }

    test('генерация_статистики_с_доходами_и_расходами', () async {
      // Arrange
      final planner = createPlanner();
      final payments = [
        createPayment(
          id: 'payment-1',
          date: DateTime(2023, 1, 5),
          type: PaymentType.income,
          money: 500,
        ),
        createPayment(
          id: 'payment-2',
          date: DateTime(2023, 1, 10),
          type: PaymentType.expense,
          money: -300,
        ),
        createPayment(
          id: 'payment-3',
          date: DateTime(2023, 1, 15),
          type: PaymentType.income,
          money: 700,
        ),
      ];

      final repo = TestPlannerRepo(planner: planner, payments: payments);
      final sut = GenerateBudgetStatisticsUseCase(plannerRepo: repo, plannerId: planner.id);

      // Act
      final result = await sut.run();

      // Assert
      expect(result.totalBudget.length, 3);
      expect(result.incomes.length, 2);
      expect(result.expenses.length, 1);

      // Проверяем, что даты соответствуют датам платежей
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 5).dayBound), isTrue);
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 10).dayBound), isTrue);
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 15).dayBound), isTrue);

      // Проверяем суммы
      final day5 = DateTime(2023, 1, 5).dayBound;
      final day10 = DateTime(2023, 1, 10).dayBound;
      final day15 = DateTime(2023, 1, 15).dayBound;

      expect(result.incomes[day5], 500);
      expect(result.expenses[day10], 300);
      expect(result.incomes[day15], 700);

      // Проверяем накопительный итог
      expect(result.totalBudget[day5]?.totalBudget, 1000 + 500);
      expect(result.totalBudget[day10]?.totalBudget, 1000 + 500 - 300);
      expect(result.totalBudget[day15]?.totalBudget, 1000 + 500 - 300 + 700);
    });

    test('генерация_статистики_с_ограничением_периода', () async {
      // Arrange
      final planner = createPlanner(
        dateStart: DateTime(2023, 1, 1),
        dateEnd: DateTime(2023, 1, 31),
      );

      final payments = [
        createPayment(
          id: 'payment-1',
          date: DateTime(2023, 1, 5),
          type: PaymentType.income,
          money: 500,
        ),
        createPayment(
          id: 'payment-2',
          date: DateTime(2023, 1, 15),
          type: PaymentType.expense,
          money: -300,
        ),
        createPayment(
          id: 'payment-3',
          date: DateTime(2023, 1, 25),
          type: PaymentType.income,
          money: 700,
        ),
      ];

      final repo = TestPlannerRepo(planner: planner, payments: payments);
      final sut = GenerateBudgetStatisticsUseCase(
        plannerRepo: repo,
        plannerId: planner.id,
        dateStart: DateTime(2023, 1, 10),
        dateEnd: DateTime(2023, 1, 20),
      );

      // Act
      final result = await sut.run();

      // Assert
      expect(result.totalBudget.length, 1);
      expect(result.incomes.length, 0);
      expect(result.expenses.length, 1);

      // Проверяем, что в результате только платежи в указанном периоде
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 5).dayBound), isFalse);
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 15).dayBound), isTrue);
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 25).dayBound), isFalse);
    });

    test('генерация_статистики_с_отключенными_платежами', () async {
      // Arrange
      final planner = createPlanner();
      final payments = [
        createPayment(
          id: 'payment-1',
          date: DateTime(2023, 1, 5),
          type: PaymentType.income,
          money: 500,
          isEnabled: false, // Отключенный платеж
        ),
        createPayment(
          id: 'payment-2',
          date: DateTime(2023, 1, 10),
          type: PaymentType.expense,
          money: -300,
          isEnabled: true,
        ),
      ];

      final repo = TestPlannerRepo(planner: planner, payments: payments);
      final sut = GenerateBudgetStatisticsUseCase(plannerRepo: repo, plannerId: planner.id);

      // Act
      final result = await sut.run();

      // Assert
      expect(result.totalBudget.length, 1);
      expect(result.incomes.length, 0);
      expect(result.expenses.length, 1);

      // Проверяем, что отключенный платеж не учитывается
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 5).dayBound), isFalse);
      expect(result.totalBudget.keys.contains(DateTime(2023, 1, 10).dayBound), isTrue);
    });

    test('генерация_статистики_с_выполненными_платежами', () async {
      // Arrange
      final planner = createPlanner();
      final payments = [
        createPayment(
          id: 'payment-1',
          date: DateTime(2023, 1, 5),
          type: PaymentType.income,
          money: 500,
          isDone: true,
        ),
        createPayment(
          id: 'payment-2',
          date: DateTime(2023, 1, 5),
          type: PaymentType.expense,
          money: -300,
          isDone: false,
        ),
      ];

      final repo = TestPlannerRepo(planner: planner, payments: payments);
      final sut = GenerateBudgetStatisticsUseCase(plannerRepo: repo, plannerId: planner.id);

      // Act
      final result = await sut.run();

      // Assert
      final day5 = DateTime(2023, 1, 5).dayBound;
      expect(result.totalBudget[day5]?.allCompleted, isFalse);

      // Теперь проверим случай, когда все платежи выполнены
      final paymentsAllDone = [
        createPayment(
          id: 'payment-1',
          date: DateTime(2023, 1, 5),
          type: PaymentType.income,
          money: 500,
          isDone: true,
        ),
        createPayment(
          id: 'payment-2',
          date: DateTime(2023, 1, 5),
          type: PaymentType.expense,
          money: -300,
          isDone: true,
        ),
      ];

      final repoAllDone = TestPlannerRepo(planner: planner, payments: paymentsAllDone);
      final sutAllDone = GenerateBudgetStatisticsUseCase(
        plannerRepo: repoAllDone,
        plannerId: planner.id,
      );

      final resultAllDone = await sutAllDone.run();
      expect(resultAllDone.totalBudget[day5]?.allCompleted, isTrue);
    });

    test('генерация_пустой_статистики_при_отсутствии_платежей', () async {
      // Arrange
      final planner = createPlanner();
      final repo = TestPlannerRepo(planner: planner, payments: []);
      final sut = GenerateBudgetStatisticsUseCase(plannerRepo: repo, plannerId: planner.id);

      // Act
      final result = await sut.run();

      // Assert
      expect(result.isEmpty, isTrue);
      expect(result.totalBudget, isEmpty);
      expect(result.incomes, isEmpty);
      expect(result.expenses, isEmpty);
    });

    test('выброс_исключения_при_отсутствии_планировщика', () async {
      // Arrange
      final repo = TestPlannerRepo(planner: null);
      final sut = GenerateBudgetStatisticsUseCase(plannerRepo: repo, plannerId: 'non-existent-id');

      // Act & Assert
      expect(() => sut.run(), throwsException);
    });
  });
}
