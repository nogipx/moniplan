// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:collection/collection.dart';

import '../_index.dart';

/// Анализатор сезонных паттернов в финансовых данных
///
/// Использует алгоритмы анализа временных рядов для выявления
/// сезонных трендов в расходах и доходах
final class SeasonalPatternAnalyzer extends RetrospectiveAnalyzer {
  SeasonalPatternAnalyzer(super.source);

  @override
  AnalysisResult analyze({Map<String, dynamic>? analysisData}) {
    final operations = availableOperations;
    final insights = <Insight>[];

    // Нужно минимум 3 месяца данных для анализа сезонности
    if (operations.length < 30) {
      return AnalysisResult.empty();
    }

    // 1. Анализ месячных паттернов расходов
    // insights.addAll(_analyzeMonthlyPatterns(operations));

    // 2. Анализ недельных паттернов расходов
    insights.addAll(_analyzeWeeklyPatterns(operations));

    // 3. Анализ дневных паттернов расходов
    insights.addAll(_analyzeDailyPatterns(operations));

    // Все инсайты относятся к ретроспективному анализу
    return AnalysisResult(
      insights: InsightUtils.setTimeframeForAll(insights, InsightTimeframe.retrospective),
      analysisData: analysisData ?? {},
    );
  }

  /// Анализирует месячные паттерны расходов
  List<Insight> _analyzeMonthlyPatterns(List<IFinancialData> operations) {
    final insights = <Insight>[];

    // Фильтруем только расходы
    final expenses = operations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (expenses.isEmpty) {
      return insights;
    }

    // Группируем расходы по месяцам
    final expensesByMonth = <int, List<IFinancialData>>{};
    for (final expense in expenses) {
      final month = expense.date.month;
      expensesByMonth[month] = [...(expensesByMonth[month] ?? []), expense];
    }

    // Если данных недостаточно, возвращаем пустой список
    if (expensesByMonth.length < 3) {
      return insights;
    }

    // Рассчитываем суммы расходов по месяцам
    final monthlyTotals = <int, double>{};
    for (final entry in expensesByMonth.entries) {
      monthlyTotals[entry.key] = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );
    }

    // Находим месяц с максимальными расходами
    final maxMonth = monthlyTotals.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Находим месяц с минимальными расходами
    final minMonth = monthlyTotals.entries.reduce((a, b) => a.value < b.value ? a : b);

    // Рассчитываем среднее значение расходов по месяцам
    final avgMonthlyExpense = monthlyTotals.values.average;

    // Определяем месяцы с расходами выше среднего на 20%
    final highExpenseMonths =
        monthlyTotals.entries.where((entry) => entry.value > avgMonthlyExpense * 1.2).toList();

    // Если найдены месяцы с высокими расходами, создаем инсайт
    if (highExpenseMonths.isNotEmpty) {
      // Получаем названия месяцев
      final monthNames = [
        'январе',
        'феврале',
        'марте',
        'апреле',
        'мае',
        'июне',
        'июле',
        'августе',
        'сентябре',
        'октябре',
        'ноябре',
        'декабре',
      ];

      // Формируем список месяцев для отображения
      final highMonthsText = highExpenseMonths.map((e) => monthNames[e.key - 1]).join(', ');

      // Рассчитываем, насколько расходы в этих месяцах выше среднего
      final avgHighExpense = highExpenseMonths.map((e) => e.value).average;
      final percentAboveAvg = ((avgHighExpense / avgMonthlyExpense - 1) * 100).round();

      // Получаем платежи из месяцев с высокими расходами
      final highMonthPayments = <IFinancialData>[];
      for (final entry in highExpenseMonths) {
        highMonthPayments.addAll(expensesByMonth[entry.key] ?? []);
      }

      // Получаем оригинальные платежи с помощью сервиса
      final relatedPayments = PaymentExtractionService.extractPayments(highMonthPayments);

      insights.add(
        createInsight(
          title: 'Обнаружены сезонные пики расходов',
          description:
              'Я выявил сезонный паттерн в твоих расходах. В $highMonthsText твои расходы '
              'в среднем на $percentAboveAvg% выше, чем в другие месяцы. '
              'Это может быть связано с сезонными факторами, такими как отпуск, праздники или сезонные покупки. '
              'Планирование бюджета с учетом этих пиков поможет тебе лучше управлять финансами.',
          type: InsightType.pattern,
          importance: percentAboveAvg > 30 ? InsightImportance.high : InsightImportance.medium,
          relatedPayments: relatedPayments,
          additionalData: {
            'highExpenseMonths':
                highExpenseMonths
                    .map(
                      (e) => {
                        'month': e.key,
                        'monthName': monthNames[e.key - 1],
                        'total': e.value,
                        'percentAboveAvg': ((e.value / avgMonthlyExpense - 1) * 100).round(),
                      },
                    )
                    .toList(),
            'avgMonthlyExpense': avgMonthlyExpense,
            'maxMonth': {
              'month': maxMonth.key,
              'monthName': monthNames[maxMonth.key - 1],
              'total': maxMonth.value,
            },
            'minMonth': {
              'month': minMonth.key,
              'monthName': monthNames[minMonth.key - 1],
              'total': minMonth.value,
            },
          },
        ),
      );
    }

    return insights;
  }

  /// Анализирует недельные паттерны расходов
  List<Insight> _analyzeWeeklyPatterns(List<IFinancialData> operations) {
    final insights = <Insight>[];

    // Фильтруем только расходы
    final expenses = operations.where((op) => op.type == FinancialOperationType.expense).toList();

    if (expenses.isEmpty) {
      return insights;
    }

    // Группируем расходы по дням недели (1 = понедельник, 7 = воскресенье)
    final expensesByWeekday = <int, List<IFinancialData>>{};
    for (final expense in expenses) {
      // Преобразуем из DateTime.weekday (1-7) в наш формат (0-6)
      final weekday = expense.date.weekday;
      expensesByWeekday[weekday] = [...(expensesByWeekday[weekday] ?? []), expense];
    }

    // Если данных недостаточно, возвращаем пустой список
    if (expensesByWeekday.length < 5) {
      return insights;
    }

    // Рассчитываем средние расходы по дням недели
    final weekdayAverages = <int, double>{};
    for (final entry in expensesByWeekday.entries) {
      final totalAmount = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );
      // Делим на количество недель для получения среднего
      final weeksCount =
          entry.value
              .map((e) => '${e.date.year}-${e.date.month}-${(e.date.day / 7).floor()}')
              .toSet()
              .length;
      weekdayAverages[entry.key] = totalAmount / max(weeksCount, 1);
    }

    // Находим день с максимальными средними расходами
    final maxWeekday = weekdayAverages.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Находим день с минимальными средними расходами
    final minWeekday = weekdayAverages.entries.reduce((a, b) => a.value < b.value ? a : b);

    // Рассчитываем общее среднее значение расходов по дням недели
    final avgWeekdayExpense = weekdayAverages.values.average;

    // Если разница между максимальным и минимальным днем существенна
    if (maxWeekday.value > minWeekday.value * 1.5) {
      // Получаем названия дней недели
      final weekdayNames = [
        'понедельник',
        'вторник',
        'среду',
        'четверг',
        'пятницу',
        'субботу',
        'воскресенье',
      ];

      // Рассчитываем, насколько расходы в максимальный день выше среднего
      final percentAboveAvg = ((maxWeekday.value / avgWeekdayExpense - 1) * 100).round();

      // Получаем платежи из дня с максимальными расходами
      final maxDayPayments = expensesByWeekday[maxWeekday.key] ?? [];

      // Получаем оригинальные платежи с помощью сервиса
      final relatedPayments = PaymentExtractionService.extractPayments(maxDayPayments);

      insights.add(
        createInsight(
          title: 'Выявлен пик расходов по дням недели',
          description:
              'Я обнаружил, что в ${weekdayNames[maxWeekday.key - 1]} твои расходы '
              'в среднем на $percentAboveAvg% выше, чем в другие дни недели. '
              'В ${weekdayNames[minWeekday.key - 1]} ты тратишь меньше всего. '
              'Это может быть связано с регулярными активностями или привычками. '
              'Понимание этого паттерна поможет тебе лучше планировать недельный бюджет.',
          type: InsightType.pattern,
          importance: percentAboveAvg > 50 ? InsightImportance.medium : InsightImportance.low,
          relatedPayments: relatedPayments,
          additionalData: {
            'weekdayAverages':
                weekdayAverages.entries
                    .map(
                      (e) => {
                        'weekday': e.key,
                        'weekdayName': weekdayNames[e.key - 1],
                        'average': e.value,
                        'percentOfAvg': ((e.value / avgWeekdayExpense) * 100).round(),
                      },
                    )
                    .toList(),
            'avgWeekdayExpense': avgWeekdayExpense,
            'maxWeekday': {
              'weekday': maxWeekday.key,
              'weekdayName': weekdayNames[maxWeekday.key - 1],
              'average': maxWeekday.value,
            },
            'minWeekday': {
              'weekday': minWeekday.key,
              'weekdayName': weekdayNames[minWeekday.key - 1],
              'average': minWeekday.value,
            },
          },
        ),
      );
    }

    return insights;
  }

  /// Анализирует дневные паттерны расходов (по времени суток)
  List<Insight> _analyzeDailyPatterns(List<IFinancialData> operations) {
    final insights = <Insight>[];

    // Фильтруем только расходы с временем
    final expenses =
        operations
            .where(
              (op) =>
                  op.type == FinancialOperationType.expense &&
                  op.additionalData != null &&
                  op.additionalData!['time'] != null,
            )
            .toList();

    if (expenses.length < 20) {
      return insights;
    }

    // Определяем временные интервалы (утро, день, вечер, ночь)
    final timeIntervals = {
      'утро': (5, 11), // 5:00 - 11:59
      'день': (12, 17), // 12:00 - 17:59
      'вечер': (18, 22), // 18:00 - 22:59
      'ночь': (23, 4), // 23:00 - 4:59
    };

    // Группируем расходы по временным интервалам
    final expensesByTimeInterval = <String, List<IFinancialData>>{};

    for (final expense in expenses) {
      final time = expense.additionalData!['time'] as String?;
      if (time == null) continue;

      final hour = int.tryParse(time.split(':')[0]);
      if (hour == null) continue;

      String? interval;
      for (final entry in timeIntervals.entries) {
        final (start, end) = entry.value;
        if (start <= end) {
          if (hour >= start && hour <= end) {
            interval = entry.key;
            break;
          }
        } else {
          // Для ночного интервала (переход через полночь)
          if (hour >= start || hour <= end) {
            interval = entry.key;
            break;
          }
        }
      }

      if (interval != null) {
        expensesByTimeInterval[interval] = [...(expensesByTimeInterval[interval] ?? []), expense];
      }
    }

    // Если данных недостаточно, возвращаем пустой список
    if (expensesByTimeInterval.length < 3) {
      return insights;
    }

    // Рассчитываем суммы расходов по временным интервалам
    final intervalTotals = <String, double>{};
    for (final entry in expensesByTimeInterval.entries) {
      intervalTotals[entry.key] = entry.value.fold<double>(
        0,
        (sum, expense) => sum + expense.amount.toDouble(),
      );
    }

    // Находим интервал с максимальными расходами
    final maxInterval = intervalTotals.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Рассчитываем общую сумму расходов
    final totalExpenses = intervalTotals.values.sum;

    // Рассчитываем процент расходов в максимальном интервале
    final percentOfTotal = ((maxInterval.value / totalExpenses) * 100).round();

    // Если в одном интервале сконцентрировано более 40% расходов
    if (percentOfTotal > 40) {
      // Получаем платежи из интервала с максимальными расходами
      final maxIntervalPayments = expensesByTimeInterval[maxInterval.key] ?? [];

      // Получаем оригинальные платежи с помощью сервиса
      final relatedPayments = PaymentExtractionService.extractPayments(maxIntervalPayments);

      // Анализируем категории расходов в этом интервале
      final categoryCounts = <String, int>{};
      for (final expense in maxIntervalPayments) {
        final category = expense.category.isNotEmpty ? expense.category : 'Без категории';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      // Находим наиболее частые категории
      final sortedCategories =
          categoryCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      final topCategories = sortedCategories.take(3).map((e) => e.key).join(', ');

      insights.add(
        createInsight(
          title: 'Выявлен паттерн расходов по времени суток',
          description:
              'Я заметил, что $percentOfTotal% твоих расходов приходится на ${maxInterval.key}. '
              'Чаще всего в это время ты тратишь на: $topCategories. '
              'Понимание этого паттерна может помочь тебе лучше контролировать импульсивные покупки '
              'и планировать расходы в течение дня.',
          type: InsightType.pattern,
          importance: percentOfTotal > 60 ? InsightImportance.medium : InsightImportance.low,
          relatedPayments: relatedPayments,
          additionalData: {
            'intervalTotals':
                intervalTotals.entries
                    .map(
                      (e) => {
                        'interval': e.key,
                        'total': e.value,
                        'percentOfTotal': ((e.value / totalExpenses) * 100).round(),
                      },
                    )
                    .toList(),
            'totalExpenses': totalExpenses,
            'maxInterval': {
              'interval': maxInterval.key,
              'total': maxInterval.value,
              'percentOfTotal': percentOfTotal,
            },
            'topCategories':
                sortedCategories
                    .take(5)
                    .map(
                      (e) => {
                        'category': e.key,
                        'count': e.value,
                        'percentOfInterval': ((e.value / maxIntervalPayments.length) * 100).round(),
                      },
                    )
                    .toList(),
          },
        ),
      );
    }

    return insights;
  }
}
