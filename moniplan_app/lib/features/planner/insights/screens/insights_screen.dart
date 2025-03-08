// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/payment/planner_bloc/_index.dart';
import 'package:moniplan_app/features/planner/insights/providers/insight_generator_impl.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:moniplan_app/features/planner/insights/widgets/_index.dart';
import 'package:moniplan_app/features/planner/insights/screens/_index.dart';

/// Экран для отображения инсайтов по планировщику
class InsightsScreen extends StatefulWidget {
  /// Планировщик, для которого отображаются инсайты
  final Planner planner;

  /// Конструктор
  const InsightsScreen({Key? key, required this.planner}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with SingleTickerProviderStateMixin {
  late final IInsightGenerator _insightGenerator;
  late final TabController _tabController;
  bool _isLoading = true;
  List<Insight> _allInsights = [];
  List<Insight> _retrospectiveInsights = [];
  List<Insight> _predictiveInsights = [];
  List<Insight> _combinedInsights = [];

  // Фильтры для инсайтов
  bool _showAnomalies = false;
  bool _showAmountAnomalies = true;
  bool _showTimeAnomalies = true;
  bool _showCategoryAnomalies = true;

  // Настройка для исключения аномалий из расчетов
  bool _excludeAnomaliesFromCalculations = true;

  @override
  void initState() {
    super.initState();
    _insightGenerator = AppDi.instance.get<IInsightGenerator>();
    _tabController = TabController(length: 3, vsync: this);
    _loadInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Создаем генератор инсайтов с текущими настройками
      final insightGenerator = InsightGeneratorImpl(analyzerFactory: AnalyzerFactoryImpl());

      // Добавляем небольшую задержку, чтобы показать индикатор загрузки
      // Это нужно, так как сложные вычисления могут занять время
      await Future.delayed(const Duration(milliseconds: 500));

      // Загружаем все типы инсайтов параллельно
      final futures = await Future.wait([
        insightGenerator.generateInsights(widget.planner),
        insightGenerator.generateRetrospectiveInsights(widget.planner),
        insightGenerator.generatePredictiveInsights(widget.planner),
        insightGenerator.generateCombinedInsights(widget.planner),
      ]);

      setState(() {
        _allInsights = futures[0];
        _retrospectiveInsights = futures[1];
        _predictiveInsights = futures[2];
        _combinedInsights = futures[3];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Показываем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить инсайты: $e'), backgroundColor: Colors.red),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Финансовые инсайты', style: context.text.displaySmall),
        actions: [
          // Кнопка фильтра аномалий
          if (!_isLoading && _hasAnomalies())
            IconButton(
              icon: Icon(Icons.filter_alt, color: _showAnomalies ? context.color.primary : null),
              tooltip: 'Фильтр аномалий',
              onPressed: _showFilterDialog,
            ),
          // Кнопка настроек
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки инсайтов',
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
            tooltip: 'Обновить инсайты',
          ),
        ],
        bottom:
            _isLoading
                ? null
                : TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.insights), text: 'Все инсайты'),
                    Tab(icon: Icon(Icons.history), text: 'Анализ прошлого'),
                    Tab(icon: Icon(Icons.update), text: 'Прогнозы'),
                  ],
                ),
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Анализируем твои финансы...', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      'Это может занять несколько секунд',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildInsightsList(_getFilteredInsights(_allInsights), showEmptyAll: true),
                  _buildInsightsList(
                    _getFilteredInsights(_retrospectiveInsights),
                    showEmptyRetrospective: true,
                  ),
                  _buildInsightsList(
                    _getFilteredInsights(_predictiveInsights),
                    showEmptyPredictive: true,
                  ),
                ],
              ),
    );
  }

  Widget _buildInsightsList(
    List<Insight> insights, {
    bool showEmptyAll = false,
    bool showEmptyRetrospective = false,
    bool showEmptyPredictive = false,
  }) {
    if (insights.isEmpty) {
      return _buildEmptyState(
        showEmptyAll: showEmptyAll,
        showEmptyRetrospective: showEmptyRetrospective,
        showEmptyPredictive: showEmptyPredictive,
      );
    }

    // Группируем инсайты по важности
    final criticalInsights =
        insights.where((i) => i.importance == InsightImportance.critical).toList();
    final highInsights = insights.where((i) => i.importance == InsightImportance.high).toList();
    final mediumInsights = insights.where((i) => i.importance == InsightImportance.medium).toList();
    final lowInsights = insights.where((i) => i.importance == InsightImportance.low).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Индикатор исключения аномалий
        if (_excludeAnomaliesFromCalculations && _hasAnomalies()) ...[
          _buildAnomalyExclusionIndicator(),
          const SizedBox(height: 16),
        ],

        // Секция с критическими инсайтами
        if (criticalInsights.isNotEmpty) ...[
          _buildSectionHeader('Требуют внимания', Icons.warning, Colors.red),
          ...criticalInsights.map(
            (insight) => InsightCard(
              insight: insight,
              planner: widget.planner,
              onTap: () => _navigateToInsightDetails(insight),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Секция с важными инсайтами
        if (highInsights.isNotEmpty) ...[
          _buildSectionHeader('Важные наблюдения', Icons.priority_high, Colors.orange),
          ...highInsights.map(
            (insight) => InsightCard(
              insight: insight,
              planner: widget.planner,
              onTap: () => _navigateToInsightDetails(insight),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Секция со средними инсайтами
        if (mediumInsights.isNotEmpty) ...[
          _buildSectionHeader('Полезные инсайты', Icons.lightbulb_outline, Colors.blue),
          ...mediumInsights.map(
            (insight) => InsightCard(
              insight: insight,
              planner: widget.planner,
              onTap: () => _navigateToInsightDetails(insight),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Секция с низкоприоритетными инсайтами
        if (lowInsights.isNotEmpty) ...[
          _buildSectionHeader('Информационные заметки', Icons.info_outline, Colors.green),
          ...lowInsights.map(
            (insight) => InsightCard(
              insight: insight,
              planner: widget.planner,
              onTap: () => _navigateToInsightDetails(insight),
            ),
          ),
        ],

        // Если нет инсайтов определенной важности, показываем сообщение
        if (insights.isNotEmpty && criticalInsights.isEmpty && highInsights.isEmpty)
          _buildNoHighPriorityMessage(context),
      ],
    );
  }

  /// Строит сообщение об отсутствии высокоприоритетных инсайтов
  Widget _buildNoHighPriorityMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Всё в порядке!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                ),
                const SizedBox(height: 4),
                Text(
                  'У тебя нет критических финансовых ситуаций, требующих немедленного внимания.',
                  style: TextStyle(color: context.color.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    bool showEmptyAll = false,
    bool showEmptyRetrospective = false,
    bool showEmptyPredictive = false,
  }) {
    String title;
    String message;
    IconData icon;

    if (showEmptyRetrospective) {
      title = 'Недостаточно данных для анализа прошлого';
      message =
          'Для анализа прошлых расходов нужно больше завершенных платежей. Добавь больше платежей и отметь их как выполненные.';
      icon = Icons.history;
    } else if (showEmptyPredictive) {
      title = 'Недостаточно данных для прогнозов';
      message =
          'Для создания прогнозов нужно больше запланированных платежей. Добавь больше платежей в свой планер.';
      icon = Icons.update;
    } else {
      title = 'Инсайты пока не доступны';
      message =
          'Для генерации инсайтов нужно больше данных. Добавь больше платежей в свой планер и отметь некоторые из них как выполненные.';
      icon = Icons.insights;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Добавить платежи'),
              onPressed: () {
                // Возвращаемся на экран планера для добавления платежей
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToInsightDetails(Insight insight) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InsightDataScreen(insight: insight, planner: widget.planner),
      ),
    );
  }

  /// Проверяет, есть ли аномалии в инсайтах
  bool _hasAnomalies() {
    return _allInsights.any(_isAnomalyInsight);
  }

  /// Проверяет, является ли инсайт аномалией
  bool _isAnomalyInsight(Insight insight) {
    return insight.title.contains('необычно крупные расходы') ||
        insight.title.contains('Платежи в необычное время') ||
        insight.title.contains('Необычные категории расходов');
  }

  /// Проверяет, является ли инсайт аномалией определенного типа
  bool _isSpecificAnomalyInsight(Insight insight, String titlePattern) {
    return insight.title.contains(titlePattern);
  }

  /// Возвращает отфильтрованный список инсайтов
  List<Insight> _getFilteredInsights(List<Insight> insights) {
    if (!_showAnomalies) {
      return insights;
    }

    return insights.where((insight) {
      // Если инсайт не является аномалией, всегда показываем его
      if (!_isAnomalyInsight(insight)) {
        return true;
      }

      // Фильтруем аномалии по типу
      if (_isSpecificAnomalyInsight(insight, 'необычно крупные расходы') && !_showAmountAnomalies) {
        return false;
      }

      if (_isSpecificAnomalyInsight(insight, 'Платежи в необычное время') && !_showTimeAnomalies) {
        return false;
      }

      if (_isSpecificAnomalyInsight(insight, 'Необычные категории расходов') &&
          !_showCategoryAnomalies) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Показывает диалог фильтрации аномалий
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Фильтр аномалий'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Включить фильтр аномалий'),
                      subtitle: const Text('Показывать только выбранные типы аномалий'),
                      value: _showAnomalies,
                      onChanged: (value) {
                        setState(() {
                          _showAnomalies = value;
                        });
                      },
                    ),
                    const Divider(),
                    const Text('Типы аномалий:', style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Крупные расходы'),
                      subtitle: const Text('Платежи, значительно превышающие средний размер'),
                      value: _showAmountAnomalies,
                      onChanged:
                          _showAnomalies
                              ? (value) {
                                setState(() {
                                  _showAmountAnomalies = value!;
                                });
                              }
                              : null,
                    ),
                    CheckboxListTile(
                      title: const Text('Необычное время'),
                      subtitle: const Text('Платежи, совершенные ночью или рано утром'),
                      value: _showTimeAnomalies,
                      onChanged:
                          _showAnomalies
                              ? (value) {
                                setState(() {
                                  _showTimeAnomalies = value!;
                                });
                              }
                              : null,
                    ),
                    CheckboxListTile(
                      title: const Text('Редкие категории'),
                      subtitle: const Text('Платежи в категориях, которые редко встречаются'),
                      value: _showCategoryAnomalies,
                      onChanged:
                          _showAnomalies
                              ? (value) {
                                setState(() {
                                  _showCategoryAnomalies = value!;
                                });
                              }
                              : null,
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Совет',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Чтобы исключить аномалии из расчетов других инсайтов, '
                                  'используй настройки инсайтов (иконка шестеренки).',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      this.setState(() {
                        // Обновляем состояние основного экрана
                      });
                    },
                    child: const Text('Применить'),
                  ),
                ],
              );
            },
          ),
    );
  }

  /// Показывает диалог настроек инсайтов
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.settings, size: 24),
                    const SizedBox(width: 12),
                    const Text('Настройки инсайтов'),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          'Обработка аномалий',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Исключать аномалии из расчетов'),
                        subtitle: const Text(
                          'Аномальные платежи не будут учитываться при расчете других инсайтов, '
                          'что позволит получить более точную картину обычных расходов',
                        ),
                        value: _excludeAnomaliesFromCalculations,
                        onChanged: (value) {
                          setState(() {
                            _excludeAnomaliesFromCalculations = value;
                          });
                        },
                      ),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          'Анализ итогов дня',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Новая функция!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Теперь приложение анализирует твои ежедневные расходы, '
                              'выявляя дни с максимальными тратами и закономерности в расходах по дням недели.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          'О функции инсайтов',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Инсайты помогают тебе лучше понимать свои финансы, выявляя закономерности, '
                              'аномалии и предлагая рекомендации по оптимизации расходов.',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Чем больше данных о платежах ты добавишь, тем точнее будут инсайты.',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Перезагружаем инсайты с новыми настройками
                      _loadInsights();
                    },
                    child: const Text('Применить'),
                  ),
                ],
              );
            },
          ),
    );
  }

  /// Строит индикатор исключения аномалий из расчетов
  Widget _buildAnomalyExclusionIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Аномалии исключены из расчетов',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  'Необычные платежи не учитываются при расчете инсайтов, '
                  'что дает более точную картину твоих обычных финансовых привычек.',
                  style: TextStyle(fontSize: 13, color: context.color.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка для отображения инсайта
class InsightCard extends StatelessWidget {
  /// Инсайт для отображения
  final Insight insight;

  /// Планер, для которого отображаются инсайты
  final Planner planner;

  /// Функция обратного вызова при нажатии на карточку
  final VoidCallback? onTap;

  /// Конструктор
  const InsightCard({Key? key, required this.insight, required this.planner, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final importanceColor = _getColorForImportance(insight.importance);
    final timeframe = _getTimeframe(insight);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: importanceColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с цветовой полосой важности
            Container(
              decoration: BoxDecoration(
                color: importanceColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _getIconForType(insight.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.color.onSurface,
                      ),
                    ),
                  ),
                  _getTimeframeIndicator(context, timeframe),
                ],
              ),
            ),

            // Основное содержимое
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание инсайта
                  Text(
                    insight.description,
                    style: TextStyle(fontSize: 15, color: context.color.onSurface),
                  ),

                  const SizedBox(height: 16),

                  // Ключевые факты
                  _buildKeyFacts(context),

                  // Связанные платежи (если есть)
                  if (insight.relatedPayments != null && insight.relatedPayments!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildRelatedPayments(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Строит блок с ключевыми фактами инсайта
  Widget _buildKeyFacts(BuildContext context) {
    final additionalData = insight.additionalData;
    if (additionalData == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> facts = [];

    // Добавляем факты в зависимости от типа инсайта
    switch (insight.type) {
      case InsightType.expenseStructure:
        if (additionalData.containsKey('name')) {
          facts.add(
            _buildFactItem(context, 'Категория', additionalData['name'].toString(), Icons.category),
          );
        }
        if (additionalData.containsKey('percentage')) {
          facts.add(
            _buildFactItem(
              context,
              'Доля расходов',
              '${additionalData['percentage']}%',
              Icons.pie_chart,
            ),
          );
        }
        if (additionalData.containsKey('amount')) {
          facts.add(
            _buildFactItem(
              context,
              'Сумма',
              '${_formatAmount(additionalData['amount'])} ₽',
              Icons.attach_money,
            ),
          );
        }
        break;

      case InsightType.pattern:
        if (additionalData.containsKey('weekdayName')) {
          facts.add(
            _buildFactItem(
              context,
              'День недели',
              additionalData['weekdayName'].toString(),
              Icons.calendar_today,
            ),
          );
        }
        if (additionalData.containsKey('amount')) {
          facts.add(
            _buildFactItem(
              context,
              'Сумма',
              '${_formatAmount(additionalData['amount'])} ₽',
              Icons.attach_money,
            ),
          );
        }
        if (additionalData.containsKey('frequency')) {
          facts.add(
            _buildFactItem(context, 'Частота', '${additionalData['frequency']} раз', Icons.repeat),
          );
        }
        if (additionalData.containsKey('periodicity')) {
          facts.add(
            _buildFactItem(
              context,
              'Периодичность',
              '${additionalData['periodicity']} дней',
              Icons.date_range,
            ),
          );
        }
        break;

      case InsightType.forecast:
        if (additionalData.containsKey('dailyAverage')) {
          facts.add(
            _buildFactItem(
              context,
              'Средний расход',
              '${_formatAmount(additionalData['dailyAverage'])} ₽/день',
              Icons.trending_up,
            ),
          );
        }
        if (additionalData.containsKey('monthlyProjection')) {
          facts.add(
            _buildFactItem(
              context,
              'Прогноз на месяц',
              '${_formatAmount(additionalData['monthlyProjection'])} ₽',
              Icons.calendar_month,
            ),
          );
        }
        if (additionalData.containsKey('percentChange')) {
          final change = additionalData['percentChange'];
          final isIncrease = change > 0;
          facts.add(
            _buildFactItem(
              context,
              'Изменение',
              '${isIncrease ? '+' : ''}${change}%',
              isIncrease ? Icons.trending_up : Icons.trending_down,
              color: isIncrease ? Colors.red : Colors.green,
            ),
          );
        }
        if (additionalData.containsKey('negativeBalanceProbability')) {
          facts.add(
            _buildFactItem(
              context,
              'Вероятность минуса',
              '${(additionalData['negativeBalanceProbability'] * 100).round()}%',
              Icons.warning,
              color: Colors.orange,
            ),
          );
        }
        break;

      case InsightType.optimization:
        if (additionalData.containsKey('totalExcluded')) {
          facts.add(
            _buildFactItem(
              context,
              'Потенциальная экономия',
              '${_formatAmount(additionalData['totalExcluded'])} ₽',
              Icons.savings,
              color: Colors.green,
            ),
          );
        }
        if (additionalData.containsKey('excludedCount')) {
          facts.add(
            _buildFactItem(
              context,
              'Количество платежей',
              '${additionalData['excludedCount']} шт.',
              Icons.payments,
            ),
          );
        }
        break;

      case InsightType.advice:
        if (additionalData.containsKey('liquidityRatio')) {
          facts.add(
            _buildFactItem(
              context,
              'Запас ликвидности',
              '${additionalData['liquidityRatio'].round()} дней',
              Icons.account_balance_wallet,
            ),
          );
        }
        break;

      default:
        // Для других типов инсайтов показываем общую информацию
        if (additionalData.containsKey('timeframe')) {
          final timeframeStr = additionalData['timeframe'] as String?;
          String readableTimeframe = 'Комбинированный';
          if (timeframeStr == 'retrospective') {
            readableTimeframe = 'Ретроспективный';
          } else if (timeframeStr == 'predictive') {
            readableTimeframe = 'Прогностический';
          }
          facts.add(_buildFactItem(context, 'Тип анализа', readableTimeframe, Icons.analytics));
        }
    }

    if (facts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ключевые факты:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: facts),
      ],
    );
  }

  /// Строит элемент факта
  Widget _buildFactItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.onSurface.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? context.color.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: context.color.onSurface.withOpacity(0.7)),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color ?? context.color.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Строит блок со связанными платежами
  Widget _buildRelatedPayments(BuildContext context) {
    final payments = insight.relatedPayments!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long, size: 16, color: context.color.primary),
            const SizedBox(width: 8),
            Text(
              'Связанные платежи:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: context.color.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.color.onSurface.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              ...payments
                  .take(3)
                  .map(
                    (payment) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            payment.type == PaymentType.expense
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: payment.type == PaymentType.expense ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              payment.details.name ?? "Без описания",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: context.color.onSurface),
                            ),
                          ),
                          Text(
                            '${payment.type == PaymentType.expense ? "-" : "+"}${_formatAmount(payment.details.normalizedMoney)} ₽',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  payment.type == PaymentType.expense ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (payments.length > 3)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'И еще ${payments.length - 3} платежей...',
                    style: TextStyle(
                      color: context.color.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Строит блок с рекомендациями
  Widget _buildRecommendations(BuildContext context) {
    String recommendation = '';
    IconData recommendationIcon = Icons.lightbulb_outline;
    Color recommendationColor = context.color.primary;

    // Формируем рекомендацию в зависимости от типа инсайта
    switch (insight.type) {
      case InsightType.expenseStructure:
        recommendation =
            'Обрати внимание на распределение расходов по категориям. Возможно, стоит пересмотреть бюджет на некоторые категории.';
        recommendationIcon = Icons.pie_chart;
        break;

      case InsightType.pattern:
        recommendation = 'Учитывай выявленные закономерности при планировании будущих расходов.';
        recommendationIcon = Icons.repeat;
        break;

      case InsightType.forecast:
        if (insight.importance == InsightImportance.critical ||
            insight.importance == InsightImportance.high) {
          recommendation =
              'Рассмотри возможность сокращения некоторых расходов или увеличения доходов в ближайшее время.';
          recommendationIcon = Icons.warning;
          recommendationColor = Colors.orange;
        } else {
          recommendation =
              'Продолжай следить за своими расходами и доходами, чтобы сохранить финансовую стабильность.';
          recommendationIcon = Icons.trending_up;
        }
        break;

      case InsightType.optimization:
        recommendation =
            'Рассмотри возможность отложить или отменить некоторые платежи для оптимизации бюджета.';
        recommendationIcon = Icons.build;
        break;

      case InsightType.advice:
        recommendation = 'Следуй этому совету для улучшения своего финансового положения.';
        recommendationIcon = Icons.lightbulb_outline;
        break;

      default:
        recommendation =
            'Используй этот инсайт для принятия более обоснованных финансовых решений.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: recommendationColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(recommendationIcon, color: recommendationColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Рекомендация:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: recommendationColor),
                ),
                const SizedBox(height: 4),
                Text(recommendation, style: TextStyle(color: context.color.onSurface)),
                if (insight.importance == InsightImportance.critical ||
                    insight.importance == InsightImportance.high) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.analytics_outlined, size: 16),
                        label: const Text('Подробнее'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onTap,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Возвращает индикатор временного признака
  Widget _getTimeframeIndicator(BuildContext context, InsightTimeframe timeframe) {
    String text;
    Color color;
    IconData iconData;

    switch (timeframe) {
      case InsightTimeframe.retrospective:
        text = 'На основе прошлых данных';
        color = Colors.blue;
        iconData = Icons.history;
        break;
      case InsightTimeframe.predictive:
        text = 'Прогноз на будущее';
        color = Colors.orange;
        iconData = Icons.update;
        break;
      case InsightTimeframe.combined:
        text = 'Комбинированный анализ';
        color = Colors.purple;
        iconData = Icons.sync;
        break;
    }

    return Tooltip(
      message: text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              timeframe == InsightTimeframe.retrospective
                  ? 'Прошлое'
                  : timeframe == InsightTimeframe.predictive
                  ? 'Будущее'
                  : 'Комбо',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
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

  String _formatAmount(num amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
  }

  /// Получает временной признак инсайта
  InsightTimeframe _getTimeframe(Insight insight) {
    if (insight.timeframe != InsightTimeframe.combined) {
      return insight.timeframe;
    }

    if (insight.additionalData != null && insight.additionalData!.containsKey('timeframe')) {
      final timeframeStr = insight.additionalData!['timeframe'] as String?;
      if (timeframeStr == 'retrospective') {
        return InsightTimeframe.retrospective;
      } else if (timeframeStr == 'predictive') {
        return InsightTimeframe.predictive;
      }
    }
    return InsightTimeframe.combined;
  }

  Widget _getIconForType(InsightType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case InsightType.expenseStructure:
        iconData = Icons.pie_chart;
        color = Colors.purple;
        break;
      case InsightType.pattern:
        iconData = Icons.repeat;
        color = Colors.blue;
        break;
      case InsightType.forecast:
        iconData = Icons.trending_up;
        color = Colors.orange;
        break;
      case InsightType.comparison:
        iconData = Icons.compare_arrows;
        color = Colors.green;
        break;
      case InsightType.optimization:
        iconData = Icons.build;
        color = Colors.amber;
        break;
      case InsightType.goal:
        iconData = Icons.flag;
        color = Colors.red;
        break;
      case InsightType.advice:
        iconData = Icons.lightbulb_outline;
        color = Colors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
