// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:moniplan_app/features/planner/insights/widgets/insight_data_details.dart';

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
        title: Text(insight.title),
        backgroundColor: importanceColor.withOpacity(0.1),
        foregroundColor: importanceColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
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

                    const SizedBox(height: 24),

                    // Рекомендации
                    _buildRecommendations(context),
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

  /// Строит блок с рекомендациями
  Widget _buildRecommendations(BuildContext context) {
    final recommendation = _getRecommendation();
    final recommendationIcon = _getRecommendationIcon();
    final recommendationColor = _getRecommendationColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Что делать?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.color.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: recommendationColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: recommendationColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(recommendationIcon, color: recommendationColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  recommendation,
                  style: TextStyle(fontSize: 15, color: context.color.onSurface),
                ),
              ),
            ],
          ),
        ),
      ],
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

  /// Получает рекомендацию в зависимости от типа инсайта
  String _getRecommendation() {
    switch (insight.type) {
      case InsightType.expenseStructure:
        return 'Проанализируй свои расходы по категориям. Если какая-то категория занимает слишком большую долю бюджета, подумай о способах сократить эти расходы или перераспределить средства более равномерно.';

      case InsightType.pattern:
        return 'Обрати внимание на выявленные закономерности в твоих финансовых привычках. Используй эту информацию для более эффективного планирования будущих расходов и доходов.';

      case InsightType.forecast:
        if (insight.importance == InsightImportance.critical ||
            insight.importance == InsightImportance.high) {
          return 'Твой текущий финансовый курс может привести к проблемам. Рассмотри возможность сократить некоторые необязательные расходы или найти дополнительные источники дохода в ближайшее время.';
        } else {
          return 'Твои финансы развиваются в правильном направлении. Продолжай следить за балансом доходов и расходов, чтобы сохранить финансовую стабильность.';
        }

      case InsightType.optimization:
        return 'Рассмотри возможность оптимизировать свои расходы, отложив или отменив некоторые необязательные платежи. Это поможет улучшить твое финансовое положение и избежать возможных проблем в будущем.';

      case InsightType.comparison:
        return 'Сравни свои текущие финансовые показатели с предыдущими периодами. Это поможет тебе увидеть прогресс и определить области, требующие внимания.';

      case InsightType.goal:
        return 'Следуй своему финансовому плану и регулярно отслеживай прогресс в достижении поставленных целей. При необходимости корректируй свою стратегию.';

      case InsightType.advice:
        return 'Примени этот финансовый совет к своей ситуации. Даже небольшие изменения в финансовых привычках могут привести к значительным улучшениям в долгосрочной перспективе.';
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

  /// Показывает диалог справки
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('О данных для анализа'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'На этом экране показаны конкретные данные, которые были использованы для формирования инсайта.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ты можешь:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildHelpItem(
                    context,
                    'Изучить ключевые факты',
                    'Они помогут понять, на чем основан инсайт',
                  ),
                  _buildHelpItem(
                    context,
                    'Просмотреть связанные платежи',
                    'Увидеть конкретные транзакции, повлиявшие на анализ',
                  ),
                  _buildHelpItem(
                    context,
                    'Получить рекомендации',
                    'Узнать, какие действия стоит предпринять',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Это поможет тебе принимать более обоснованные финансовые решения и улучшить свое финансовое положение.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
              ),
            ],
          ),
    );
  }

  /// Строит элемент справки
  Widget _buildHelpItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  description,
                  style: TextStyle(color: context.color.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
