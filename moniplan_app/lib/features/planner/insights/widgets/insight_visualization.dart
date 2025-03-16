// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:moniplan_app/features/planner/insights/screens/_index.dart';

/// Виджет для визуализации инсайтов
class InsightVisualization extends StatelessWidget {
  /// Инсайт для визуализации
  final Insight insight;

  /// Планер, для которого отображаются инсайты
  final Planner planner;

  /// Конструктор
  const InsightVisualization({super.key, required this.insight, required this.planner});

  @override
  Widget build(BuildContext context) {
    // Выбираем тип визуализации в зависимости от типа инсайта
    final Widget visualization = switch (insight.type) {
      InsightType.expenseStructure => _buildExpenseStructureChart(context),
      InsightType.pattern => _buildPatternChart(context),
      InsightType.forecast => _buildForecastChart(context),
      InsightType.comparison => _buildComparisonChart(context),
      _ => const SizedBox.shrink(), // Для остальных типов пока нет визуализации
    };

    // Если нет визуализации, возвращаем пустой виджет
    if (visualization is SizedBox) {
      return visualization;
    }

    // Оборачиваем визуализацию в интерактивный контейнер
    return GestureDetector(
      onTap: () => _showFullScreenVisualization(context, visualization),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            visualization,
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 14,
                    color: context.color.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Нажмите для увеличения',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.color.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Показывает визуализацию в полноэкранном режиме
  void _showFullScreenVisualization(BuildContext context, Widget visualization) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: context.color.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Детальный анализ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.color.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          // Добавляем кнопку для экспорта
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => _shareVisualization(context),
                            tooltip: 'Поделиться',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'Закрыть',
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Добавляем информацию о периоде анализа
                  _buildAnalysisPeriodInfo(context),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300, // Увеличенная высота для лучшей детализации
                    child: visualization,
                  ),
                  const SizedBox(height: 16),
                  // Добавляем кнопки для переключения между типами визуализаций
                  _buildVisualizationOptions(context),
                  const SizedBox(height: 16),
                  // Добавляем объяснение вывода
                  _buildInsightExplanation(context),
                  const SizedBox(height: 16),
                  // Добавляем кнопку для просмотра деталей расчета
                  _buildCalculationDetailsButton(context),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Делится визуализацией
  void _shareVisualization(BuildContext context) {
    // Здесь будет реализация экспорта визуализации
    // Пока просто показываем сообщение
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция экспорта будет доступна в будущих версиях'),
        duration: Duration(seconds: 2),
      ),
    );

    // Показываем диалог с опциями экспорта
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Поделиться инсайтом',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildShareOption(
                  context,
                  Icons.image,
                  'Сохранить как изображение',
                  'Сохранить визуализацию как PNG-изображение',
                  () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Сохранение как изображение будет доступно в будущих версиях',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildShareOption(
                  context,
                  Icons.picture_as_pdf,
                  'Экспорт в PDF',
                  'Сохранить инсайт с визуализацией в PDF-файл',
                  () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Экспорт в PDF будет доступен в будущих версиях'),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildShareOption(
                  context,
                  Icons.text_snippet,
                  'Экспорт данных',
                  'Сохранить данные в CSV-файл для дальнейшего анализа',
                  () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Экспорт данных будет доступен в будущих версиях'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// Строит опцию для экспорта
  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.color.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: context.color.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.color.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.color.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// Строит информацию о периоде анализа
  Widget _buildAnalysisPeriodInfo(BuildContext context) {
    // Определяем период анализа на основе связанных платежей
    if (insight.relatedPayments == null || insight.relatedPayments!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Сортируем платежи по дате
    final payments = List<Payment>.from(insight.relatedPayments!)
      ..sort((a, b) => a.date.compareTo(b.date));

    final DateTime startDate = payments.first.date;
    final DateTime endDate = payments.last.date;

    // Форматируем даты
    final startDateStr = '${startDate.day}.${startDate.month}.${startDate.year}';
    final endDateStr = '${endDate.day}.${endDate.month}.${endDate.year}';

    // Определяем тип анализа
    String analysisType;
    Color typeColor;
    switch (insight.timeframe) {
      case InsightTimeframe.retrospective:
        analysisType = 'Ретроспективный анализ';
        typeColor = Colors.blue;
        break;
      case InsightTimeframe.predictive:
        analysisType = 'Прогностический анализ';
        typeColor = Colors.orange;
        break;
      case InsightTimeframe.combined:
        analysisType = 'Комбинированный анализ';
        typeColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, size: 16, color: typeColor),
              const SizedBox(width: 8),
              Text(analysisType, style: TextStyle(fontWeight: FontWeight.bold, color: typeColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Период: $startDateStr - $endDateStr',
            style: TextStyle(fontSize: 12, color: context.color.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 4),
          Text(
            'Количество платежей: ${insight.relatedPayments!.length}',
            style: TextStyle(fontSize: 12, color: context.color.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  /// Строит объяснение вывода
  Widget _buildInsightExplanation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: _getColorForImportance(insight.importance),
              ),
              const SizedBox(width: 8),
              Text(
                'Объяснение',
                style: TextStyle(fontWeight: FontWeight.bold, color: context.color.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.description, style: TextStyle(fontSize: 14, color: context.color.onSurface)),
          const SizedBox(height: 8),
          // Добавляем конкретные данные, которые привели к выводу
          _buildConcreteData(context),
        ],
      ),
    );
  }

  /// Строит конкретные данные, которые привели к выводу
  Widget _buildConcreteData(BuildContext context) {
    // Получаем конкретные данные из additionalData, если они есть
    final additionalData = insight.additionalData;
    if (additionalData == null) {
      return const SizedBox.shrink();
    }

    // Создаем список конкретных фактов
    final List<Widget> facts = [];

    // Добавляем факты в зависимости от типа инсайта
    switch (insight.type) {
      case InsightType.expenseStructure:
        if (additionalData.containsKey('largest_category')) {
          facts.add(
            _buildFactItem(
              'Самая крупная категория расходов: ${additionalData['largest_category']} (${_formatAmount(additionalData['largest_amount'] ?? 0)} ₽)',
            ),
          );
        }
        if (additionalData.containsKey('category_percentage')) {
          facts.add(
            _buildFactItem('Доля от общих расходов: ${additionalData['category_percentage']}%'),
          );
        }
        break;
      case InsightType.pattern:
        if (additionalData.containsKey('pattern_type')) {
          facts.add(
            _buildFactItem('Тип обнаруженного паттерна: ${additionalData['pattern_type']}'),
          );
        }
        if (additionalData.containsKey('confidence')) {
          facts.add(_buildFactItem('Уверенность в паттерне: ${additionalData['confidence']}%'));
        }
        break;
      case InsightType.forecast:
        if (additionalData.containsKey('forecast_change')) {
          final change = additionalData['forecast_change'];
          final isIncrease = change > 0;
          facts.add(
            _buildFactItem(
              'Прогнозируемое ${isIncrease ? 'увеличение' : 'уменьшение'} расходов: ${change.abs()}%',
            ),
          );
        }
        if (additionalData.containsKey('forecast_confidence')) {
          facts.add(_buildFactItem('Точность прогноза: ${additionalData['forecast_confidence']}%'));
        }
        break;
      case InsightType.comparison:
        if (additionalData.containsKey('comparison_period')) {
          facts.add(_buildFactItem('Период сравнения: ${additionalData['comparison_period']}'));
        }
        if (additionalData.containsKey('change_percentage')) {
          final change = additionalData['change_percentage'];
          final isIncrease = change > 0;
          facts.add(
            _buildFactItem(
              '${isIncrease ? 'Увеличение' : 'Уменьшение'} расходов: ${change.abs()}%',
            ),
          );
        }
        break;
      default:
        // Для остальных типов инсайтов просто выводим все данные
        additionalData.forEach((key, value) {
          if (key != 'timeframe') {
            facts.add(_buildFactItem('$key: $value'));
          }
        });
    }

    // Если нет конкретных фактов, возвращаем заглушку
    if (facts.isEmpty) {
      // Создаем демо-факты для наглядности
      switch (insight.type) {
        case InsightType.expenseStructure:
          facts.add(_buildFactItem('Категория "Продукты" составляет 35% ваших расходов'));
          facts.add(_buildFactItem('Это на 10% больше, чем в прошлом месяце'));
          break;
        case InsightType.pattern:
          facts.add(_buildFactItem('Обнаружены регулярные расходы в категории "Развлечения"'));
          facts.add(_buildFactItem('Частота: еженедельно по пятницам'));
          break;
        case InsightType.forecast:
          facts.add(_buildFactItem('Прогноз основан на данных за последние 3 месяца'));
          facts.add(_buildFactItem('Учтены сезонные колебания расходов'));
          break;
        case InsightType.comparison:
          facts.add(_buildFactItem('Сравнение с аналогичным периодом прошлого года'));
          facts.add(_buildFactItem('Учтена инфляция: 7%'));
          break;
        default:
          facts.add(_buildFactItem('Анализ основан на ваших платежах за выбранный период'));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Конкретные факты:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        ...facts,
      ],
    );
  }

  /// Строит элемент факта
  Widget _buildFactItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  /// Строит кнопку для просмотра деталей расчета
  Widget _buildCalculationDetailsButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.calculate, size: 16),
          label: const Text('Посмотреть детали расчета'),
          onPressed: () => _showCalculationDetails(context),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.data_array, size: 16),
          label: const Text('Исходные данные'),
          onPressed: () => _showSourceData(context),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  /// Показывает детали расчета
  void _showCalculationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: context.color.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Детали расчета',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.color.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Закрыть',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Здесь будут детали расчета
                  _buildCalculationSteps(context),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Закрыть'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Показывает экран с исходными данными
  void _showSourceData(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InsightDataScreen(insight: insight, planner: planner),
      ),
    );
  }

  /// Строит шаги расчета
  Widget _buildCalculationSteps(BuildContext context) {
    // Здесь можно добавить реальные шаги расчета из additionalData
    // Пока добавим демо-шаги для наглядности
    final List<Widget> steps = [];

    switch (insight.type) {
      case InsightType.expenseStructure:
        steps.add(
          _buildCalculationStep(
            1,
            'Сбор данных',
            'Собраны все расходы за период ${_getAnalysisPeriod()}',
          ),
        );
        steps.add(
          _buildCalculationStep(
            2,
            'Группировка по категориям',
            'Расходы сгруппированы по тегам и категориям',
          ),
        );
        steps.add(
          _buildCalculationStep(
            3,
            'Расчет долей',
            'Для каждой категории рассчитана доля от общей суммы расходов',
          ),
        );
        steps.add(
          _buildCalculationStep(
            4,
            'Выявление крупнейших категорий',
            'Определены категории с наибольшей долей расходов',
          ),
        );
        break;
      case InsightType.pattern:
        steps.add(
          _buildCalculationStep(
            1,
            'Сбор данных',
            'Собраны все платежи за период ${_getAnalysisPeriod()}',
          ),
        );
        steps.add(
          _buildCalculationStep(2, 'Временной анализ', 'Проанализированы даты и суммы платежей'),
        );
        steps.add(
          _buildCalculationStep(
            3,
            'Поиск закономерностей',
            'Выявлены повторяющиеся платежи и их периодичность',
          ),
        );
        steps.add(
          _buildCalculationStep(
            4,
            'Оценка уверенности',
            'Рассчитана статистическая значимость обнаруженных паттернов',
          ),
        );
        break;
      case InsightType.forecast:
        steps.add(
          _buildCalculationStep(
            1,
            'Сбор исторических данных',
            'Собраны данные о расходах за предыдущие периоды',
          ),
        );
        steps.add(
          _buildCalculationStep(2, 'Анализ тренда', 'Выявлен общий тренд изменения расходов'),
        );
        steps.add(
          _buildCalculationStep(3, 'Учет сезонности', 'Учтены сезонные колебания расходов'),
        );
        steps.add(
          _buildCalculationStep(
            4,
            'Построение прогноза',
            'Сформирован прогноз на основе исторических данных и выявленных закономерностей',
          ),
        );
        break;
      case InsightType.comparison:
        steps.add(
          _buildCalculationStep(
            1,
            'Выбор периодов для сравнения',
            'Текущий период: ${_getAnalysisPeriod()}, Предыдущий период: аналогичный период прошлого года',
          ),
        );
        steps.add(
          _buildCalculationStep(
            2,
            'Нормализация данных',
            'Учтена инфляция и другие факторы для корректного сравнения',
          ),
        );
        steps.add(
          _buildCalculationStep(
            3,
            'Расчет изменений',
            'Рассчитаны абсолютные и относительные изменения по категориям',
          ),
        );
        steps.add(
          _buildCalculationStep(
            4,
            'Выявление значимых изменений',
            'Определены категории с наиболее существенными изменениями',
          ),
        );
        break;
      default:
        steps.add(
          _buildCalculationStep(
            1,
            'Сбор данных',
            'Собраны все платежи за период ${_getAnalysisPeriod()}',
          ),
        );
        steps.add(
          _buildCalculationStep(
            2,
            'Анализ данных',
            'Проведен анализ платежей по различным параметрам',
          ),
        );
        steps.add(
          _buildCalculationStep(
            3,
            'Формирование выводов',
            'На основе анализа сформированы выводы и рекомендации',
          ),
        );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: steps);
  }

  /// Строит шаг расчета
  Widget _buildCalculationStep(int stepNumber, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Получает период анализа в виде строки
  String _getAnalysisPeriod() {
    if (insight.relatedPayments == null || insight.relatedPayments!.isEmpty) {
      return 'последние 3 месяца';
    }

    // Сортируем платежи по дате
    final payments = List<Payment>.from(insight.relatedPayments!)
      ..sort((a, b) => a.date.compareTo(b.date));

    final DateTime startDate = payments.first.date;
    final DateTime endDate = payments.last.date;

    // Форматируем даты
    final startDateStr = '${startDate.day}.${startDate.month}.${startDate.year}';
    final endDateStr = '${endDate.day}.${endDate.month}.${endDate.year}';

    return '$startDateStr - $endDateStr';
  }

  /// Возвращает цвет в зависимости от важности инсайта
  Color _getColorForImportance(InsightImportance importance) {
    switch (importance) {
      case InsightImportance.critical:
        return Colors.red;
      case InsightImportance.high:
        return Colors.orange;
      case InsightImportance.medium:
        return Colors.blue;
      case InsightImportance.low:
        return Colors.green;
    }
  }

  /// Строит опции для переключения между типами визуализаций
  Widget _buildVisualizationOptions(BuildContext context) {
    // Получаем доступные типы визуализаций для данного инсайта
    final List<Widget> options = [];

    // Добавляем опции в зависимости от типа инсайта
    switch (insight.type) {
      case InsightType.expenseStructure:
        options.add(_buildOptionChip(context, 'Круговая диаграмма', Icons.pie_chart));
        options.add(_buildOptionChip(context, 'Столбчатая диаграмма', Icons.bar_chart));
        break;
      case InsightType.pattern:
        options.add(_buildOptionChip(context, 'Линейный график', Icons.show_chart));
        options.add(_buildOptionChip(context, 'Гистограмма', Icons.stacked_bar_chart));
        break;
      case InsightType.forecast:
        options.add(_buildOptionChip(context, 'Прогноз', Icons.trending_up));
        options.add(_buildOptionChip(context, 'Монте-Карло', Icons.blur_on));
        break;
      case InsightType.comparison:
        options.add(_buildOptionChip(context, 'По месяцам', Icons.date_range));
        options.add(_buildOptionChip(context, 'По категориям', Icons.category));
        break;
      default:
        return const SizedBox.shrink();
    }

    return Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: options);
  }

  /// Строит чип для выбора типа визуализации
  Widget _buildOptionChip(BuildContext context, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {
        // Здесь можно добавить логику для переключения типа визуализации
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Переключение на "$label" будет доступно в будущих версиях'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  /// Строит круговую диаграмму для структуры расходов
  Widget _buildExpenseStructureChart(BuildContext context) {
    // Если нет связанных платежей, возвращаем пустой виджет
    if (insight.relatedPayments == null || insight.relatedPayments!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Группируем платежи по тегам
    final Map<String, double> tagTotals = {};
    for (final payment in insight.relatedPayments!) {
      if (payment.details.type == PaymentType.expense) {
        for (final tag in payment.details.tags) {
          final amount = payment.details.normalizedMoney.abs().toDouble();
          tagTotals[tag] = (tagTotals[tag] ?? 0) + amount;
        }
      }
    }

    // Если нет тегов, возвращаем пустой виджет
    if (tagTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Сортируем теги по сумме (от большей к меньшей)
    final sortedEntries = tagTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Ограничиваем количество секторов (остальные объединяем в "Другое")
    final int maxSectors = 5;
    final List<MapEntry<String, double>> topEntries;
    double otherTotal = 0;

    if (sortedEntries.length > maxSectors) {
      topEntries = sortedEntries.sublist(0, maxSectors);
      for (int i = maxSectors; i < sortedEntries.length; i++) {
        otherTotal += sortedEntries[i].value;
      }
    } else {
      topEntries = sortedEntries;
    }

    // Создаем секции для круговой диаграммы
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    double total = 0;
    for (final entry in topEntries) {
      total += entry.value;
    }
    total += otherTotal;

    for (int i = 0; i < topEntries.length; i++) {
      final entry = topEntries[i];
      final percentage = (entry.value / total) * 100;

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Добавляем сектор "Другое", если есть
    if (otherTotal > 0) {
      final percentage = (otherTotal / total) * 100;
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: otherTotal,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(sections: sections, centerSpaceRadius: 40, sectionsSpace: 2),
          ),
        ),
        const SizedBox(height: 16),
        // Легенда
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < topEntries.length; i++)
              _buildLegendItem(
                topEntries[i].key,
                colors[i % colors.length],
                '${_formatAmount(topEntries[i].value)} ₽',
              ),
            if (otherTotal > 0)
              _buildLegendItem('Другое', Colors.grey, '${_formatAmount(otherTotal)} ₽'),
          ],
        ),
      ],
    );
  }

  /// Строит график для паттернов расходов
  Widget _buildPatternChart(BuildContext context) {
    // Если нет связанных платежей, возвращаем пустой виджет
    if (insight.relatedPayments == null || insight.relatedPayments!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Сортируем платежи по дате
    final payments = List<Payment>.from(insight.relatedPayments!)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Группируем платежи по дням
    final Map<DateTime, double> dailyExpenses = {};
    for (final payment in payments) {
      if (payment.details.type == PaymentType.expense) {
        final date = DateTime(payment.date.year, payment.date.month, payment.date.day);
        final amount = payment.details.normalizedMoney.abs().toDouble();
        dailyExpenses[date] = (dailyExpenses[date] ?? 0) + amount;
      }
    }

    // Если нет данных, возвращаем пустой виджет
    if (dailyExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Сортируем дни
    final sortedDays = dailyExpenses.keys.toList()..sort();

    // Создаем точки для графика
    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      spots.add(FlSpot(i.toDouble(), dailyExpenses[day]!));
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Динамика расходов',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < sortedDays.length) {
                        final day = sortedDays[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${day.day}/${day.month}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.2)),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => context.color.surface,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isHistory = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${_formatAmount(spot.y)} ₽',
                        TextStyle(
                          color: isHistory ? Colors.blue : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Строит график для прогнозов
  Widget _buildForecastChart(BuildContext context) {
    // Получаем данные из additionalData, если они есть
    final additionalData = insight.additionalData;
    if (additionalData == null || !additionalData.containsKey('forecast_data')) {
      // Если нет данных для прогноза, создаем демо-данные
      return _buildDemoForecastChart(context);
    }

    return _buildDemoForecastChart(context);
  }

  /// Строит демо-график для прогнозов
  Widget _buildDemoForecastChart(BuildContext context) {
    // Создаем демо-данные для прогноза
    final now = DateTime.now();
    final List<FlSpot> historicalSpots = [];
    final List<FlSpot> forecastSpots = [];

    // Исторические данные (последние 7 дней)
    for (int i = 0; i < 7; i++) {
      final value = 5000.0 + math.Random().nextDouble() * 3000;
      historicalSpots.add(FlSpot(i.toDouble(), value));
    }

    // Прогнозные данные (следующие 7 дней)
    double lastValue = historicalSpots.last.y;
    for (int i = 7; i < 14; i++) {
      // Добавляем тренд и случайность
      final trend = math.Random().nextDouble() * 500 - 250;
      lastValue += trend;
      forecastSpots.add(FlSpot(i.toDouble(), lastValue));
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Прогноз расходов',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 2 == 0) {
                        final date = now.add(Duration(days: value.toInt() - 7));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Исторические данные
                LineChartBarData(
                  spots: historicalSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.2)),
                ),
                // Прогнозные данные
                LineChartBarData(
                  spots: forecastSpots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  dashArray: [5, 5], // Пунктирная линия для прогноза
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => context.color.surface,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isHistory = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${_formatAmount(spot.y)} ₽',
                        TextStyle(
                          color: isHistory ? Colors.blue : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Легенда
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Исторические данные', Colors.blue, ''),
            const SizedBox(width: 16),
            _buildLegendItem('Прогноз', Colors.orange, ''),
          ],
        ),
      ],
    );
  }

  /// Строит график для сравнения
  Widget _buildComparisonChart(BuildContext context) {
    // Если нет связанных платежей, возвращаем пустой виджет
    if (insight.relatedPayments == null || insight.relatedPayments!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Группируем платежи по месяцам
    final Map<String, double> monthlyExpenses = {};
    for (final payment in insight.relatedPayments!) {
      if (payment.details.type == PaymentType.expense) {
        final month = '${payment.date.month}/${payment.date.year}';
        final amount = payment.details.normalizedMoney.abs().toDouble();
        monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + amount;
      }
    }

    // Если нет данных, возвращаем пустой виджет
    if (monthlyExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Сортируем месяцы
    final sortedMonths =
        monthlyExpenses.keys.toList()..sort((a, b) {
          final aParts = a.split('/');
          final bParts = b.split('/');
          final aYear = int.parse(aParts[1]);
          final bYear = int.parse(bParts[1]);
          if (aYear != bYear) return aYear.compareTo(bYear);
          return int.parse(aParts[0]).compareTo(int.parse(bParts[0]));
        });

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Сравнение по месяцам',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: monthlyExpenses.values.reduce(math.max) * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => context.color.surface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${_formatAmount(rod.toY)} ₽',
                      TextStyle(color: context.color.primary, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                        final month = sortedMonths[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(month, style: const TextStyle(fontSize: 10)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: List.generate(
                sortedMonths.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: monthlyExpenses[sortedMonths[index]]!,
                      color: context.color.primary,
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Строит элемент легенды
  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  /// Форматирует сумму для отображения
  String _formatAmount(num amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
  }
}
