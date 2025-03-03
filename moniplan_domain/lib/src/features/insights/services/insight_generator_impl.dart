// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:intl/intl.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_domain/src/features/insights/models/_index.dart';
import 'package:moniplan_domain/src/features/insights/services/insight_generator.dart';
import 'package:moniplan_domain/src/features/payment/models/payment/payment.dart';
import 'package:moniplan_domain/src/features/payment/models/payment/payment_type.dart';
import 'package:moniplan_domain/src/features/payment/models/planner/planner.dart';
import 'package:uuid/uuid.dart';

/// Реализация генератора финансовых инсайтов
class InsightGeneratorImpl implements InsightGenerator {
  final _uuid = Uuid();
  final _currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

  @override
  Future<List<Insight>> generateInsights(Planner planner, {int limit = 5}) async {
    final insights = <Insight>[];

    // Собираем инсайты из всех анализаторов
    insights.addAll(_analyzeExpenseStructure(planner));
    insights.addAll(_detectPatterns(planner));
    insights.addAll(_generateForecasts(planner));
    insights.addAll(_compareWithPreviousPeriods(planner));
    insights.addAll(_suggestOptimizations(planner));
    insights.addAll(_analyzeCashFlow(planner));

    // Сортируем инсайты по важности
    insights.sort((a, b) => b.importance.index.compareTo(a.importance.index));

    // Возвращаем топ-N инсайтов
    return insights.take(limit).toList();
  }

  /// Анализирует структуру расходов с использованием продвинутых методов
  List<Insight> _analyzeExpenseStructure(Planner planner) {
    final insights = <Insight>[];
    final payments = planner.payments ?? [];

    if (payments.isEmpty) {
      return insights;
    }

    // Группируем расходы по названиям
    final expensesByName = <String, num>{};
    num totalExpenses = 0;

    for (final payment in payments) {
      if (payment.type == PaymentType.expense) {
        final name = payment.details.name;
        expensesByName[name] = (expensesByName[name] ?? 0) + payment.details.normalizedMoney;
        totalExpenses += payment.details.normalizedMoney;
      }
    }

    if (expensesByName.isEmpty || totalExpenses == 0) {
      return insights;
    }

    // Находим название с наибольшими расходами
    final topName = expensesByName.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Рассчитываем процент от общих расходов
    final percentage = (topName.value / totalExpenses * 100).round();

    if (percentage > 40) {
      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Высокая концентрация расходов',
          description:
              'На "${topName.key}" приходится $percentage% '
              'всех твоих расходов (${_currencyFormat.format(topName.value)}). '
              'Возможно, стоит пересмотреть эту статью бюджета?',
          type: InsightType.expenseStructure,
          importance: percentage > 60 ? InsightImportance.high : InsightImportance.medium,
          additionalData: {'name': topName.key, 'percentage': percentage, 'amount': topName.value},
        ),
      );
    }

    // Анализ разнообразия расходов
    if (expensesByName.length < 3 && payments.length > 5) {
      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Низкое разнообразие расходов',
          description:
              'Ты используешь всего ${expensesByName.length} '
              'типа расходов. Более детальное разделение поможет '
              'лучше анализировать твой бюджет.',
          type: InsightType.advice,
          importance: InsightImportance.low,
        ),
      );
    }

    // Расчет энтропии распределения расходов (мера разнообразия)
    final entropy = _calculateExpenseEntropy(expensesByName, totalExpenses);
    final normalizedEntropy = entropy / log(expensesByName.length > 1 ? expensesByName.length : 2);

    if (normalizedEntropy < 0.6 && expensesByName.length > 3) {
      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Неравномерное распределение расходов',
          description:
              'Твои расходы распределены неравномерно (энтропия: ${normalizedEntropy.toStringAsFixed(2)}). '
              'Это может указывать на несбалансированный бюджет. '
              'Рекомендую пересмотреть структуру расходов для более равномерного распределения.',
          type: InsightType.expenseStructure,
          importance: normalizedEntropy < 0.4 ? InsightImportance.high : InsightImportance.medium,
          additionalData: {'entropy': normalizedEntropy},
        ),
      );
    }

    // Расчет индекса Джини (мера неравенства распределения)
    final giniIndex = _calculateGiniIndex(expensesByName.values.toList());

    if (giniIndex > 0.5 && expensesByName.length > 3) {
      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Высокая концентрация бюджета',
          description:
              'Индекс Джини твоих расходов составляет ${giniIndex.toStringAsFixed(2)}, '
              'что указывает на высокую концентрацию бюджета в нескольких категориях. '
              'Более равномерное распределение может снизить финансовые риски.',
          type: InsightType.expenseStructure,
          importance: giniIndex > 0.7 ? InsightImportance.high : InsightImportance.medium,
          additionalData: {'giniIndex': giniIndex},
        ),
      );
    }

    return insights;
  }

  /// Рассчитывает энтропию Шеннона для распределения расходов
  /// Энтропия - мера неопределенности или разнообразия распределения
  double _calculateExpenseEntropy(Map<String, num> expensesByName, num totalExpenses) {
    double entropy = 0;

    for (final expense in expensesByName.values) {
      final probability = expense / totalExpenses;
      if (probability > 0) {
        entropy -= probability * log(probability) / ln10;
      }
    }

    return entropy;
  }

  /// Рассчитывает индекс Джини для распределения расходов
  /// Индекс Джини - мера статистической дисперсии, используемая для измерения неравенства
  double _calculateGiniIndex(List<num> values) {
    if (values.isEmpty) return 0;
    if (values.length == 1) return 0;

    // Сортируем значения
    values.sort();

    final n = values.length;
    double sumOfAbsoluteDifferences = 0;
    double sumOfValues = 0;

    for (final value in values) {
      sumOfValues += value.toDouble();
    }

    if (sumOfValues == 0) return 0;

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        sumOfAbsoluteDifferences += (values[i] - values[j]).abs();
      }
    }

    return sumOfAbsoluteDifferences / (2 * n * n * (sumOfValues / n));
  }

  /// Выявляет паттерны в расходах
  List<Insight> _detectPatterns(Planner planner) {
    final insights = <Insight>[];
    final payments = planner.payments ?? [];

    if (payments.isEmpty) {
      return insights;
    }

    // Группируем расходы по дням недели
    final expensesByWeekday = <int, num>{};
    final expenseCountByWeekday = <int, int>{};

    for (final payment in payments) {
      if (payment.type == PaymentType.expense) {
        final weekday = payment.date.weekday;
        expensesByWeekday[weekday] =
            (expensesByWeekday[weekday] ?? 0) + payment.details.normalizedMoney;
        expenseCountByWeekday[weekday] = (expenseCountByWeekday[weekday] ?? 0) + 1;
      }
    }

    if (expensesByWeekday.isEmpty) {
      return insights;
    }

    // Находим день с наибольшими расходами
    final topWeekday = expensesByWeekday.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Получаем название дня недели
    final weekdayNames = [
      'понедельникам',
      'вторникам',
      'средам',
      'четвергам',
      'пятницам',
      'субботам',
      'воскресеньям',
    ];
    final weekdayName = weekdayNames[topWeekday.key - 1];

    insights.add(
      Insight(
        id: _uuid.v4(),
        title: 'Паттерн расходов по дням недели',
        description:
            'Ты тратишь больше всего по $weekdayName — '
            'в среднем ${_currencyFormat.format(topWeekday.value / (expenseCountByWeekday[topWeekday.key] ?? 1))}. '
            'Может быть, стоит планировать крупные покупки на другие дни?',
        type: InsightType.pattern,
        importance: InsightImportance.medium,
        additionalData: {
          'weekday': topWeekday.key,
          'weekdayName': weekdayName,
          'amount': topWeekday.value,
        },
      ),
    );

    // Поиск повторяющихся платежей одинакового размера
    final amountFrequency = <num, int>{};
    final amountPayments = <num, List<Payment>>{};

    for (final payment in payments) {
      if (payment.type == PaymentType.expense) {
        final amount = payment.details.normalizedMoney;
        amountFrequency[amount] = (amountFrequency[amount] ?? 0) + 1;
        amountPayments[amount] = [...(amountPayments[amount] ?? []), payment];
      }
    }

    final repeatingAmounts =
        amountFrequency.entries.where((entry) => entry.value >= 3).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (repeatingAmounts.isNotEmpty) {
      final topAmount = repeatingAmounts.first;
      final relatedPayments = amountPayments[topAmount.key] ?? [];

      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Повторяющиеся платежи',
          description:
              'Платеж на сумму ${_currencyFormat.format(topAmount.key)} '
              'встречается ${topAmount.value} раз. Возможно, это регулярная подписка '
              'или повторяющийся расход, который стоит учесть в планировании.',
          type: InsightType.pattern,
          importance: InsightImportance.medium,
          relatedPayments: relatedPayments,
          additionalData: {'amount': topAmount.key, 'frequency': topAmount.value},
        ),
      );
    }

    // Анализ временных рядов для выявления периодичности
    if (payments.length >= 10) {
      // Сортируем платежи по дате
      final sortedPayments = List<Payment>.from(payments)..sort((a, b) => a.date.compareTo(b.date));

      // Группируем расходы по дням
      final dailyExpenses = <DateTime, num>{};

      for (final payment in sortedPayments) {
        if (payment.type == PaymentType.expense) {
          final day = DateTime(payment.date.year, payment.date.month, payment.date.day);
          dailyExpenses[day] = (dailyExpenses[day] ?? 0) + payment.details.normalizedMoney;
        }
      }

      if (dailyExpenses.length >= 7) {
        // Преобразуем в временной ряд
        final dates = dailyExpenses.keys.toList()..sort();
        final timeSeries = dates.map((date) => dailyExpenses[date] ?? 0).toList();

        // Рассчитываем автокорреляцию для выявления периодичности
        final autocorrelation = _calculateAutocorrelation(
          timeSeries,
          7,
        ); // Проверяем недельную периодичность

        // Находим максимальную автокорреляцию и соответствующий лаг
        int maxLag = 0;
        double maxCorrelation = 0;

        for (int i = 1; i < autocorrelation.length; i++) {
          if (autocorrelation[i] > maxCorrelation) {
            maxCorrelation = autocorrelation[i];
            maxLag = i;
          }
        }

        // Если найдена значимая периодичность
        if (maxCorrelation > 0.5 && maxLag > 0) {
          String periodDescription;
          InsightImportance importance;

          if (maxLag == 7) {
            periodDescription = 'недельная';
            importance = InsightImportance.high;
          } else if (maxLag == 1) {
            periodDescription = 'ежедневная';
            importance = InsightImportance.medium;
          } else if (maxLag == 30 || maxLag == 31 || maxLag == 28) {
            periodDescription = 'месячная';
            importance = InsightImportance.high;
          } else {
            periodDescription = '$maxLag-дневная';
            importance = InsightImportance.medium;
          }

          insights.add(
            Insight(
              id: _uuid.v4(),
              title: 'Обнаружена периодичность расходов',
              description:
                  'Анализ временных рядов показал $periodDescription периодичность в твоих расходах '
                  'с коэффициентом корреляции ${maxCorrelation.toStringAsFixed(2)}. '
                  'Это может помочь в более точном планировании бюджета.',
              type: InsightType.pattern,
              importance: importance,
              additionalData: {
                'periodicity': maxLag,
                'correlation': maxCorrelation,
                'description': periodDescription,
              },
            ),
          );
        }
      }

      // Анализ тренда расходов
      if (dailyExpenses.length >= 14) {
        final trendResult = _analyzeTrend(dailyExpenses);

        if (trendResult['slope'] != null) {
          final slope = trendResult['slope'] as double;
          final normalizedSlope = slope / (trendResult['average'] as double);

          if (normalizedSlope.abs() > 0.05) {
            // Значимое изменение
            final trendDirection = slope > 0 ? 'рост' : 'снижение';
            final changePercentage = (normalizedSlope * 100).abs().toStringAsFixed(1);

            insights.add(
              Insight(
                id: _uuid.v4(),
                title: 'Тренд в расходах',
                description:
                    'Обнаружен $trendDirection расходов на $changePercentage% в день. '
                    'При сохранении этой тенденции твои расходы могут ${slope > 0 ? 'значительно вырасти' : 'существенно снизиться'} '
                    'в ближайшие недели.',
                type: InsightType.forecast,
                importance:
                    normalizedSlope.abs() > 0.1 ? InsightImportance.high : InsightImportance.medium,
                additionalData: {
                  'slope': slope,
                  'normalizedSlope': normalizedSlope,
                  'direction': slope > 0 ? 'up' : 'down',
                },
              ),
            );
          }
        }
      }
    }

    return insights;
  }

  /// Рассчитывает автокорреляцию временного ряда
  /// Автокорреляция показывает корреляцию ряда с самим собой со сдвигом
  List<double> _calculateAutocorrelation(List<num> timeSeries, int maxLag) {
    if (timeSeries.isEmpty || maxLag <= 0) {
      return [];
    }

    final n = timeSeries.length;
    final result = List<double>.filled(maxLag + 1, 0);

    // Рассчитываем среднее значение ряда
    double mean = 0;
    for (final value in timeSeries) {
      mean += value.toDouble();
    }
    mean /= n;

    // Рассчитываем дисперсию
    double variance = 0;
    for (final value in timeSeries) {
      variance += pow(value - mean, 2);
    }
    variance /= n;

    if (variance.abs() < 1e-10) {
      return List<double>.filled(
        maxLag + 1,
        0,
      ); // Если дисперсия близка к нулю, автокорреляция не имеет смысла
    }

    // Рассчитываем автокорреляцию для каждого лага
    for (int lag = 0; lag <= maxLag; lag++) {
      double sum = 0;

      for (int i = 0; i < n - lag; i++) {
        sum += (timeSeries[i] - mean) * (timeSeries[i + lag] - mean);
      }

      result[lag] = sum / (n - lag) / variance;
    }

    return result;
  }

  /// Анализирует тренд в расходах с помощью линейной регрессии
  Map<String, double> _analyzeTrend(Map<DateTime, num> dailyExpenses) {
    final dates = dailyExpenses.keys.toList()..sort();

    if (dates.length < 2) {
      return {};
    }

    // Преобразуем даты в числовые значения (дни от начальной даты)
    final startDate = dates.first;
    final x = <double>[];
    final y = <double>[];

    for (final date in dates) {
      final dayDifference = date.difference(startDate).inDays.toDouble();
      x.add(dayDifference);
      y.add(dailyExpenses[date]!.toDouble());
    }

    // Рассчитываем параметры линейной регрессии (y = a + b*x)
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    final n = x.length;

    for (int i = 0; i < n; i++) {
      sumX += x[i];
      sumY += y[i];
      sumXY += x[i] * y[i];
      sumX2 += x[i] * x[i];
    }

    final avgY = sumY / n;

    // Проверяем, что знаменатель не равен нулю
    if ((n * sumX2 - sumX * sumX).abs() < 1e-10) {
      return {'average': avgY};
    }

    // Рассчитываем коэффициенты регрессии
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Рассчитываем коэффициент детерминации (R^2)
    double ssr = 0; // Сумма квадратов регрессии
    double sst = 0; // Общая сумма квадратов

    for (int i = 0; i < n; i++) {
      final predicted = intercept + slope * x[i];
      ssr += pow(predicted - avgY, 2);
      sst += pow(y[i] - avgY, 2);
    }

    double r2 = 0;
    if (sst.abs() > 1e-10) {
      r2 = ssr / sst;
    }

    return {'slope': slope, 'intercept': intercept, 'r2': r2, 'average': avgY};
  }

  /// Генерирует прогнозы и предупреждения
  List<Insight> _generateForecasts(Planner planner) {
    final insights = <Insight>[];
    final payments = planner.payments ?? [];

    if (payments.isEmpty) {
      return insights;
    }

    // Разделяем платежи на выполненные и запланированные
    final completedPayments = payments.where((p) => p.isDone).toList();
    final plannedPayments = payments.where((p) => !p.isDone).toList();

    // Рассчитываем средний ежедневный расход по выполненным платежам
    num totalCompletedExpenses = 0;
    final completedExpenseDates = <DateTime>{};

    for (final payment in completedPayments) {
      if (payment.type == PaymentType.expense) {
        totalCompletedExpenses += payment.details.normalizedMoney;
        completedExpenseDates.add(
          DateTime(payment.date.year, payment.date.month, payment.date.day),
        );
      }
    }

    // Если нет выполненных расходов, используем все платежи для базового прогноза
    if (completedExpenseDates.isEmpty) {
      // Рассчитываем средний ежедневный расход по всем платежам
      num totalExpenses = 0;
      final expenseDates = <DateTime>{};

      for (final payment in payments) {
        if (payment.type == PaymentType.expense) {
          totalExpenses += payment.details.normalizedMoney;
          expenseDates.add(DateTime(payment.date.year, payment.date.month, payment.date.day));
        }
      }

      if (expenseDates.isEmpty) {
        return insights;
      }

      // Вычисляем общий период анализа
      final sortedDates = expenseDates.toList()..sort();
      final firstDate = sortedDates.first;
      final lastDate = sortedDates.last;

      // Вычисляем общее количество дней в периоде (включая дни без платежей)
      final totalDays = lastDate.difference(firstDate).inDays + 1;

      // Рассчитываем средний ежедневный расход с учетом всего периода
      final avgDailyExpense = totalExpenses / totalDays;

      // Прогноз месячных расходов
      final daysInMonth = 30;
      final projectedMonthlyExpense = avgDailyExpense * daysInMonth;

      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Предварительный прогноз расходов',
          description:
              'На основе запланированных платежей, при текущем темпе расходов (${_currencyFormat.format(avgDailyExpense)} в день) '
              'твои месячные расходы могут составить примерно ${_currencyFormat.format(projectedMonthlyExpense)}.',
          type: InsightType.forecast,
          importance: InsightImportance.low,
          additionalData: {
            'dailyAverage': avgDailyExpense,
            'monthlyProjection': projectedMonthlyExpense,
            'totalDays': totalDays,
            'uniqueDaysWithExpenses': expenseDates.length,
            'basedOnPlannedPayments': true,
          },
        ),
      );

      return insights;
    }

    // Вычисляем общий период анализа для выполненных платежей
    final sortedCompletedDates = completedExpenseDates.toList()..sort();
    final firstCompletedDate = sortedCompletedDates.first;
    final lastCompletedDate = sortedCompletedDates.last;

    // Вычисляем общее количество дней в периоде (включая дни без платежей)
    final totalCompletedDays = lastCompletedDate.difference(firstCompletedDate).inDays + 1;

    // Рассчитываем средний ежедневный расход с учетом всего периода
    final avgDailyCompletedExpense = totalCompletedExpenses / totalCompletedDays;

    // Прогноз месячных расходов на основе выполненных платежей
    final daysInMonth = 30;
    final projectedMonthlyExpense = avgDailyCompletedExpense * daysInMonth;

    insights.add(
      Insight(
        id: _uuid.v4(),
        title: 'Прогноз месячных расходов',
        description:
            'При текущем темпе расходов (${_currencyFormat.format(avgDailyCompletedExpense)} в день) '
            'твои месячные расходы составят примерно ${_currencyFormat.format(projectedMonthlyExpense)}.',
        type: InsightType.forecast,
        importance: InsightImportance.medium,
        additionalData: {
          'dailyAverage': avgDailyCompletedExpense,
          'monthlyProjection': projectedMonthlyExpense,
          'totalDays': totalCompletedDays,
          'uniqueDaysWithExpenses': completedExpenseDates.length,
          'basedOnCompletedPayments': true,
        },
      ),
    );

    // Если есть запланированные платежи, добавляем инсайт о будущих расходах
    if (plannedPayments.isNotEmpty) {
      num totalPlannedExpenses = 0;
      final plannedExpenseDates = <DateTime>{};

      for (final payment in plannedPayments) {
        if (payment.type == PaymentType.expense) {
          totalPlannedExpenses += payment.details.normalizedMoney;
          plannedExpenseDates.add(
            DateTime(payment.date.year, payment.date.month, payment.date.day),
          );
        }
      }

      if (plannedExpenseDates.isNotEmpty) {
        // Вычисляем общий период анализа для запланированных платежей
        final sortedPlannedDates = plannedExpenseDates.toList()..sort();
        final firstPlannedDate = sortedPlannedDates.first;
        final lastPlannedDate = sortedPlannedDates.last;

        // Вычисляем общее количество дней в периоде запланированных платежей
        final totalPlannedDays = lastPlannedDate.difference(firstPlannedDate).inDays + 1;

        // Если период запланированных платежей не нулевой
        if (totalPlannedDays > 0) {
          // Рассчитываем средний ежедневный запланированный расход
          final avgDailyPlannedExpense = totalPlannedExpenses / totalPlannedDays;

          // Сравниваем с текущим темпом расходов
          final percentChange =
              ((avgDailyPlannedExpense - avgDailyCompletedExpense) / avgDailyCompletedExpense * 100)
                  .round();

          if (percentChange.abs() >= 10) {
            insights.add(
              Insight(
                id: _uuid.v4(),
                title: 'Изменение темпа расходов',
                description:
                    'Запланированные платежи ${percentChange > 0 ? 'увеличат' : 'уменьшат'} твой ежедневный расход '
                    'на ${percentChange.abs()}% (до ${_currencyFormat.format(avgDailyPlannedExpense)} в день). '
                    'Это может ${percentChange > 0 ? 'негативно' : 'положительно'} повлиять на твой бюджет.',
                type: InsightType.forecast,
                importance: percentChange > 20 ? InsightImportance.high : InsightImportance.medium,
                additionalData: {
                  'currentDailyAverage': avgDailyCompletedExpense,
                  'plannedDailyAverage': avgDailyPlannedExpense,
                  'percentChange': percentChange,
                  'totalPlannedExpenses': totalPlannedExpenses,
                },
              ),
            );
          }
        }
      }
    }

    // Продвинутое прогнозирование с использованием временных рядов
    if (completedPayments.length >= 14) {
      // Сортируем платежи по дате
      final sortedPayments = List<Payment>.from(completedPayments)
        ..sort((a, b) => a.date.compareTo(b.date));

      // Группируем расходы по дням
      final dailyExpenses = <DateTime, num>{};

      for (final payment in sortedPayments) {
        if (payment.type == PaymentType.expense) {
          final day = DateTime(payment.date.year, payment.date.month, payment.date.day);
          dailyExpenses[day] = (dailyExpenses[day] ?? 0) + payment.details.normalizedMoney;
        }
      }

      // Заполняем пропущенные дни нулевыми значениями для более точного анализа
      final completeTimeSeries = <DateTime, num>{};

      // Создаем полный временной ряд со всеми днями в периоде
      for (int i = 0; i < totalCompletedDays; i++) {
        final currentDate = firstCompletedDate.add(Duration(days: i));
        final normalizedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
        completeTimeSeries[normalizedDate] = dailyExpenses[normalizedDate] ?? 0;
      }

      if (completeTimeSeries.length >= 7) {
        // Преобразуем в временной ряд
        final dates = completeTimeSeries.keys.toList()..sort();
        final timeSeries = dates.map((date) => completeTimeSeries[date]!.toDouble()).toList();

        // Прогнозирование с использованием экспоненциального сглаживания
        final alpha = 0.3; // Параметр сглаживания
        final forecastDays = 7; // Прогноз на неделю вперед

        final smoothedSeries = _exponentialSmoothing(timeSeries, alpha);
        final forecast = _forecastExponentialSmoothing(smoothedSeries, alpha, forecastDays);

        // Рассчитываем среднее значение прогноза
        double avgForecast = 0;
        for (final value in forecast) {
          avgForecast += value;
        }
        avgForecast /= forecast.length;

        // Рассчитываем среднее значение последних 7 дней
        double avgRecent = 0;
        final recentDays = timeSeries.length >= 7 ? 7 : timeSeries.length;
        for (int i = timeSeries.length - recentDays; i < timeSeries.length; i++) {
          avgRecent += timeSeries[i];
        }
        avgRecent /= recentDays;

        // Рассчитываем процентное изменение
        final percentChange = ((avgForecast - avgRecent) / avgRecent * 100).round();

        if (percentChange.abs() >= 10) {
          insights.add(
            Insight(
              id: _uuid.v4(),
              title: 'Прогноз изменения расходов',
              description:
                  'На основе анализа временных рядов, в ближайшую неделю ожидается '
                  '${percentChange > 0 ? 'увеличение' : 'снижение'} твоих ежедневных расходов '
                  'примерно на ${percentChange.abs()}% '
                  '(до ${_currencyFormat.format(avgForecast)} в день).',
              type: InsightType.forecast,
              importance:
                  percentChange.abs() >= 20 ? InsightImportance.high : InsightImportance.medium,
              additionalData: {
                'percentChange': percentChange,
                'avgForecast': avgForecast,
                'avgRecent': avgRecent,
              },
            ),
          );
        }

        // Прогнозирование с использованием скользящего среднего
        if (timeSeries.length >= 10) {
          final windowSize = 3; // Размер окна для скользящего среднего
          final maForecast = _movingAverageForecast(timeSeries, windowSize, forecastDays);

          // Рассчитываем среднее значение прогноза
          double maAvgForecast = 0;
          for (final value in maForecast) {
            maAvgForecast += value;
          }
          maAvgForecast /= maForecast.length;

          // Сравниваем прогнозы разных методов
          final forecastDiff = ((maAvgForecast - avgForecast) / avgForecast * 100).abs().round();

          if (forecastDiff >= 15) {
            insights.add(
              Insight(
                id: _uuid.v4(),
                title: 'Неопределенность в прогнозе',
                description:
                    'Разные методы прогнозирования дают существенно различающиеся результаты '
                    '(разница $forecastDiff%). Это может указывать на высокую волатильность '
                    'твоих расходов. Рекомендуется более консервативное планирование бюджета.',
                type: InsightType.advice,
                importance: forecastDiff >= 25 ? InsightImportance.high : InsightImportance.medium,
                additionalData: {
                  'forecastDiff': forecastDiff,
                  'esAvgForecast': avgForecast,
                  'maAvgForecast': maAvgForecast,
                },
              ),
            );
          }
        }
      }
    }

    return insights;
  }

  /// Применяет экспоненциальное сглаживание к временному ряду
  List<double> _exponentialSmoothing(List<double> timeSeries, double alpha) {
    if (timeSeries.isEmpty || alpha < 0 || alpha > 1) {
      return [];
    }

    final result = <double>[];
    double smoothed = timeSeries[0];
    result.add(smoothed);

    for (int i = 1; i < timeSeries.length; i++) {
      smoothed = alpha * timeSeries[i] + (1 - alpha) * smoothed;
      result.add(smoothed);
    }

    return result;
  }

  /// Прогнозирует будущие значения с использованием экспоненциального сглаживания
  List<double> _forecastExponentialSmoothing(
    List<double> smoothedSeries,
    double alpha,
    int forecastDays,
  ) {
    if (smoothedSeries.isEmpty || forecastDays <= 0) {
      return [];
    }

    final result = <double>[];
    final lastSmoothed = smoothedSeries.last;

    // Для простого экспоненциального сглаживания прогноз - это последнее сглаженное значение
    for (int i = 0; i < forecastDays; i++) {
      result.add(lastSmoothed);
    }

    return result;
  }

  /// Рассчитывает скользящее среднее временного ряда
  List<double> _movingAverage(List<double> timeSeries, int windowSize) {
    if (timeSeries.isEmpty || windowSize <= 0 || windowSize > timeSeries.length) {
      return [];
    }

    final result = <double>[];

    for (int i = 0; i <= timeSeries.length - windowSize; i++) {
      double sum = 0;
      for (int j = 0; j < windowSize; j++) {
        sum += timeSeries[i + j];
      }
      result.add(sum / windowSize);
    }

    return result;
  }

  /// Прогнозирует будущие значения с использованием скользящего среднего
  List<double> _movingAverageForecast(List<double> timeSeries, int windowSize, int forecastDays) {
    if (timeSeries.isEmpty || windowSize <= 0 || forecastDays <= 0) {
      return [];
    }

    final ma = _movingAverage(timeSeries, windowSize);
    if (ma.isEmpty) {
      return [];
    }

    final result = <double>[];
    final lastValues = timeSeries.sublist(timeSeries.length - windowSize);

    for (int i = 0; i < forecastDays; i++) {
      double sum = 0;
      for (final value in lastValues) {
        sum += value;
      }
      final nextValue = sum / windowSize;
      result.add(nextValue);

      // Обновляем последние значения для следующего прогноза
      lastValues.removeAt(0);
      lastValues.add(nextValue);
    }

    return result;
  }

  /// Сравнивает с предыдущими периодами
  List<Insight> _compareWithPreviousPeriods(Planner planner) {
    // В реальной реализации здесь будет сравнение с предыдущими периодами
    // Для демонстрации добавим заглушку
    return [
      Insight(
        id: _uuid.v4(),
        title: 'Сравнение с прошлым периодом',
        description:
            'Функция сравнения с предыдущими периодами будет доступна, '
            'когда у тебя появится больше данных.',
        type: InsightType.comparison,
        importance: InsightImportance.low,
      ),
    ];
  }

  /// Предлагает оптимизации бюджета
  List<Insight> _suggestOptimizations(Planner planner) {
    final insights = <Insight>[];
    final payments = planner.payments ?? [];

    if (payments.isEmpty) {
      return insights;
    }

    // Группируем расходы по названиям
    final expensesByName = <String, List<Payment>>{};

    for (final payment in payments) {
      if (payment.type == PaymentType.expense) {
        final name = payment.details.name;
        expensesByName[name] = [...(expensesByName[name] ?? []), payment];
      }
    }

    // Ищем названия с наибольшим количеством мелких расходов
    final namesWithSmallExpenses = <String, int>{};

    for (final entry in expensesByName.entries) {
      final smallExpenses = entry.value.where((p) => p.details.normalizedMoney.abs() < 500).length;
      if (smallExpenses >= 3) {
        namesWithSmallExpenses[entry.key] = smallExpenses;
      }
    }

    if (namesWithSmallExpenses.isNotEmpty) {
      final topName = namesWithSmallExpenses.entries.reduce((a, b) => a.value > b.value ? a : b);

      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Много мелких расходов',
          description:
              'В "${topName.key}" у тебя ${topName.value} '
              'мелких расходов. Возможно, стоит объединить покупки, '
              'чтобы сэкономить время и, возможно, деньги.',
          type: InsightType.optimization,
          importance: InsightImportance.medium,
          relatedPayments: expensesByName[topName.key],
          additionalData: {'name': topName.key, 'count': topName.value},
        ),
      );
    }

    return insights;
  }

  /// Анализирует движение денежных средств
  List<Insight> _analyzeCashFlow(Planner planner) {
    final insights = <Insight>[];
    final payments = planner.payments ?? [];

    if (payments.isEmpty) {
      return insights;
    }

    // Разделяем платежи на выполненные и запланированные
    final completedPayments = payments.where((p) => p.isDone).toList();
    final plannedPayments = payments.where((p) => !p.isDone).toList();

    // Сортируем платежи по дате
    final sortedCompletedPayments = List<Payment>.from(completedPayments)
      ..sort((a, b) => a.date.compareTo(b.date));
    final sortedPlannedPayments = List<Payment>.from(plannedPayments)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Определяем временной диапазон анализа для выполненных платежей
    DateTime? firstCompletedDate;
    DateTime? lastCompletedDate;
    int totalCompletedDays = 0;

    if (sortedCompletedPayments.isNotEmpty) {
      firstCompletedDate = DateTime(
        sortedCompletedPayments.first.date.year,
        sortedCompletedPayments.first.date.month,
        sortedCompletedPayments.first.date.day,
      );
      lastCompletedDate = DateTime(
        sortedCompletedPayments.last.date.year,
        sortedCompletedPayments.last.date.month,
        sortedCompletedPayments.last.date.day,
      );
      totalCompletedDays = lastCompletedDate.difference(firstCompletedDate).inDays + 1;
    }

    // Определяем временной диапазон анализа для запланированных платежей
    DateTime? firstPlannedDate;
    DateTime? lastPlannedDate;
    int totalPlannedDays = 0;

    if (sortedPlannedPayments.isNotEmpty) {
      firstPlannedDate = DateTime(
        sortedPlannedPayments.first.date.year,
        sortedPlannedPayments.first.date.month,
        sortedPlannedPayments.first.date.day,
      );
      lastPlannedDate = DateTime(
        sortedPlannedPayments.last.date.year,
        sortedPlannedPayments.last.date.month,
        sortedPlannedPayments.last.date.day,
      );
      totalPlannedDays = lastPlannedDate.difference(firstPlannedDate).inDays + 1;
    }

    // Определяем общий временной диапазон для анализа
    DateTime firstDate;
    DateTime lastDate;

    if (firstCompletedDate != null && firstPlannedDate != null) {
      firstDate =
          firstCompletedDate.isBefore(firstPlannedDate) ? firstCompletedDate : firstPlannedDate;
    } else if (firstCompletedDate != null) {
      firstDate = firstCompletedDate;
    } else if (firstPlannedDate != null) {
      firstDate = firstPlannedDate;
    } else {
      return insights; // Нет платежей для анализа
    }

    if (lastCompletedDate != null && lastPlannedDate != null) {
      lastDate = lastCompletedDate.isAfter(lastPlannedDate) ? lastCompletedDate : lastPlannedDate;
    } else if (lastCompletedDate != null) {
      lastDate = lastCompletedDate;
    } else {
      lastDate = lastPlannedDate!;
    }

    final totalDays = lastDate.difference(firstDate).inDays + 1;

    // Симулируем движение средств
    num currentBalance = planner.initialBudget;
    DateTime? negativeBalanceDate;
    num lowestBalance = currentBalance;
    bool isNegativeFromPlanned =
        false; // Флаг для определения, вызван ли отрицательный баланс запланированными платежами

    // Для расчета коэффициентов ликвидности
    final dailyBalances = <DateTime, num>{};
    final dailyExpenses = <DateTime, num>{};
    final dailyIncomes = <DateTime, num>{};
    final isPlannedDay = <DateTime, bool>{}; // Отмечаем дни с запланированными платежами

    // Инициализируем все дни в периоде нулевыми значениями
    for (int i = 0; i < totalDays; i++) {
      final currentDate = firstDate.add(Duration(days: i));
      final day = DateTime(currentDate.year, currentDate.month, currentDate.day);
      dailyExpenses[day] = 0;
      dailyIncomes[day] = 0;
      isPlannedDay[day] = false;
    }

    // Заполняем фактические данные по выполненным платежам
    for (final payment in sortedCompletedPayments) {
      final day = DateTime(payment.date.year, payment.date.month, payment.date.day);

      if (payment.type == PaymentType.expense) {
        currentBalance -= payment.details.normalizedMoney;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + payment.details.normalizedMoney;
      } else {
        currentBalance += payment.details.normalizedMoney;
        dailyIncomes[day] = (dailyIncomes[day] ?? 0) + payment.details.normalizedMoney;
      }

      dailyBalances[day] = currentBalance;

      if (currentBalance < lowestBalance) {
        lowestBalance = currentBalance;
      }

      if (currentBalance < 0 && negativeBalanceDate == null) {
        negativeBalanceDate = payment.date;
        isNegativeFromPlanned = false;
      }
    }

    // Сохраняем баланс после выполненных платежей
    num balanceAfterCompleted = currentBalance;

    // Заполняем данные по запланированным платежам
    for (final payment in sortedPlannedPayments) {
      final day = DateTime(payment.date.year, payment.date.month, payment.date.day);
      isPlannedDay[day] = true;

      if (payment.type == PaymentType.expense) {
        currentBalance -= payment.details.normalizedMoney;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + payment.details.normalizedMoney;
      } else {
        currentBalance += payment.details.normalizedMoney;
        dailyIncomes[day] = (dailyIncomes[day] ?? 0) + payment.details.normalizedMoney;
      }

      dailyBalances[day] = currentBalance;

      if (currentBalance < lowestBalance) {
        lowestBalance = currentBalance;
      }

      if (currentBalance < 0 && negativeBalanceDate == null) {
        negativeBalanceDate = payment.date;
        isNegativeFromPlanned = true;
      }
    }

    // Заполняем пропущенные значения баланса
    // Проходим по всем дням и заполняем пропущенные значения баланса
    num lastBalance = planner.initialBudget;
    for (int i = 0; i < totalDays; i++) {
      final currentDate = firstDate.add(Duration(days: i));
      final day = DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (dailyBalances.containsKey(day)) {
        lastBalance = dailyBalances[day]!;
      } else {
        dailyBalances[day] = lastBalance;
      }
    }

    // Если прогнозируется отрицательный баланс
    if (negativeBalanceDate != null) {
      final formatter = DateFormat('d MMMM', 'ru');
      final importance =
          isNegativeFromPlanned ? InsightImportance.high : InsightImportance.critical;
      final prefix = isNegativeFromPlanned ? 'С учетом запланированных платежей, ' : '';

      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Риск кассового разрыва',
          description:
              '${prefix}По моим расчетам, примерно ${formatter.format(negativeBalanceDate)} '
              'твой баланс может уйти в минус. Рекомендую пересмотреть '
              'планируемые расходы или увеличить доходы.',
          type: InsightType.forecast,
          importance: importance,
          additionalData: {
            'date': negativeBalanceDate.toIso8601String(),
            'formattedDate': formatter.format(negativeBalanceDate),
            'projectedBalance': lowestBalance,
            'isFromPlannedPayments': isNegativeFromPlanned,
          },
        ),
      );
    }

    // Если баланс близок к нулю
    if (lowestBalance >= 0 && lowestBalance < 1000) {
      final isFromPlanned = lowestBalance != balanceAfterCompleted;
      final prefix = isFromPlanned ? 'С учетом запланированных платежей, ' : '';
      final importance = isFromPlanned ? InsightImportance.medium : InsightImportance.high;

      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Низкий остаток средств',
          description:
              '${prefix}В какой-то момент твой баланс может снизиться до ${_currencyFormat.format(lowestBalance)}. '
              'Это довольно близко к нулю, рекомендую иметь небольшой запас.',
          type: InsightType.forecast,
          importance: importance,
          additionalData: {'lowestBalance': lowestBalance, 'isFromPlannedPayments': isFromPlanned},
        ),
      );
    }

    // Расчет коэффициентов ликвидности
    if (dailyBalances.isNotEmpty && dailyExpenses.isNotEmpty) {
      // Рассчитываем средние ежедневные расходы с учетом всех дней в периоде
      double totalExpenses = 0;
      for (final expense in dailyExpenses.values) {
        totalExpenses += expense.toDouble();
      }
      final avgDailyExpense = totalExpenses / totalDays;

      // Рассчитываем текущий коэффициент ликвидности (текущий баланс / средние ежедневные расходы)
      // Показывает, на сколько дней хватит текущего баланса при средних расходах
      final currentLiquidityRatio = avgDailyExpense > 0 ? currentBalance / avgDailyExpense : 0;

      if (currentLiquidityRatio < 7 && avgDailyExpense > 0) {
        insights.add(
          Insight(
            id: _uuid.v4(),
            title: 'Низкий запас ликвидности',
            description:
                'При текущем темпе расходов твоего баланса хватит примерно на '
                '${currentLiquidityRatio.round()} дней. Рекомендуется иметь запас '
                'минимум на 2 недели для финансовой безопасности.',
            type: InsightType.advice,
            importance:
                currentLiquidityRatio < 3 ? InsightImportance.critical : InsightImportance.high,
            additionalData: {'liquidityRatio': currentLiquidityRatio},
          ),
        );
      } else if (currentLiquidityRatio > 60 && avgDailyExpense > 0) {
        insights.add(
          Insight(
            id: _uuid.v4(),
            title: 'Избыточная ликвидность',
            description:
                'Твой текущий баланс обеспечивает запас на ${currentLiquidityRatio.round()} дней '
                'при текущем темпе расходов. Возможно, стоит рассмотреть инвестирование '
                'части средств для получения дополнительного дохода.',
            type: InsightType.advice,
            importance: InsightImportance.medium,
            additionalData: {'liquidityRatio': currentLiquidityRatio},
          ),
        );
      }

      // Анализ волатильности денежного потока только для выполненных платежей
      if (sortedCompletedPayments.length >= 7 && totalCompletedDays > 0) {
        final completedExpenseValues = <num>[];

        // Собираем расходы только за дни с выполненными платежами
        for (int i = 0; i < totalCompletedDays; i++) {
          final currentDate = firstCompletedDate!.add(Duration(days: i));
          final day = DateTime(currentDate.year, currentDate.month, currentDate.day);
          if (!isPlannedDay[day]!) {
            completedExpenseValues.add(dailyExpenses[day] ?? 0);
          }
        }

        if (completedExpenseValues.isNotEmpty) {
          final mean =
              completedExpenseValues.reduce((a, b) => a + b) / completedExpenseValues.length;

          // Проверяем, что среднее значение не равно нулю
          if (mean > 0) {
            double variance = 0;
            for (final value in completedExpenseValues) {
              variance += pow(value - mean, 2);
            }
            variance /= completedExpenseValues.length;

            final stdDev = sqrt(variance);
            final coefficientOfVariation = stdDev / mean; // Коэффициент вариации

            if (coefficientOfVariation > 0.5) {
              insights.add(
                Insight(
                  id: _uuid.v4(),
                  title: 'Высокая волатильность расходов',
                  description:
                      'Твои ежедневные расходы сильно колеблются (коэффициент вариации: '
                      '${(coefficientOfVariation * 100).round()}%). Это может затруднять '
                      'планирование бюджета. Рекомендуется более равномерное распределение расходов.',
                  type: InsightType.pattern,
                  importance:
                      coefficientOfVariation > 0.8
                          ? InsightImportance.high
                          : InsightImportance.medium,
                  additionalData: {'coefficientOfVariation': coefficientOfVariation},
                ),
              );
            }
          }
        }
      }
    }

    // Анализ сезонности денежного потока только для выполненных платежей
    if (sortedCompletedPayments.length >= 14 && totalCompletedDays >= 14) {
      // Группируем расходы по дням недели для выявления недельной сезонности
      final expensesByWeekday = <int, List<num>>{};

      for (int i = 0; i < totalCompletedDays; i++) {
        final currentDate = firstCompletedDate!.add(Duration(days: i));
        final day = DateTime(currentDate.year, currentDate.month, currentDate.day);
        if (!isPlannedDay[day]!) {
          final weekday = day.weekday;
          final expense = dailyExpenses[day] ?? 0;
          expensesByWeekday[weekday] = [...(expensesByWeekday[weekday] ?? []), expense];
        }
      }

      // Рассчитываем средние расходы по дням недели
      final avgExpensesByWeekday = <int, double>{};
      final countsByWeekday = <int, int>{};

      for (final entry in expensesByWeekday.entries) {
        final weekday = entry.key;
        final expenses = entry.value;
        if (expenses.isNotEmpty) {
          final avgExpense = expenses.reduce((a, b) => a + b) / expenses.length;
          avgExpensesByWeekday[weekday] = avgExpense;
          countsByWeekday[weekday] = expenses.length;
        }
      }

      // Рассчитываем общее среднее
      double overallAvg = 0;
      int totalCount = 0;
      for (final entry in avgExpensesByWeekday.entries) {
        overallAvg += entry.value * countsByWeekday[entry.key]!;
        totalCount += countsByWeekday[entry.key]!;
      }

      if (totalCount > 0) {
        overallAvg /= totalCount;

        // Находим дни с наибольшим отклонением от среднего
        final weekdayNames = [
          'понедельник',
          'вторник',
          'среда',
          'четверг',
          'пятница',
          'суббота',
          'воскресенье',
        ];

        int maxDeviationWeekday = 0;
        double maxDeviation = 0;

        for (final entry in avgExpensesByWeekday.entries) {
          final weekday = entry.key;
          final avg = entry.value;

          // Проверяем, что общее среднее не равно нулю
          if (overallAvg > 0) {
            final deviation = (avg - overallAvg).abs() / overallAvg;

            if (deviation > maxDeviation) {
              maxDeviation = deviation;
              maxDeviationWeekday = weekday;
            }
          }
        }

        if (maxDeviation > 0.3 && overallAvg > 0) {
          // Значимое отклонение (более 30%)
          final weekdayName = weekdayNames[maxDeviationWeekday - 1];
          final avgExpense = avgExpensesByWeekday[maxDeviationWeekday]!;
          final isHigher = avgExpense > overallAvg;

          insights.add(
            Insight(
              id: _uuid.v4(),
              title: 'Сезонность расходов',
              description:
                  'По ${weekdayName}ам твои расходы ${isHigher ? 'выше' : 'ниже'} среднего на '
                  '${(maxDeviation * 100).round()}% (${_currencyFormat.format(avgExpense)} против '
                  'среднего ${_currencyFormat.format(overallAvg)}). Учитывай эту сезонность '
                  'при планировании бюджета.',
              type: InsightType.pattern,
              importance: maxDeviation > 0.5 ? InsightImportance.high : InsightImportance.medium,
              additionalData: {
                'weekday': maxDeviationWeekday,
                'weekdayName': weekdayName,
                'avgExpense': avgExpense,
                'overallAvg': overallAvg,
                'deviation': maxDeviation,
              },
            ),
          );
        }
      }
    }

    return insights;
  }
}
