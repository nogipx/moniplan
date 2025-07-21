// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;

import 'package:moniplan_domain/src/features/financial_flow/financial_flow.dart';

/// Пример использования функциональности финансового потока
class FinancialFlowExample {
  late final FinancialFlowRepository _repository;
  late final FinancialFlowCalculationService _calculationService;
  late final ManageFinancialFlowProfilesUseCase _manageProfilesUseCase;
  late final CalculateFinancialFlowUseCase _calculateFlowUseCase;
  late final AnalyzeFinancialFlowUseCase _analyzeFlowUseCase;

  FinancialFlowExample() {
    _repository = InMemoryFinancialFlowRepository();
    _calculationService = FinancialFlowCalculationServiceImpl();
    _manageProfilesUseCase = ManageFinancialFlowProfilesUseCase(_repository);
    _calculateFlowUseCase = CalculateFinancialFlowUseCase(
      _repository,
      _calculationService,
    );
    _analyzeFlowUseCase = AnalyzeFinancialFlowUseCase(_repository);
  }

  /// Демонстрирует создание профиля с различными финансовыми инструментами
  Future<void> demonstrateBasicUsage() async {
    print('=== Демонстрация базового использования ===\n');

    // Создаем профиль
    final profile = await _manageProfilesUseCase.createProfile(
      name: 'Семейный бюджет',
      description: 'Основной семейный бюджет на 2025 год',
      defaultCurrency: _createRubleCurrency(),
      calculationPeriod: CalculationPeriod.forMonths(6), // 6 месяцев
      tags: {'семья', 'основной'},
    );

    print('Создан профиль: ${profile.name}');
    print('Период расчета: ${profile.calculationPeriod.monthsCount} месяцев\n');

    // Добавляем доходы
    await _addIncomeInstruments(profile.id);

    // Добавляем расходы
    await _addExpenseInstruments(profile.id);

    // Добавляем кредиты
    await _addCreditInstruments(profile.id);

    // Выполняем расчет
    print('Выполняем расчет финансового потока...');
    final calculation = await _calculateFlowUseCase.calculateFlow(profile.id);

    // Выводим результаты
    _printCalculationResults(calculation);

    // Анализируем результаты
    await _analyzeResults(profile.id);
  }

  /// Добавляет инструменты доходов
  Future<void> _addIncomeInstruments(String profileId) async {
    print('Добавляем доходы...');

    // Зарплата
    final salary = FinancialInstrument(
      id: 'salary_1',
      name: 'Зарплата (основная)',
      description: 'Основной доход от работы',
      type: FinancialInstrumentType.regularIncome,
      currency: _createRubleCurrency(),
      amount: 150000, // 150,000 рублей
      tags: {'работа', 'зарплата'},
      repeat: _createMonthlyRepeat(),
      startDate: DateTime(2025, 1, 1),
    );

    // Подработка
    final freelance = FinancialInstrument(
      id: 'freelance_1',
      name: 'Фриланс',
      description: 'Дополнительный доход от фриланса',
      type: FinancialInstrumentType.regularIncome,
      currency: _createRubleCurrency(),
      amount: 50000, // 50,000 рублей
      tags: {'фриланс', 'дополнительный доход'},
      repeat: _createMonthlyRepeat(),
      startDate: DateTime(2025, 1, 1),
    );

    // Разовый доход
    final bonus = FinancialInstrument(
      id: 'bonus_1',
      name: 'Премия',
      description: 'Годовая премия',
      type: FinancialInstrumentType.oneTimeIncome,
      currency: _createRubleCurrency(),
      amount: 100000, // 100,000 рублей
      tags: {'премия', 'работа'},
      startDate: DateTime(2025, 3, 1), // Март
    );

    await _manageProfilesUseCase.addInstrumentToProfile(profileId, salary);
    await _manageProfilesUseCase.addInstrumentToProfile(profileId, freelance);
    await _manageProfilesUseCase.addInstrumentToProfile(profileId, bonus);

    print('✓ Добавлены доходы\n');
  }

  /// Добавляет инструменты расходов
  Future<void> _addExpenseInstruments(String profileId) async {
    print('Добавляем расходы...');

    // Аренда жилья
    final rent = FinancialInstrument(
      id: 'rent_1',
      name: 'Аренда квартиры',
      description: 'Ежемесячная аренда жилья',
      type: FinancialInstrumentType.regularExpense,
      currency: _createRubleCurrency(),
      amount: 45000, // 45,000 рублей
      tags: {'жилье', 'аренда'},
      repeat: _createMonthlyRepeat(),
      startDate: DateTime(2025, 1, 1),
    );

    // Продукты
    final groceries = FinancialInstrument(
      id: 'groceries_1',
      name: 'Продукты питания',
      description: 'Еженедельные расходы на продукты',
      type: FinancialInstrumentType.regularExpense,
      currency: _createRubleCurrency(),
      amount: 8000, // 8,000 рублей в неделю ≈ 32,000 в месяц
      tags: {'еда', 'продукты'},
      repeat: _createWeeklyRepeat(),
      startDate: DateTime(2025, 1, 1),
    );

    // Коммунальные услуги
    final utilities = FinancialInstrument(
      id: 'utilities_1',
      name: 'Коммунальные услуги',
      description: 'Электричество, вода, интернет',
      type: FinancialInstrumentType.regularExpense,
      currency: _createRubleCurrency(),
      amount: 12000, // 12,000 рублей
      tags: {'коммунальные', 'дом'},
      repeat: _createMonthlyRepeat(),
      startDate: DateTime(2025, 1, 1),
    );

    // Транспорт
    final transport = FinancialInstrument(
      id: 'transport_1',
      name: 'Транспорт',
      description: 'Общественный транспорт и такси',
      type: FinancialInstrumentType.regularExpense,
      currency: _createRubleCurrency(),
      amount: 15000, // 15,000 рублей
      tags: {'транспорт'},
      repeat: _createMonthlyRepeat(),
      startDate: DateTime(2025, 1, 1),
    );

    await _manageProfilesUseCase.addInstrumentToProfile(profileId, rent);
    await _manageProfilesUseCase.addInstrumentToProfile(profileId, groceries);
    await _manageProfilesUseCase.addInstrumentToProfile(profileId, utilities);
    await _manageProfilesUseCase.addInstrumentToProfile(profileId, transport);

    print('✓ Добавлены расходы\n');
  }

  /// Добавляет кредитные инструменты
  Future<void> _addCreditInstruments(String profileId) async {
    print('Добавляем кредиты...');

    // Ипотека
    final mortgage = FinancialInstrument(
      id: 'mortgage_1',
      name: 'Ипотека',
      description: 'Кредит на покупку квартиры',
      type: FinancialInstrumentType.creditPayment,
      currency: _createRubleCurrency(),
      amount: 0, // Не используется для кредитов
      tags: {'кредит', 'ипотека', 'недвижимость'},
      repeat: _createMonthlyRepeat(),
      startDate: DateTime(2025, 1, 1),
      creditData: const CreditData(
        totalAmount: 3000000, // 3 млн рублей
        monthlyPayment: 35000, // 35,000 рублей в месяц
        interestRate: 12.5, // 12.5% годовых
        termMonths: 240, // 20 лет
        remainingAmount: 2800000, // Остаток 2.8 млн
        issueDate: null, // Дата выдачи не указана
        creditType: CreditType.annuity,
      ),
    );

    // Потребительский кредит
    final consumerCredit = FinancialInstrument(
      id: 'consumer_credit_1',
      name: 'Потребительский кредит',
      description: 'Кредит на покупку мебели',
      type: FinancialInstrumentType.creditPayment,
      currency: _createRubleCurrency(),
      amount: 0,
      tags: {'кредит', 'мебель'},
      repeat: _createMonthlyRepeat(),
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 12, 31), // Закрывается в конце года
      creditData: const CreditData(
        totalAmount: 200000, // 200,000 рублей
        monthlyPayment: 18000, // 18,000 рублей в месяц
        interestRate: 15.0, // 15% годовых
        termMonths: 12, // 1 год
        remainingAmount: 150000, // Остаток 150,000
        creditType: CreditType.annuity,
      ),
    );

    await _manageProfilesUseCase.addInstrumentToProfile(profileId, mortgage);
    await _manageProfilesUseCase.addInstrumentToProfile(
      profileId,
      consumerCredit,
    );

    print('✓ Добавлены кредиты\n');
  }

  /// Выводит результаты расчета
  void _printCalculationResults(FinancialFlowCalculation calculation) {
    print('\n=== РЕЗУЛЬТАТЫ РАСЧЕТА ===');
    print('Статус: ${calculation.status.displayName}');
    print('Время выполнения: ${calculation.executionTimeMs} мс');
    print('Количество периодов: ${calculation.periodResults.length}');

    final summary = calculation.summary;
    print('\n--- ОБЩИЕ ИТОГИ ---');
    print('Общий доход: ${_formatAmount(summary.totalIncome)} ₽');
    print('Общие расходы: ${_formatAmount(summary.totalExpenses)} ₽');
    print('Чистый поток: ${_formatAmount(summary.totalNetFlow)} ₽');
    print(
      'Средний месячный доход: ${_formatAmount(summary.averageMonthlyIncome)} ₽',
    );
    print(
      'Средние месячные расходы: ${_formatAmount(summary.averageMonthlyExpenses)} ₽',
    );
    print(
      'Средний месячный чистый поток: ${_formatAmount(summary.averageMonthlyNetFlow)} ₽',
    );

    if (summary.totalCreditPayments > 0) {
      print('\n--- КРЕДИТЫ ---');
      print(
        'Общие платежи по кредитам: ${_formatAmount(summary.totalCreditPayments)} ₽',
      );
      print(
        'Остаток задолженности: ${_formatAmount(summary.totalRemainingCreditBalance)} ₽',
      );
    }

    // Показываем первые несколько периодов как пример
    print('\n--- ДЕТАЛИЗАЦИЯ ПО ПЕРИОДАМ (первые 3) ---');
    for (int i = 0; i < math.min(3, calculation.periodResults.length); i++) {
      final period = calculation.periodResults[i];
      print(
        '\nПериод ${i + 1}: ${_formatDate(period.period.startDate)} - ${_formatDate(period.period.endDate)}',
      );
      print('  Доходы: ${_formatAmount(period.totalIncome)} ₽');
      print('  Расходы: ${_formatAmount(period.totalExpenses)} ₽');
      print('  Чистый поток: ${_formatAmount(period.netFlow)} ₽');

      if (period.categoryResults.isNotEmpty) {
        print('  Топ категории:');
        final sortedCategories =
            period.categoryResults.entries.toList()
              ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

        for (int j = 0; j < math.min(3, sortedCategories.length); j++) {
          final category = sortedCategories[j];
          print(
            '    ${category.key}: ${_formatAmount(category.value.abs())} ₽',
          );
        }
      }
    }
  }

  /// Анализирует результаты
  Future<void> _analyzeResults(String profileId) async {
    print('\n=== АНАЛИЗ РЕЗУЛЬТАТОВ ===');

    try {
      // Получаем топ категорий расходов
      final topCategories = await _analyzeFlowUseCase.getTopExpenseCategories(
        profileId,
        5,
      );

      if (topCategories.isNotEmpty) {
        print('\n--- ТОП КАТЕГОРИЙ РАСХОДОВ ---');
        for (int i = 0; i < topCategories.length; i++) {
          final category = topCategories[i];
          print(
            '${i + 1}. ${category.category}: ${_formatAmount(category.totalAmount)} ₽ (${category.percentage.toStringAsFixed(1)}%)',
          );
        }
      }

      // Получаем прогноз
      final forecast = await _analyzeFlowUseCase.getForecast(profileId, 3);

      print('\n--- ПРОГНОЗ НА ${forecast.forecastPeriodMonths} МЕСЯЦА ---');
      print(
        'Прогнозируемый доход: ${_formatAmount(forecast.projectedIncome)} ₽',
      );
      print(
        'Прогнозируемые расходы: ${_formatAmount(forecast.projectedExpenses)} ₽',
      );
      print(
        'Прогнозируемый чистый поток: ${_formatAmount(forecast.projectedNetFlow)} ₽',
      );
      print(
        'Уверенность прогноза: ${(forecast.confidence * 100).toStringAsFixed(1)}%',
      );

      if (forecast.assumptions.isNotEmpty) {
        print('\nДопущения прогноза:');
        for (final assumption in forecast.assumptions) {
          print('• $assumption');
        }
      }
    } catch (e) {
      print('Ошибка при анализе: $e');
    }
  }

  /// Создает валюту рубль
  dynamic _createRubleCurrency() {
    // Здесь должен быть реальный объект CurrencyData
    // Пока возвращаем заглушку
    return 'RUB';
  }

  /// Создает месячное повторение
  dynamic _createMonthlyRepeat() {
    // Здесь должен быть реальный объект DateTimeRepeat
    // Пока возвращаем заглушку
    return 'monthly';
  }

  /// Создает недельное повторение
  dynamic _createWeeklyRepeat() {
    // Здесь должен быть реальный объект DateTimeRepeat
    // Пока возвращаем заглушку
    return 'weekly';
  }

  /// Форматирует сумму для отображения
  String _formatAmount(num amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
  }

  /// Форматирует дату для отображения
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

/// Точка входа для запуска примера
Future<void> main() async {
  final example = FinancialFlowExample();
  await example.demonstrateBasicUsage();
}
