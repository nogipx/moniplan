// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'dart:developer' as dev;

import 'package:uuid/uuid.dart';

import '../_index.dart';

/// Анализатор для выявления аномалий в финансовых данных
final class AnomalyAnalyzer extends RetrospectiveAnalyzer {
  final _uuid = Uuid();

  AnomalyAnalyzer(super.source);

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) {
    final operations = availableOperations;
    final insights = <Insight>[];

    // Фильтруем только расходы
    final expenses = operations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (expenses.isEmpty) {
      return AnalysisResult.empty();
    }

    // 1. Выявление необычно крупных платежей (выбросов)
    insights.addAll(_detectAmountAnomalies(expenses));

    // 2. Выявление необычных категорий расходов
    insights.addAll(_detectCategoryAnomalies(expenses));

    // Все аномалии относятся к ретроспективному анализу
    return AnalysisResult(
      insights: InsightUtils.setTimeframeForAll(insights, InsightTimeframe.retrospective),
      analysisData: analysisData ?? {},
    );
  }

  /// Выявляет аномалии в суммах платежей
  List<Insight> _detectAmountAnomalies(List<IFinancialData> expenses) {
    final insights = <Insight>[];

    // Если платежей слишком мало, не выявляем аномалии
    if (expenses.length < 3) {
      return insights;
    }

    // Рассчитываем среднее и стандартное отклонение
    final amounts = expenses.map((e) => e.amount.toDouble()).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final variance = amounts.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / amounts.length;
    final stdDev = sqrt(variance);

    // Определяем порог для аномалий (2 стандартных отклонения от среднего)
    final threshold = mean + 2 * stdDev;

    // Находим платежи, превышающие порог
    final anomalies = expenses.where((e) => e.amount > threshold).toList();

    // Если найдены аномалии, создаем инсайт
    if (anomalies.isNotEmpty) {
      // Сортируем аномалии по убыванию суммы
      anomalies.sort((a, b) => b.amount.compareTo(a.amount));

      // Получаем оригинальные платежи с помощью сервиса
      final relatedPayments = PaymentExtractionService.extractPayments(anomalies);

      // Формируем описание аномалий
      final anomalyCount = anomalies.length;
      final totalAmount = anomalies.fold<double>(0, (sum, e) => sum + e.amount.toDouble());
      final percentOfTotal =
          (totalAmount / expenses.fold<double>(0, (sum, e) => sum + e.amount.toDouble()) * 100)
              .round();

      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Обнаружены необычно крупные расходы',
          description:
              'Я выявил $anomalyCount ${_pluralize(anomalyCount, 'необычно крупный расход', 'необычно крупных расхода', 'необычно крупных расходов')} '
              'на общую сумму ${InsightUtils.currencyFormat.format(totalAmount)}. '
              'Это составляет $percentOfTotal% от всех твоих расходов за период. '
              'Возможно, стоит проверить эти платежи.',
          type: InsightType.pattern,
          importance: percentOfTotal > 30 ? InsightImportance.high : InsightImportance.medium,
          relatedPayments: relatedPayments,
          additionalData: {
            'anomalyCount': anomalyCount,
            'totalAmount': totalAmount,
            'percentOfTotal': percentOfTotal,
            'threshold': threshold,
            'mean': mean,
            'stdDev': stdDev,
          },
        ),
      );
    }

    return insights;
  }

  /// Выявляет аномалии в категориях расходов
  List<Insight> _detectCategoryAnomalies(List<IFinancialData> expenses) {
    final insights = <Insight>[];

    // Если платежей слишком мало, не выявляем аномалии
    if (expenses.length < 5) {
      return insights;
    }

    // Группируем расходы по категориям
    final expensesByCategory = <String, List<IFinancialData>>{};
    for (final expense in expenses) {
      final category = expense.category.isNotEmpty ? expense.category : 'Без категории';
      expensesByCategory[category] = [...(expensesByCategory[category] ?? []), expense];
    }

    // Находим редкие категории (менее 5% от общего числа платежей)
    final rareCategories =
        expensesByCategory.entries
            .where((e) => e.value.length < expenses.length * 0.05 && e.value.length <= 2)
            .toList();

    // Если найдены редкие категории, создаем инсайт
    if (rareCategories.isNotEmpty) {
      // Собираем все платежи из редких категорий
      final rareCategoryPayments = <IFinancialData>[];
      for (final entry in rareCategories) {
        rareCategoryPayments.addAll(entry.value);
      }

      // Получаем оригинальные платежи с помощью сервиса
      final relatedPayments = PaymentExtractionService.extractPayments(rareCategoryPayments);

      // Формируем описание редких категорий
      final categoryCount = rareCategories.length;
      final paymentCount = rareCategoryPayments.length;
      final totalAmount = rareCategoryPayments.fold<double>(
        0,
        (sum, e) => sum + e.amount.toDouble(),
      );

      // Формируем список категорий для отображения
      final categoryNames = rareCategories.map((e) => '"${e.key}"').take(3).join(', ');
      final additionalCount = categoryCount > 3 ? ' и еще ${categoryCount - 3}' : '';

      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Необычные категории расходов',
          description:
              'Я обнаружил $paymentCount ${_pluralize(paymentCount, 'платеж', 'платежа', 'платежей')} '
              'в редко используемых категориях: $categoryNames$additionalCount. '
              'Общая сумма этих расходов: ${InsightUtils.currencyFormat.format(totalAmount)}. '
              'Возможно, стоит проверить эти платежи или объединить редкие категории.',
          type: InsightType.pattern,
          importance: InsightImportance.low,
          relatedPayments: relatedPayments,
          additionalData: {
            'categoryCount': categoryCount,
            'paymentCount': paymentCount,
            'totalAmount': totalAmount,
            'categories':
                rareCategories
                    .map(
                      (e) => {
                        'category': e.key,
                        'count': e.value.length,
                        'totalAmount': e.value.fold<num>(0, (sum, op) => sum + op.amount),
                      },
                    )
                    .toList(),
          },
        ),
      );
    }

    return insights;
  }

  /// Возвращает правильную форму слова в зависимости от числа
  String _pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) {
      return one;
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return few;
    } else {
      return many;
    }
  }
}
