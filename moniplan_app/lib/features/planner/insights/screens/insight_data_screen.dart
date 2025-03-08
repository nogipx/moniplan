// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Экран для отображения данных, использованных при анализе инсайта
class InsightDataScreen extends StatelessWidget {
  /// Инсайт для отображения
  final Insight insight;

  /// Планер, для которого отображаются инсайты
  final Planner planner;

  /// Конструктор
  const InsightDataScreen({Key? key, required this.insight, required this.planner})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final importanceColor = _getColorForImportance(insight.importance);
    final timeframe = _getTimeframe(insight);

    return Scaffold(
      appBar: AppBar(
        title: Text('Данные анализа', style: context.text.displayMedium),
        backgroundColor: importanceColor.withOpacity(0.1),
        foregroundColor: importanceColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с информацией об инсайте
              _buildHeader(context, importanceColor, timeframe),

              // Основное содержимое
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Описание инсайта
                    _buildDescription(context),

                    const SizedBox(height: 24),

                    // Данные, использованные для анализа
                    _buildAnalysisData(context),

                    const SizedBox(height: 24),

                    // Связанные платежи
                    if (insight.relatedPayments != null && insight.relatedPayments!.isNotEmpty)
                      _buildRelatedPayments(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Строит заголовок с информацией об инсайте
  Widget _buildHeader(BuildContext context, Color importanceColor, InsightTimeframe timeframe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: importanceColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getIconForType(insight.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeTitle(insight.type),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: importanceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                context,
                _getImportanceText(insight.importance),
                _getImportanceIcon(insight.importance),
                importanceColor,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                context,
                _getTimeframeText(timeframe),
                _getTimeframeIcon(timeframe),
                _getTimeframeColor(timeframe),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Строит описание инсайта
  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Что это значит?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(insight.description, style: TextStyle(fontSize: 15, color: context.color.onSurface)),
      ],
    );
  }

  /// Строит блок с данными, использованными для анализа
  Widget _buildAnalysisData(BuildContext context) {
    final additionalData = insight.additionalData;
    if (additionalData == null || additionalData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Исключаем служебные поля
    final excludedKeys = ['timeframe'];
    final filteredData = Map.fromEntries(
      additionalData.entries.where((entry) => !excludedKeys.contains(entry.key)),
    );

    if (filteredData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Данные анализа',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.color.onSurface.withOpacity(0.1)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredData.length,
            separatorBuilder:
                (context, index) =>
                    Divider(height: 1, color: context.color.onSurface.withOpacity(0.1)),
            itemBuilder: (context, index) {
              final entry = filteredData.entries.elementAt(index);
              return _buildDataItem(context, entry.key, entry.value);
            },
          ),
        ),
      ],
    );
  }

  /// Строит элемент данных
  Widget _buildDataItem(BuildContext context, String key, dynamic value) {
    // Форматируем ключ для отображения
    final formattedKey =
        key
            .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)!.toLowerCase()}')
            .replaceAll('_', ' ')
            .trim()
            .capitalize();

    // Форматируем значение для отображения
    String formattedValue;
    if (value is num) {
      if (key.contains('percentage') || key.contains('ratio')) {
        formattedValue = '${value.toStringAsFixed(1)}%';
      } else if (key.contains('amount') || key.contains('budget') || key.contains('money')) {
        formattedValue = '${_formatAmount(value)} ₽';
      } else {
        formattedValue = value.toString();
      }
    } else {
      formattedValue = value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              formattedKey,
              style: TextStyle(fontWeight: FontWeight.bold, color: context.color.onSurface),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(formattedValue, style: TextStyle(color: context.color.onSurface)),
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
        Text(
          'Связанные платежи',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.color.onSurface.withOpacity(0.1)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder:
                (context, index) =>
                    Divider(height: 1, color: context.color.onSurface.withOpacity(0.1)),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildPaymentItem(context, payment);
            },
          ),
        ),
      ],
    );
  }

  /// Строит элемент платежа
  Widget _buildPaymentItem(BuildContext context, Payment payment) {
    final isExpense = payment.type == PaymentType.expense;
    final color = isExpense ? Colors.red : Colors.green;
    final icon = isExpense ? Icons.arrow_upward : Icons.arrow_downward;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.details.name ?? 'Без названия',
                  style: TextStyle(fontWeight: FontWeight.bold, color: context.color.onSurface),
                ),
                Text(
                  _formatDate(payment.date),
                  style: TextStyle(fontSize: 12, color: context.color.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${_formatAmount(payment.details.normalizedMoney)} ₽',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  /// Строит информационный чип
  Widget _buildInfoChip(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  /// Получает заголовок для типа инсайта
  String _getTypeTitle(InsightType type) {
    switch (type) {
      case InsightType.expenseStructure:
        return 'Структура расходов';
      case InsightType.pattern:
        return 'Выявленный паттерн';
      case InsightType.forecast:
        return 'Финансовый прогноз';
      case InsightType.comparison:
        return 'Сравнительный анализ';
      case InsightType.optimization:
        return 'Оптимизация бюджета';
      case InsightType.goal:
        return 'Финансовая цель';
      case InsightType.advice:
        return 'Финансовый совет';
    }
  }

  /// Получает текст для важности инсайта
  String _getImportanceText(InsightImportance importance) {
    switch (importance) {
      case InsightImportance.critical:
        return 'Критично';
      case InsightImportance.high:
        return 'Важно';
      case InsightImportance.medium:
        return 'Полезно';
      case InsightImportance.low:
        return 'Информация';
    }
  }

  /// Получает иконку для важности инсайта
  IconData _getImportanceIcon(InsightImportance importance) {
    switch (importance) {
      case InsightImportance.critical:
        return Icons.priority_high;
      case InsightImportance.high:
        return Icons.warning;
      case InsightImportance.medium:
        return Icons.info;
      case InsightImportance.low:
        return Icons.info_outline;
    }
  }

  /// Получает текст для временного признака инсайта
  String _getTimeframeText(InsightTimeframe timeframe) {
    switch (timeframe) {
      case InsightTimeframe.retrospective:
        return 'Анализ прошлого';
      case InsightTimeframe.predictive:
        return 'Прогноз будущего';
      case InsightTimeframe.combined:
        return 'Комбинированный';
    }
  }

  /// Получает иконку для временного признака инсайта
  IconData _getTimeframeIcon(InsightTimeframe timeframe) {
    switch (timeframe) {
      case InsightTimeframe.retrospective:
        return Icons.history;
      case InsightTimeframe.predictive:
        return Icons.update;
      case InsightTimeframe.combined:
        return Icons.sync;
    }
  }

  /// Получает цвет для временного признака инсайта
  Color _getTimeframeColor(InsightTimeframe timeframe) {
    switch (timeframe) {
      case InsightTimeframe.retrospective:
        return Colors.blue;
      case InsightTimeframe.predictive:
        return Colors.orange;
      case InsightTimeframe.combined:
        return Colors.purple;
    }
  }

  /// Получает иконку для рекомендации
  IconData _getRecommendationIcon() {
    switch (insight.type) {
      case InsightType.expenseStructure:
        return Icons.pie_chart;
      case InsightType.pattern:
        return Icons.repeat;
      case InsightType.forecast:
        return insight.importance == InsightImportance.critical ||
                insight.importance == InsightImportance.high
            ? Icons.warning
            : Icons.trending_up;
      case InsightType.comparison:
        return Icons.compare_arrows;
      case InsightType.optimization:
        return Icons.build;
      case InsightType.goal:
        return Icons.flag;
      case InsightType.advice:
        return Icons.lightbulb_outline;
    }
  }

  /// Получает цвет для рекомендации
  Color _getRecommendationColor() {
    if (insight.type == InsightType.forecast &&
        (insight.importance == InsightImportance.critical ||
            insight.importance == InsightImportance.high)) {
      return Colors.orange;
    }

    return _getColorForImportance(insight.importance);
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  /// Форматирует сумму
  String _formatAmount(num amount) {
    return amount
        .abs()
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
  }

  /// Форматирует дату
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Сегодня';
    } else if (dateOnly == yesterday) {
      return 'Вчера';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
