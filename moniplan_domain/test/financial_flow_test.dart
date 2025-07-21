// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:test/test.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

void main() {
  group('Financial Flow Tests', () {
    late FinancialFlowRepository repository;
    late FinancialFlowCalculationService calculationService;
    late ManageFinancialFlowProfilesUseCase manageProfilesUseCase;
    late CalculateFinancialFlowUseCase calculateFlowUseCase;

    setUp(() {
      repository = InMemoryFinancialFlowRepository();
      calculationService = FinancialFlowCalculationServiceImpl();
      manageProfilesUseCase = ManageFinancialFlowProfilesUseCase(repository);
      calculateFlowUseCase = CalculateFinancialFlowUseCase(
        repository,
        calculationService,
      );
    });

    test('создание профиля финансового потока', () async {
      // Arrange
      final profile = await manageProfilesUseCase.createProfile(
        name: 'Тестовый профиль',
        description: 'Профиль для тестирования',
        defaultCurrency: _createTestCurrency(),
      );

      // Act & Assert
      expect(profile.name, equals('Тестовый профиль'));
      expect(profile.description, equals('Профиль для тестирования'));
      expect(profile.instruments.isEmpty, isTrue);
      expect(profile.isActive, isTrue);
      expect(profile.createdAt, isNotNull);
    });

    test('добавление финансовых инструментов в профиль', () async {
      // Arrange
      final profile = await manageProfilesUseCase.createProfile(
        name: 'Тестовый профиль',
        description: 'Профиль для тестирования',
        defaultCurrency: _createTestCurrency(),
      );

      final incomeInstrument = FinancialInstrument(
        id: 'income_1',
        name: 'Зарплата',
        type: FinancialInstrumentType.regularIncome,
        currency: _createTestCurrency(),
        amount: 100000,
        repeat: DateTimeRepeat.noRepeat,
      );

      final expenseInstrument = FinancialInstrument(
        id: 'expense_1',
        name: 'Аренда',
        type: FinancialInstrumentType.regularExpense,
        currency: _createTestCurrency(),
        amount: 50000,
        repeat: DateTimeRepeat.noRepeat,
      );

      // Act
      var updatedProfile = await manageProfilesUseCase.addInstrumentToProfile(
        profile.id,
        incomeInstrument,
      );

      updatedProfile = await manageProfilesUseCase.addInstrumentToProfile(
        profile.id,
        expenseInstrument,
      );

      // Assert
      expect(updatedProfile.instruments.length, equals(2));
      expect(updatedProfile.incomes.length, equals(1));
      expect(updatedProfile.expenses.length, equals(1));
      expect(updatedProfile.incomes.first.name, equals('Зарплата'));
      expect(updatedProfile.expenses.first.name, equals('Аренда'));
    });

    test('создание кредитного инструмента', () async {
      // Arrange
      final creditInstrument = FinancialInstrument(
        id: 'credit_1',
        name: 'Ипотека',
        type: FinancialInstrumentType.creditPayment,
        currency: _createTestCurrency(),
        amount: 0,
        repeat: DateTimeRepeat.noRepeat,
        creditData: const CreditData(
          totalAmount: 3000000,
          monthlyPayment: 35000,
          interestRate: 12.5,
          termMonths: 240,
          remainingAmount: 2800000,
          creditType: CreditType.annuity,
        ),
      );

      // Act & Assert
      expect(creditInstrument.type.isCredit, isTrue);
      expect(creditInstrument.creditData, isNotNull);
      expect(creditInstrument.creditData!.totalAmount, equals(3000000));
      expect(creditInstrument.creditData!.monthlyPayment, equals(35000));
      expect(
        creditInstrument.monthlyAmount,
        equals(-35000),
      ); // Отрицательное значение для расходов
    });

    test('расчет простого финансового потока', () async {
      // Arrange
      final profile = await manageProfilesUseCase.createProfile(
        name: 'Простой профиль',
        description: 'Профиль для простого расчета',
        defaultCurrency: _createTestCurrency(),
        calculationPeriod: CalculationPeriod.currentMonth(),
      );

      // Добавляем доход
      await manageProfilesUseCase.addInstrumentToProfile(
        profile.id,
        FinancialInstrument(
          id: 'income_1',
          name: 'Зарплата',
          type: FinancialInstrumentType.regularIncome,
          currency: _createTestCurrency(),
          amount: 150000,
          repeat: DateTimeRepeat.noRepeat,
        ),
      );

      // Добавляем расход
      await manageProfilesUseCase.addInstrumentToProfile(
        profile.id,
        FinancialInstrument(
          id: 'expense_1',
          name: 'Аренда',
          type: FinancialInstrumentType.regularExpense,
          currency: _createTestCurrency(),
          amount: 50000,
          repeat: DateTimeRepeat.noRepeat,
        ),
      );

      // Act
      final calculation = await calculateFlowUseCase.calculateFlow(profile.id);

      // Assert
      expect(calculation.status, equals(CalculationStatus.completed));
      expect(calculation.errors.isEmpty, isTrue);
      expect(calculation.periodResults.isNotEmpty, isTrue);
      expect(calculation.summary.totalIncome, greaterThan(0));
      expect(calculation.summary.totalExpenses, greaterThan(0));
      expect(
        calculation.summary.totalNetFlow,
        greaterThan(0),
      ); // Доходы больше расходов
    });

    test('валидация профиля с ошибками', () async {
      // Arrange
      final emptyProfile = FinancialFlowProfile(
        id: 'empty_1',
        name: 'Пустой профиль', // Даем имя профилю
        calculationPeriod: CalculationPeriod(
          startDate: DateTime(2025, 2, 1),
          endDate: DateTime(
            2025,
            1,
            1,
          ), // Неправильные даты - конец раньше начала
        ),
        defaultCurrency: _createTestCurrency(),
        instruments: [], // Пустой список инструментов
      );

      // Act
      final errors = calculationService.validateProfile(emptyProfile);

      // Assert
      expect(errors.isNotEmpty, isTrue);
      expect(errors.length, equals(2)); // Должно быть 2 ошибки
      expect(errors.any((error) => error.contains('инструмент')), isTrue);
      expect(
        errors.any((error) => error.contains('дата') || error.contains('Дата')),
        isTrue,
      );
    });

    test('расчет периода с инактивными инструментами', () async {
      // Arrange
      final profile = await manageProfilesUseCase.createProfile(
        name: 'Профиль с инактивными инструментами',
        description: 'Тест инактивных инструментов',
        defaultCurrency: _createTestCurrency(),
      );

      // Добавляем активный инструмент
      await manageProfilesUseCase.addInstrumentToProfile(
        profile.id,
        FinancialInstrument(
          id: 'active_1',
          name: 'Активный доход',
          type: FinancialInstrumentType.regularIncome,
          currency: _createTestCurrency(),
          amount: 100000,
          repeat: DateTimeRepeat.noRepeat,
          isActive: true,
        ),
      );

      // Добавляем неактивный инструмент
      await manageProfilesUseCase.addInstrumentToProfile(
        profile.id,
        FinancialInstrument(
          id: 'inactive_1',
          name: 'Неактивный доход',
          type: FinancialInstrumentType.regularIncome,
          currency: _createTestCurrency(),
          amount: 200000,
          repeat: DateTimeRepeat.noRepeat,
          isActive: false, // Неактивный
        ),
      );

      // Act
      final period = CalculationPeriod.currentMonth();
      final result = await calculateFlowUseCase.calculatePeriod(
        profile.id,
        period,
      );

      // Assert
      expect(
        result.instrumentResults.length,
        equals(1),
      ); // Только активный инструмент
      expect(
        result.instrumentResults.first.instrumentName,
        equals('Активный доход'),
      );
      expect(
        result.totalIncome,
        equals(100000),
      ); // Только от активного инструмента
    });
  });
}

/// Создает тестовую валюту
CurrencyData _createTestCurrency() {
  return CurrencyDataCommon.rub; // Используем российский рубль
}
