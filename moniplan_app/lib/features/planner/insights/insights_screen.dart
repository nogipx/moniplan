// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Экран для отображения инсайтов по планировщику
class InsightsScreen extends StatefulWidget {
  /// Планировщик, для которого отображаются инсайты
  final Planner planner;

  /// Конструктор
  const InsightsScreen({Key? key, required this.planner}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late final InsightGenerator _insightGenerator;
  bool _isLoading = true;
  List<Insight> _insights = [];

  @override
  void initState() {
    super.initState();
    _insightGenerator = AppDi.instance.get<InsightGenerator>();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Добавляем небольшую задержку, чтобы показать индикатор загрузки
      // Это нужно, так как сложные вычисления могут занять время
      await Future.delayed(const Duration(milliseconds: 500));

      final insights = await _insightGenerator.generateInsights(widget.planner, limit: 10);
      setState(() {
        _insights = insights;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Умные инсайты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
            tooltip: 'Обновить инсайты',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Анализирую твои финансы...',
            style: TextStyle(fontSize: 16, color: context.color.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            'Это может занять некоторое время',
            style: TextStyle(fontSize: 14, color: context.color.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_insights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Пока недостаточно данных для инсайтов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте больше платежей, чтобы получить полезные рекомендации',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Вернуться к планировщику'),
            ),
          ],
        ),
      );
    }

    // Группируем инсайты по важности
    final criticalInsights =
        _insights.where((i) => i.importance == InsightImportance.critical).toList();
    final highInsights = _insights.where((i) => i.importance == InsightImportance.high).toList();
    final mediumInsights =
        _insights.where((i) => i.importance == InsightImportance.medium).toList();
    final lowInsights = _insights.where((i) => i.importance == InsightImportance.low).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (criticalInsights.isNotEmpty) ...[
          _buildInsightSection('Требуют внимания', criticalInsights, Colors.red),
          const SizedBox(height: 16),
        ],
        if (highInsights.isNotEmpty) ...[
          _buildInsightSection('Важные инсайты', highInsights, Colors.orange),
          const SizedBox(height: 16),
        ],
        if (mediumInsights.isNotEmpty) ...[
          _buildInsightSection('Полезные наблюдения', mediumInsights, Colors.blue),
          const SizedBox(height: 16),
        ],
        if (lowInsights.isNotEmpty) ...[
          _buildInsightSection('Информация', lowInsights, Colors.green),
        ],
      ],
    );
  }

  Widget _buildInsightSection(String title, List<Insight> insights, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.color.onSurface,
                ),
              ),
            ],
          ),
        ),
        ...insights.map((insight) => InsightCard(insight: insight)),
      ],
    );
  }
}

/// Карточка для отображения инсайта
class InsightCard extends StatelessWidget {
  /// Инсайт для отображения
  final Insight insight;

  /// Конструктор
  const InsightCard({Key? key, required this.insight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getColorForImportance(insight.importance).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getIconForType(insight.type),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _getImportanceIndicator(insight.importance),
              ],
            ),
            const SizedBox(height: 12),
            Text(insight.description, style: const TextStyle(fontSize: 16)),
            if (insight.relatedPayments != null && insight.relatedPayments!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Связанные платежи:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...insight.relatedPayments!
                  .take(3)
                  .map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${payment.details.name ?? "Без описания"}: ${_formatAmount(payment.details.normalizedMoney)} руб.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if ((insight.relatedPayments?.length ?? 0) > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'И еще ${insight.relatedPayments!.length - 3} платежей...',
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ),
            ],
            // Добавляем кнопку действия, если инсайт требует внимания
            if (insight.importance == InsightImportance.critical ||
                insight.importance == InsightImportance.high) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Здесь можно добавить действие по инсайту
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Действие по инсайту "${insight.title}" будет доступно в будущих версиях',
                          ),
                        ),
                      );
                    },
                    child: const Text('Что делать?'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getIconForType(InsightType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case InsightType.expenseStructure:
        iconData = Icons.pie_chart;
        color = Colors.blue;
        break;
      case InsightType.pattern:
        iconData = Icons.repeat;
        color = Colors.purple;
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _getImportanceIndicator(InsightImportance importance) {
    Color color = _getColorForImportance(importance);
    String label;

    switch (importance) {
      case InsightImportance.critical:
        label = 'Критично';
        break;
      case InsightImportance.high:
        label = 'Важно';
        break;
      case InsightImportance.medium:
        label = 'Полезно';
        break;
      case InsightImportance.low:
        label = 'Инфо';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

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
    return amount.toStringAsFixed(0);
  }
}
