// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Виджет для отображения графиков в инсайтах
class InsightCharts {
  /// Форматтер для денежных сумм
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 0,
  );

  /// Создает круговую диаграмму для структуры расходов
  static Widget buildExpenseStructurePieChart(
    BuildContext context,
    Map<String, dynamic> additionalData,
  ) {
    // Проверяем наличие необходимых данных
    if (!additionalData.containsKey('allCategories')) {
      return const SizedBox.shrink();
    }

    final allCategories = additionalData['allCategories'] as List<dynamic>;
    if (allCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Создаем секции для круговой диаграммы
    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];

    // Ограничиваем количество категорий для отображения
    final categoriesToShow = allCategories.take(7).toList();
    double otherTotal = 0;

    // Если категорий больше 7, группируем остальные в "Другое"
    if (allCategories.length > 7) {
      for (int i = 7; i < allCategories.length; i++) {
        final category = allCategories[i] as Map<String, dynamic>;
        otherTotal += (category['total'] as num).toDouble();
      }
    }

    // Создаем секции для основных категорий
    for (int i = 0; i < categoriesToShow.length; i++) {
      final category = categoriesToShow[i] as Map<String, dynamic>;
      final percent = category['percent'] as int;
      final categoryName = category['category'] as String;

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: percent.toDouble(),
          title: '$percent%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _Badge(categoryName, size: 16, borderColor: colors[i % colors.length]),
          badgePositionPercentageOffset: 1.1,
        ),
      );
    }

    // Добавляем секцию "Другое", если есть
    if (otherTotal > 0) {
      final totalExpenses = additionalData['totalExpenses'] as double;
      final otherPercent = (otherTotal / totalExpenses * 100).round();

      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: otherPercent.toDouble(),
          title: '$otherPercent%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: const _Badge('Другое', size: 16, borderColor: Colors.grey),
          badgePositionPercentageOffset: 1.1,
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Структура расходов',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Можно добавить интерактивность при касании
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Создает линейный график для сравнения периодов
  static Widget buildComparisonLineChart(
    BuildContext context,
    Map<String, dynamic> additionalData,
  ) {
    // Проверяем наличие необходимых данных
    if (!additionalData.containsKey('firstPeriodTotals') ||
        !additionalData.containsKey('secondPeriodTotals') ||
        !additionalData.containsKey('significantChanges')) {
      return const SizedBox.shrink();
    }

    final firstPeriodTotals = additionalData['firstPeriodTotals'] as Map<String, dynamic>;
    final secondPeriodTotals = additionalData['secondPeriodTotals'] as Map<String, dynamic>;
    final significantChanges = additionalData['significantChanges'] as List<dynamic>;

    if (significantChanges.isEmpty) {
      return const SizedBox.shrink();
    }

    // Получаем категории с наибольшими изменениями
    final categories = <String>[];
    for (final change in significantChanges) {
      final category = change['category'] as String;
      categories.add(category);
    }

    // Ограничиваем количество категорий для отображения
    final categoriesToShow = categories.take(5).toList();

    // Создаем данные для графика
    final spots1 = <FlSpot>[];
    final spots2 = <FlSpot>[];

    for (int i = 0; i < categoriesToShow.length; i++) {
      final category = categoriesToShow[i];
      final firstValue = firstPeriodTotals[category] as double? ?? 0;
      final secondValue = secondPeriodTotals[category] as double? ?? 0;

      spots1.add(FlSpot(i.toDouble(), firstValue));
      spots2.add(FlSpot(i.toDouble(), secondValue));
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Сравнение расходов по периодам',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1000,
                verticalInterval: 1,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < categoriesToShow.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            categoriesToShow[index].length > 10
                                ? '${categoriesToShow[index].substring(0, 10)}...'
                                : categoriesToShow[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _currencyFormat.format(value).replaceAll(' ', ''),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: categoriesToShow.length - 1.0,
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  spots: spots1,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: spots2,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
            ),
            const SizedBox(width: 4),
            const Text('Первый период'),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            ),
            const SizedBox(width: 4),
            const Text('Второй период'),
          ],
        ),
      ],
    );
  }

  /// Создает столбчатую диаграмму для паттернов расходов
  static Widget buildPatternBarChart(BuildContext context, Map<String, dynamic> additionalData) {
    // Проверяем наличие необходимых данных для инфляции образа жизни
    if (additionalData.containsKey('incomeChange') && additionalData.containsKey('expenseChange')) {
      return _buildLifestyleInflationBarChart(context, additionalData);
    }

    // Проверяем наличие необходимых данных для категорий с ростом расходов
    if (additionalData.containsKey('topGrowthCategories') &&
        additionalData.containsKey('categoryChangePercents')) {
      return _buildCategoryGrowthBarChart(context, additionalData);
    }

    return const SizedBox.shrink();
  }

  /// Создает столбчатую диаграмму для инфляции образа жизни
  static Widget _buildLifestyleInflationBarChart(
    BuildContext context,
    Map<String, dynamic> additionalData,
  ) {
    final incomeChange = additionalData['incomeChange'] as double;
    final expenseChange = additionalData['expenseChange'] as double;

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Изменение доходов и расходов',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: [incomeChange.abs(), expenseChange.abs()].reduce((a, b) => a > b ? a : b) * 1.2,
              minY: 0,
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: incomeChange.abs(),
                      color: incomeChange >= 0 ? Colors.green : Colors.red,
                      width: 40,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: expenseChange.abs(),
                      color: expenseChange <= 0 ? Colors.green : Colors.red,
                      width: 40,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final titles = ['Доходы', 'Расходы'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 14)),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12));
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: incomeChange >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 4),
            Text('Изменение доходов: ${incomeChange.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: expenseChange <= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 4),
            Text('Изменение расходов: ${expenseChange.toStringAsFixed(1)}%'),
          ],
        ),
      ],
    );
  }

  /// Создает столбчатую диаграмму для категорий с ростом расходов
  static Widget _buildCategoryGrowthBarChart(
    BuildContext context,
    Map<String, dynamic> additionalData,
  ) {
    final topGrowthCategories = additionalData['topGrowthCategories'] as List<dynamic>;
    final categoryChangePercents = additionalData['categoryChangePercents'] as Map<String, dynamic>;

    if (topGrowthCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Создаем данные для графика
    final barGroups = <BarChartGroupData>[];
    final categories = <String>[];

    for (int i = 0; i < topGrowthCategories.length; i++) {
      final category = topGrowthCategories[i] as String;
      categories.add(category);
      final changePercent = categoryChangePercents[category] as double;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: changePercent,
              color: changePercent > 0 ? Colors.red : Colors.green,
              width: 30,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Изменение расходов по категориям',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY:
                  barGroups
                      .map((group) => group.barRods.first.toY)
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              minY: 0,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < categories.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            categories[index].length > 10
                                ? '${categories[index].substring(0, 10)}...'
                                : categories[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12));
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  /// Создает график для инсайта с предложениями категорий
  static Widget buildCategorySuggestionChart(
    BuildContext context,
    Map<String, dynamic> additionalData,
  ) {
    // Проверяем наличие необходимых данных
    if (!additionalData.containsKey('operations')) {
      return const SizedBox.shrink();
    }

    final operations = additionalData['operations'] as List<dynamic>;
    if (operations.isEmpty) {
      return const SizedBox.shrink();
    }

    // Собираем статистику по предлагаемым категориям
    final categoryStats = <String, int>{};

    for (final operation in operations) {
      final suggestions = operation['suggestions'] as List<dynamic>? ?? [];
      if (suggestions.isNotEmpty) {
        final topSuggestion = suggestions.first as Map<String, dynamic>;
        final category = topSuggestion['category'] as String;
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }
    }

    // Сортируем категории по количеству предложений
    final sortedCategories =
        categoryStats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Ограничиваем количество категорий для отображения
    final categoriesToShow = sortedCategories.take(5).toList();

    // Создаем данные для графика
    final barGroups = <BarChartGroupData>[];
    final categories = <String>[];
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

    for (int i = 0; i < categoriesToShow.length; i++) {
      final entry = categoriesToShow[i];
      categories.add(entry.key);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: colors[i % colors.length],
              width: 30,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Наиболее часто предлагаемые категории',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY:
                  barGroups
                      .map((group) => group.barRods.first.toY)
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              minY: 0,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < categories.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            categories[index].length > 10
                                ? '${categories[index].substring(0, 10)}...'
                                : categories[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
                    },
                    reservedSize: 40,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Количество операций с предложенной категорией',
          style: TextStyle(fontSize: 12, color: context.color.onSurface.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Создает график для инсайтов типа optimization
  static Widget buildOptimizationChart(BuildContext context, Map<String, dynamic> additionalData) {
    // Проверяем наличие данных о перерасходе бюджета
    if (additionalData.containsKey('overBudgetCategories')) {
      return _buildOverBudgetChart(context, additionalData);
    }

    // Проверяем наличие данных о высокой доле расходов
    if (additionalData.containsKey('category') && additionalData.containsKey('percent')) {
      return _buildHighExpenseShareChart(context, additionalData);
    }

    // Проверяем наличие данных о сезонной оптимизации
    if (additionalData.containsKey('highMonths') && additionalData.containsKey('avgMonthly')) {
      return _buildSeasonalOptimizationChart(context, additionalData);
    }

    return const SizedBox.shrink();
  }

  /// Создает график для инсайта о перерасходе бюджета
  static Widget _buildOverBudgetChart(BuildContext context, Map<String, dynamic> additionalData) {
    final overBudgetCategories = additionalData['overBudgetCategories'] as List<dynamic>;

    if (overBudgetCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ограничиваем количество категорий для отображения
    final categoriesToShow = overBudgetCategories.take(5).toList();

    // Создаем данные для графика
    final barGroups = <BarChartGroupData>[];
    final categories = <String>[];

    for (int i = 0; i < categoriesToShow.length; i++) {
      final category = categoriesToShow[i] as Map<String, dynamic>;
      final categoryName = category['category'] as String;
      final planned = category['planned'] as double;
      final actual = category['actual'] as double;

      categories.add(categoryName);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: planned,
              color: Colors.blue,
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            BarChartRodData(
              toY: actual,
              color: Colors.red,
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Сравнение плановых и фактических расходов',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  barGroups
                      .expand((group) => group.barRods.map((rod) => rod.toY))
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              minY: 0,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < categories.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            categories[index].length > 10
                                ? '${categories[index].substring(0, 10)}...'
                                : categories[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _currencyFormat.format(value).replaceAll(' ', ''),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                    reservedSize: 60,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
            ),
            const SizedBox(width: 4),
            const Text('Запланировано'),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            ),
            const SizedBox(width: 4),
            const Text('Фактически'),
          ],
        ),
      ],
    );
  }

  /// Создает график для инсайта о высокой доле расходов
  static Widget _buildHighExpenseShareChart(
    BuildContext context,
    Map<String, dynamic> additionalData,
  ) {
    final category = additionalData['category'] as String;
    final percent = additionalData['percent'] as int;
    final otherPercent = 100 - percent;

    // Создаем секции для круговой диаграммы
    final sections = <PieChartSectionData>[
      PieChartSectionData(
        color: Colors.red,
        value: percent.toDouble(),
        title: '$percent%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: _Badge(category, size: 16, borderColor: Colors.red),
        badgePositionPercentageOffset: 1.1,
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: otherPercent.toDouble(),
        title: '$otherPercent%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: const _Badge('Другие', size: 16, borderColor: Colors.blue),
        badgePositionPercentageOffset: 1.1,
      ),
    ];

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Доля расходов на категорию "$category"',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Можно добавить интерактивность при касании
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Создает график для инсайта о сезонной оптимизации
  static Widget _buildSeasonalOptimizationChart(
    BuildContext context,
    Map<String, dynamic> additionalData,
  ) {
    final highMonths = additionalData['highMonths'] as List<dynamic>;
    final avgMonthly = additionalData['avgMonthly'] as double;
    final category = additionalData['category'] as String;

    if (highMonths.isEmpty) {
      return const SizedBox.shrink();
    }

    // Создаем данные для графика
    final spots = <FlSpot>[];
    final monthNames = <String>[];
    final monthValues = <double>[];

    // Сортируем месяцы по ключу (чтобы они шли в хронологическом порядке)
    final sortedMonths = List<Map<String, dynamic>>.from(highMonths)
      ..sort((a, b) => (a['monthKey'] as String).compareTo(b['monthKey'] as String));

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final amount = month['amount'] as double;
      final monthKey = month['monthKey'] as String;

      // Извлекаем месяц из ключа (формат: YYYY-MM)
      final parts = monthKey.split('-');
      if (parts.length == 2) {
        final monthNumber = int.tryParse(parts[1]);
        if (monthNumber != null) {
          final monthName = _getMonthName(monthNumber);
          monthNames.add(monthName);
          monthValues.add(amount);
          spots.add(FlSpot(i.toDouble(), amount));
        }
      }
    }

    // Добавляем линию среднего значения
    final avgLine = <FlSpot>[];
    for (int i = 0; i < spots.length; i++) {
      avgLine.add(FlSpot(i.toDouble(), avgMonthly));
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Сезонные колебания расходов на "$category"',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1000,
                verticalInterval: 1,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index >= 0 && index < monthNames.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(monthNames[index], style: const TextStyle(fontSize: 12)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _currencyFormat.format(value).replaceAll(' ', ''),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: spots.length - 1.0,
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: avgLine,
                  isCurved: false,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            ),
            const SizedBox(width: 4),
            const Text('Фактические расходы'),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
            ),
            const SizedBox(width: 4),
            const Text('Среднее значение'),
          ],
        ),
      ],
    );
  }

  /// Возвращает название месяца по его номеру
  static String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Янв';
      case 2:
        return 'Фев';
      case 3:
        return 'Мар';
      case 4:
        return 'Апр';
      case 5:
        return 'Май';
      case 6:
        return 'Июн';
      case 7:
        return 'Июл';
      case 8:
        return 'Авг';
      case 9:
        return 'Сен';
      case 10:
        return 'Окт';
      case 11:
        return 'Ноя';
      case 12:
        return 'Дек';
      default:
        return '';
    }
  }
}

/// Виджет для отображения бейджа категории в круговой диаграмме
class _Badge extends StatelessWidget {
  final String category;
  final double size;
  final Color borderColor;

  const _Badge(this.category, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Center(
        child: Text(
          category.substring(0, 1).toUpperCase(),
          style: TextStyle(fontSize: size * 0.7, fontWeight: FontWeight.bold, color: borderColor),
        ),
      ),
    );
  }
}
