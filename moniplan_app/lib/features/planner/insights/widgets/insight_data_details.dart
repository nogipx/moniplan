// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Виджет для отображения конкретных данных, использованных при анализе инсайта
class InsightDataDetails extends StatefulWidget {
  /// Инсайт для отображения
  final Insight insight;

  /// Планер, для которого отображаются инсайты
  final Planner? planner;

  /// Конструктор
  const InsightDataDetails({Key? key, required this.insight, this.planner}) : super(key: key);

  @override
  State<InsightDataDetails> createState() => _InsightDataDetailsState();
}

class _InsightDataDetailsState extends State<InsightDataDetails> {
  // Форматтер для дат
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  // Форматтер для денежных сумм
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 0,
  );

  // Контроллер для поиска
  final TextEditingController _searchController = TextEditingController();

  // Список отфильтрованных платежей
  List<Payment> _filteredPayments = [];

  // Выбранная категория для фильтрации
  String? _selectedCategory;

  // Список всех категорий
  Set<String> _allCategories = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Инициализирует данные
  void _initializeData() {
    if (widget.insight.relatedPayments == null || widget.insight.relatedPayments!.isEmpty) {
      _filteredPayments = [];
      return;
    }

    // Получаем все платежи
    _filteredPayments = List<Payment>.from(widget.insight.relatedPayments!)
      ..sort((a, b) => b.date.compareTo(a.date)); // Сортируем по дате (новые сверху)

    // Собираем все категории
    _allCategories = {};
    for (final payment in _filteredPayments) {
      _allCategories.addAll(payment.details.tags);
    }
  }

  /// Фильтрует платежи по поисковому запросу и категории
  void _filterPayments() {
    if (widget.insight.relatedPayments == null || widget.insight.relatedPayments!.isEmpty) {
      setState(() {
        _filteredPayments = [];
      });
      return;
    }

    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredPayments =
          widget.insight.relatedPayments!.where((payment) {
              // Фильтрация по поисковому запросу
              final matchesSearch =
                  searchQuery.isEmpty ||
                  payment.details.name?.toLowerCase().contains(searchQuery) == true ||
                  payment.details.note.toLowerCase().contains(searchQuery);

              // Фильтрация по категории
              final matchesCategory =
                  _selectedCategory == null || payment.details.tags.contains(_selectedCategory);

              return matchesSearch && matchesCategory;
            }).toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // Сортируем по дате (новые сверху)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.insight.relatedPayments == null || widget.insight.relatedPayments!.isEmpty) {
      return _buildNoRelatedPaymentsView(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildFilters(),
        const SizedBox(height: 16),
        _buildSummary(),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            children: [
              _buildCalculationMethodology(context),
              const SizedBox(height: 16),
              Flexible(child: _buildPaymentsList()),
            ],
          ),
        ),
      ],
    );
  }

  /// Строит представление, когда у инсайта нет связанных платежей
  Widget _buildNoRelatedPaymentsView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Агрегированные данные',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Этот инсайт был сформирован на основе агрегированных данных и общего анализа вашего бюджета. '
                  'Для него нет конкретных связанных платежей, которые можно было бы показать.',
                  style: TextStyle(color: context.color.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                _buildCalculationMethodology(context),
                const SizedBox(height: 16),
                if (widget.planner != null && widget.planner!.payments.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _filteredPayments = List<Payment>.from(widget.planner!.payments)
                          ..sort((a, b) => b.date.compareTo(a.date));

                        // Собираем все категории
                        _allCategories = {};
                        for (final payment in _filteredPayments) {
                          _allCategories.addAll(payment.details.tags);
                        }
                      });
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Показать все платежи планера'),
                  ),
              ],
            ),
          ),
          if (_filteredPayments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_outlined, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Отображаются все платежи планера. Они могут не иметь прямого отношения к данному инсайту.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.color.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 16),
            Expanded(child: _buildPaymentsList()),
          ],
        ],
      ),
    );
  }

  /// Строит заголовок
  Widget _buildHeader() {
    return Text(
      'Данные для анализа',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.color.onSurface),
    );
  }

  /// Строит фильтры
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Поисковая строка
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Поиск по названию или описанию',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          onChanged: (_) => _filterPayments(),
        ),
        const SizedBox(height: 8),
        // Фильтр по категориям
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Кнопка "Все категории"
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Все категории'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _filterPayments();
                    }
                  },
                ),
              ),
              // Остальные категории
              ..._allCategories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      _filterPayments();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Строит сводку по данным
  Widget _buildSummary() {
    // Рассчитываем общую сумму доходов и расходов
    double totalIncome = 0;
    double totalExpense = 0;

    for (final payment in _filteredPayments) {
      if (payment.details.type == PaymentType.income) {
        totalIncome += payment.details.normalizedMoney.abs();
      } else if (payment.details.type == PaymentType.expense) {
        totalExpense += payment.details.normalizedMoney.abs();
      }
    }

    // Рассчитываем баланс
    final balance = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сводка по ${_filteredPayments.length} платежам',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Доходы', totalIncome, Colors.green, Icons.arrow_upward),
              ),
              Expanded(
                child: _buildSummaryItem('Расходы', totalExpense, Colors.red, Icons.arrow_downward),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Баланс',
                  balance,
                  balance >= 0 ? Colors.green : Colors.red,
                  balance >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Строит элемент сводки
  Widget _buildSummaryItem(String title, double amount, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: context.color.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              _currencyFormat.format(amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  /// Строит список платежей
  Widget _buildPaymentsList() {
    if (_filteredPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Нет платежей, соответствующих фильтрам',
              style: TextStyle(fontSize: 16, color: context.color.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredPayments.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final payment = _filteredPayments[index];
        return _buildPaymentItem(payment);
      },
    );
  }

  /// Строит элемент платежа
  Widget _buildPaymentItem(Payment payment) {
    final isIncome = payment.details.type == PaymentType.income;
    final amount = payment.details.normalizedMoney.abs();
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(
        payment.details.name ?? 'Без названия',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_dateFormat.format(payment.date)),
          if (payment.details.tags.isNotEmpty)
            Wrap(
              spacing: 4,
              children:
                  payment.details.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
      trailing: Text(
        _currencyFormat.format(amount),
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
      onTap: () => _showPaymentDetails(payment),
    );
  }

  /// Показывает детали платежа
  void _showPaymentDetails(Payment payment) {
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
                Text(
                  payment.details.name ?? 'Без названия',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Дата', _dateFormat.format(payment.date)),
                _buildDetailRow(
                  'Сумма',
                  _currencyFormat.format(payment.details.normalizedMoney.abs()),
                  textColor: payment.details.type == PaymentType.income ? Colors.green : Colors.red,
                ),
                _buildDetailRow(
                  'Тип',
                  payment.details.type == PaymentType.income ? 'Доход' : 'Расход',
                ),
                if (payment.details.note.isNotEmpty)
                  _buildDetailRow('Примечание', payment.details.note),
                if (payment.details.tags.isNotEmpty)
                  _buildDetailRow('Категории', payment.details.tags.join(', ')),
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
    );
  }

  /// Строит строку с деталями
  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.color.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textColor ?? context.color.onSurface)),
          ),
        ],
      ),
    );
  }

  /// Строит объяснение методологии расчета инсайта
  Widget _buildCalculationMethodology(BuildContext context) {
    // Получаем тип инсайта и временной признак
    final insightType = widget.insight.type;
    final timeframe = _getTimeframe(widget.insight);

    // Заголовок и описание методологии
    String title = 'Как был рассчитан этот инсайт';
    List<Widget> steps = [];

    // Формируем шаги расчета в зависимости от типа инсайта
    switch (insightType) {
      case InsightType.expenseStructure:
        // Получаем дополнительные данные для более конкретного объяснения
        final additionalData = widget.insight.additionalData;
        final hasLargestCategory =
            additionalData != null && additionalData.containsKey('largest_category');
        final largestCategory = hasLargestCategory ? additionalData!['largest_category'] : null;
        final categoryPercentage =
            additionalData != null && additionalData.containsKey('category_percentage')
                ? additionalData['category_percentage']
                : null;

        // Формируем текст для третьего шага
        final String step3Text =
            'Для каждой категории была рассчитана доля от общей суммы расходов. '
            'Была определена средняя сумма платежа в каждой категории и стандартное отклонение. ';

        final String categoryInfo =
            hasLargestCategory
                ? 'Категория "$largestCategory" составила ${categoryPercentage != null ? "$categoryPercentage% " : "значительную долю "}всех расходов.'
                : 'Были выявлены категории с наибольшей долей в общих расходах.';

        steps = [
          _buildMethodologyStep(
            1,
            'Сбор и фильтрация данных',
            'Были собраны все ${_getTimeframeDescription(timeframe)} расходы за период ${_getAnalysisPeriod()}. '
                'Учитывались только завершенные платежи с типом "Расход".',
          ),
          _buildMethodologyStep(
            2,
            'Группировка и агрегация',
            'Расходы были сгруппированы по категориям (тегам). '
                'Для каждой категории была рассчитана общая сумма расходов и количество платежей.',
          ),
          _buildMethodologyStep(
            3,
            'Расчет долей и статистический анализ',
            step3Text + categoryInfo,
          ),
          _buildMethodologyStep(
            4,
            'Анализ структуры и формирование выводов',
            'На основе распределения расходов по категориям была проанализирована структура бюджета. '
                'Были выявлены категории, требующие особого внимания, и сформированы рекомендации по оптимизации.',
          ),
        ];
        break;

      case InsightType.pattern:
        // Получаем дополнительные данные для более конкретного объяснения
        final additionalData = widget.insight.additionalData;
        final patternType =
            additionalData != null && additionalData.containsKey('pattern_type')
                ? additionalData['pattern_type']
                : null;
        final confidence =
            additionalData != null && additionalData.containsKey('confidence')
                ? additionalData['confidence']
                : null;

        // Формируем текст для третьего шага
        final String step3Text = 'Были выявлены повторяющиеся платежи и их периодичность. ';

        final String patternInfo =
            patternType != null
                ? 'Обнаружен паттерн типа "$patternType". '
                : 'Обнаруженные паттерны были классифицированы по типам. ';

        // Формируем текст для четвертого шага
        final String step4Text =
            'Была проведена оценка статистической значимости обнаруженных паттернов. ';

        final String confidenceInfo =
            confidence != null ? 'Уверенность в выявленном паттерне составила $confidence%. ' : '';

        steps = [
          _buildMethodologyStep(
            1,
            'Сбор и подготовка временных рядов',
            'Были собраны все ${_getTimeframeDescription(timeframe)} платежи за период ${_getAnalysisPeriod()}. '
                'Данные были организованы в хронологическом порядке и нормализованы для анализа.',
          ),
          _buildMethodologyStep(
            2,
            'Анализ периодичности и частотный анализ',
            'Платежи были проанализированы по датам, суммам и периодичности. '
                'Был проведен частотный анализ для выявления повторяющихся транзакций. '
                'Использовались методы спектрального анализа для выявления скрытых циклов.',
          ),
          _buildMethodologyStep(
            3,
            'Выявление и классификация паттернов',
            step3Text +
                patternInfo +
                'Для каждого паттерна была рассчитана статистическая значимость и устойчивость.',
          ),
          _buildMethodologyStep(
            4,
            'Оценка достоверности и формирование прогноза',
            step4Text +
                confidenceInfo +
                'На основе выявленных закономерностей был сформирован прогноз будущих платежей.',
          ),
        ];
        break;

      case InsightType.forecast:
        // Получаем дополнительные данные для более конкретного объяснения
        final additionalData = widget.insight.additionalData;
        final forecastChange =
            additionalData != null && additionalData.containsKey('forecast_change')
                ? additionalData['forecast_change']
                : null;
        final forecastConfidence =
            additionalData != null && additionalData.containsKey('forecast_confidence')
                ? additionalData['forecast_confidence']
                : null;

        // Формируем текст для четвертого шага
        final String step4Text =
            'На основе исторических данных и выявленных закономерностей был сформирован прогноз. ';

        final String forecastInfo =
            forecastChange != null
                ? 'Прогнозируется ${forecastChange > 0 ? "увеличение" : "уменьшение"} расходов на ${forecastChange.abs()}%. '
                : '';

        final String confidenceInfo =
            forecastConfidence != null
                ? 'Точность прогноза оценивается в $forecastConfidence%. '
                : '';

        steps = [
          _buildMethodologyStep(
            1,
            'Сбор и анализ исторических данных',
            'Были собраны данные о ${_getTimeframeDescription(timeframe)} расходах за период ${_getAnalysisPeriod()}. '
                'Данные были очищены от выбросов и нормализованы для анализа временных рядов.',
          ),
          _buildMethodologyStep(
            2,
            'Выявление трендов и сезонности',
            'Был проведен декомпозиционный анализ временного ряда для выделения тренда, сезонной и случайной составляющих. '
                'Использовались методы скользящего среднего и экспоненциального сглаживания для выявления долгосрочных тенденций.',
          ),
          _buildMethodologyStep(
            3,
            'Построение прогностической модели',
            'На основе выявленных закономерностей была построена прогностическая модель. '
                'Использовались методы авторегрессии и интегрированного скользящего среднего (ARIMA) для прогнозирования будущих значений. '
                'Модель была обучена на исторических данных и валидирована на тестовой выборке.',
          ),
          _buildMethodologyStep(
            4,
            'Формирование прогноза и оценка точности',
            step4Text +
                forecastInfo +
                confidenceInfo +
                'Были рассчитаны доверительные интервалы для прогноза и оценены возможные риски.',
          ),
        ];
        break;

      case InsightType.comparison:
        // Получаем дополнительные данные для более конкретного объяснения
        final additionalData = widget.insight.additionalData;
        final comparisonPeriod =
            additionalData != null && additionalData.containsKey('comparison_period')
                ? additionalData['comparison_period']
                : null;
        final changePercentage =
            additionalData != null && additionalData.containsKey('change_percentage')
                ? additionalData['change_percentage']
                : null;

        // Формируем текст для третьего шага
        final String step3Text =
            'Были рассчитаны абсолютные и относительные изменения по категориям. ';

        final String changeInfo =
            changePercentage != null
                ? 'Общее ${changePercentage > 0 ? "увеличение" : "уменьшение"} расходов составило ${changePercentage.abs()}%. '
                : '';

        // Формируем текст для первого шага
        final String step1Text =
            'Были выбраны два периода для сравнения: текущий период (${_getAnalysisPeriod()}) и ';

        final String periodInfo =
            comparisonPeriod != null
                ? 'период $comparisonPeriod. '
                : 'аналогичный период в прошлом. ';

        steps = [
          _buildMethodologyStep(
            1,
            'Выбор и подготовка периодов для сравнения',
            step1Text +
                periodInfo +
                'Данные по обоим периодам были нормализованы для корректного сравнения.',
          ),
          _buildMethodologyStep(
            2,
            'Нормализация и корректировка данных',
            'Данные были скорректированы с учетом инфляции и других экономических факторов. '
                'Были учтены сезонные колебания и выровнены периоды по длительности для обеспечения сопоставимости.',
          ),
          _buildMethodologyStep(
            3,
            'Расчет и анализ изменений',
            step3Text +
                changeInfo +
                'Для каждой категории расходов были рассчитаны темпы роста/снижения и доли в общей структуре.',
          ),
          _buildMethodologyStep(
            4,
            'Выявление значимых изменений и формирование выводов',
            'Были определены категории с наиболее существенными изменениями. '
                'Проведен статистический анализ значимости изменений с использованием t-критерия. '
                'На основе анализа сформированы выводы о динамике расходов и рекомендации.',
          ),
        ];
        break;

      case InsightType.optimization:
        // Получаем дополнительные данные для более конкретного объяснения
        final additionalData = widget.insight.additionalData;
        final recommendationType =
            additionalData != null && additionalData.containsKey('recommendation_type')
                ? additionalData['recommendation_type']
                : null;
        final potentialSavings =
            additionalData != null && additionalData.containsKey('potential_savings')
                ? additionalData['potential_savings']
                : null;
        final implementationDifficulty =
            additionalData != null && additionalData.containsKey('implementation_difficulty')
                ? additionalData['implementation_difficulty']
                : null;

        // Формируем текст для четвертого шага
        final String step4Text =
            'На основе анализа данных и выявленных возможностей была сформирована рекомендация. ';

        final String recommendationInfo =
            recommendationType != null ? 'Тип рекомендации: "$recommendationType". ' : '';

        final String savingsInfo =
            potentialSavings != null ? 'Потенциальная экономия составляет $potentialSavings. ' : '';

        final String difficultyInfo =
            implementationDifficulty != null
                ? 'Сложность внедрения оценивается как "$implementationDifficulty". '
                : '';

        steps = [
          _buildMethodologyStep(
            1,
            'Анализ финансового поведения',
            'Были проанализированы данные о ${_getTimeframeDescription(timeframe)} расходах за период ${_getAnalysisPeriod()}. '
                'Были выявлены паттерны расходов, предпочтения и финансовые привычки.',
          ),
          _buildMethodologyStep(
            2,
            'Выявление возможностей для оптимизации',
            'На основе анализа данных были определены области, где возможна оптимизация расходов или улучшение финансового поведения. '
                'Были рассчитаны потенциальные выгоды от различных стратегий оптимизации.',
          ),
          _buildMethodologyStep(
            3,
            'Оценка реализуемости рекомендаций',
            'Для каждой потенциальной рекомендации была проведена оценка сложности внедрения, потенциальных рисков и ограничений. '
                'Были учтены индивидуальные особенности финансового поведения и предпочтения.',
          ),
          _buildMethodologyStep(
            4,
            'Формирование конкретной рекомендации',
            step4Text +
                recommendationInfo +
                savingsInfo +
                difficultyInfo +
                'Рекомендация была сформулирована с учетом баланса между потенциальной выгодой и сложностью внедрения.',
          ),
        ];
        break;

      case InsightType.goal:
        // Получаем дополнительные данные для более конкретного объяснения
        final additionalData = widget.insight.additionalData;
        final goalProgress =
            additionalData != null && additionalData.containsKey('goal_progress')
                ? additionalData['goal_progress']
                : null;
        final timeToCompletion =
            additionalData != null && additionalData.containsKey('time_to_completion')
                ? additionalData['time_to_completion']
                : null;
        final deviationFromPlan =
            additionalData != null && additionalData.containsKey('deviation_from_plan')
                ? additionalData['deviation_from_plan']
                : null;

        // Формируем текст для третьего шага
        final String step3Text = 'Был проведен анализ прогресса в достижении цели. ';

        final String progressInfo =
            goalProgress != null ? 'Текущий прогресс составляет $goalProgress%. ' : '';

        final String timeInfo =
            timeToCompletion != null
                ? 'Расчетное время до достижения цели: $timeToCompletion. '
                : '';

        final String deviationInfo =
            deviationFromPlan != null
                ? 'Отклонение от плана: ${deviationFromPlan > 0 ? "опережение на" : "отставание на"} ${deviationFromPlan.abs()}%. '
                : '';

        steps = [
          _buildMethodologyStep(
            1,
            'Анализ финансовой цели',
            'Была проанализирована финансовая цель и ее параметры: целевая сумма, срок достижения, приоритет. '
                'Были учтены все связанные с целью транзакции и накопления.',
          ),
          _buildMethodologyStep(
            2,
            'Расчет текущего прогресса',
            'Был рассчитан текущий прогресс в достижении цели на основе накопленных средств. '
                'Учтены все поступления и изъятия средств, связанные с целью.',
          ),
          _buildMethodologyStep(
            3,
            'Анализ динамики и прогнозирование',
            step3Text +
                progressInfo +
                timeInfo +
                deviationInfo +
                'Была проанализирована динамика накоплений и спрогнозировано время достижения цели при сохранении текущего темпа.',
          ),
          _buildMethodologyStep(
            4,
            'Формирование рекомендаций',
            'На основе анализа были сформированы рекомендации по оптимизации стратегии достижения цели. '
                'Учтены возможности ускорения накоплений и минимизации рисков недостижения цели в срок.',
          ),
        ];
        break;

      case InsightType.advice:
        // Получаем дополнительные данные для более конкретного объяснения
        final additionalData = widget.insight.additionalData;
        final anomalyType =
            additionalData != null && additionalData.containsKey('anomaly_type')
                ? additionalData['anomaly_type']
                : null;
        final deviationPercentage =
            additionalData != null && additionalData.containsKey('deviation_percentage')
                ? additionalData['deviation_percentage']
                : null;
        final zScore =
            additionalData != null && additionalData.containsKey('z_score')
                ? additionalData['z_score']
                : null;

        // Формируем текст для третьего шага
        final String step3Text = 'Были рассчитаны статистические показатели отклонения от нормы. ';

        final String anomalyInfo =
            anomalyType != null ? 'Выявлена аномалия типа "$anomalyType". ' : '';

        final String deviationInfo =
            deviationPercentage != null
                ? 'Отклонение от среднего значения составило ${deviationPercentage.abs()}%. '
                : '';

        final String zScoreInfo =
            zScore != null
                ? 'Z-показатель составил $zScore (значения выше 2 считаются статистически значимыми). '
                : '';

        steps = [
          _buildMethodologyStep(
            1,
            'Сбор и подготовка данных для анализа',
            'Были собраны данные о ${_getTimeframeDescription(timeframe)} расходах за период ${_getAnalysisPeriod()}. '
                'Данные были очищены от известных сезонных колебаний и нормализованы.',
          ),
          _buildMethodologyStep(
            2,
            'Определение статистической нормы',
            'Были рассчитаны базовые статистические показатели: среднее значение, медиана, стандартное отклонение. '
                'На основе этих показателей были определены границы нормального распределения расходов.',
          ),
          _buildMethodologyStep(
            3,
            'Выявление и анализ аномалий',
            step3Text +
                anomalyInfo +
                deviationInfo +
                zScoreInfo +
                'Был проведен анализ причин возникновения аномалии и оценка ее влияния на общую финансовую картину.',
          ),
          _buildMethodologyStep(
            4,
            'Формирование выводов и рекомендаций',
            'На основе анализа аномалии были сформированы выводы о ее значимости и потенциальном влиянии на будущие расходы. '
                'Были разработаны рекомендации по реагированию на выявленную аномалию и предотвращению подобных ситуаций в будущем.',
          ),
        ];
        break;
    }

    // Добавляем информацию из additionalData, если она есть
    Widget additionalInfo = const SizedBox.shrink();
    if (widget.insight.additionalData != null && widget.insight.additionalData!.isNotEmpty) {
      final relevantData = _getRelevantAdditionalData(widget.insight.additionalData!);
      if (relevantData.isNotEmpty) {
        additionalInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Использованные данные:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...relevantData.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        '${_formatAdditionalDataKey(entry.key)}: ${_formatAdditionalDataValue(entry.value)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.onSurface.withOpacity(0.1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...steps,
            additionalInfo,
          ],
        ),
      ),
    );
  }

  /// Строит шаг методологии расчета
  Widget _buildMethodologyStep(int stepNumber, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Получает описание временного признака
  String _getTimeframeDescription(InsightTimeframe timeframe) {
    switch (timeframe) {
      case InsightTimeframe.retrospective:
        return 'ежедневных';
      case InsightTimeframe.predictive:
        return 'прогнозируемых';
      case InsightTimeframe.combined:
      default:
        return 'общих';
    }
  }

  /// Получает временной признак инсайта
  InsightTimeframe _getTimeframe(Insight insight) {
    if (insight.timeframe != null) {
      return insight.timeframe;
    }

    if (insight.additionalData != null && insight.additionalData!.containsKey('timeframe')) {
      final timeframeStr = insight.additionalData!['timeframe'] as String?;
      if (timeframeStr == 'retrospective' ||
          timeframeStr == InsightTimeframe.retrospective.toString()) {
        return InsightTimeframe.retrospective;
      } else if (timeframeStr == 'predictive' ||
          timeframeStr == InsightTimeframe.predictive.toString()) {
        return InsightTimeframe.predictive;
      }
    }

    return InsightTimeframe.combined;
  }

  /// Получает релевантные данные из additionalData
  Map<String, dynamic> _getRelevantAdditionalData(Map<String, dynamic> additionalData) {
    // Исключаем служебные поля
    final excludedKeys = ['timeframe'];

    return Map.fromEntries(
      additionalData.entries.where((entry) => !excludedKeys.contains(entry.key)),
    );
  }

  /// Форматирует ключ additionalData для отображения
  String _formatAdditionalDataKey(String key) {
    // Преобразуем snake_case в читаемый текст
    final words = key
        .split('_')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');

    // Заменяем известные ключи на более понятные названия
    switch (key) {
      case 'largest_category':
        return 'Крупнейшая категория';
      case 'largest_amount':
        return 'Сумма по крупнейшей категории';
      case 'category_percentage':
        return 'Доля категории';
      case 'pattern_type':
        return 'Тип паттерна';
      case 'confidence':
        return 'Уверенность';
      case 'forecast_change':
        return 'Прогнозируемое изменение';
      case 'forecast_confidence':
        return 'Точность прогноза';
      case 'comparison_period':
        return 'Период сравнения';
      case 'change_percentage':
        return 'Процент изменения';
      case 'potential_savings':
        return 'Потенциальная экономия';
      case 'progress_percentage':
        return 'Процент выполнения';
      default:
        return words;
    }
  }

  /// Форматирует значение additionalData для отображения
  String _formatAdditionalDataValue(dynamic value) {
    if (value is num) {
      // Форматируем числа в зависимости от контекста
      if (value.abs() > 1000) {
        // Для больших сумм используем форматирование валюты
        return _currencyFormat.format(value);
      } else if (value % 1 == 0) {
        // Для целых чисел убираем десятичную часть
        return value.toInt().toString();
      } else {
        // Для дробных чисел оставляем 1-2 знака после запятой
        return value.toStringAsFixed(value % 1 < 0.1 ? 1 : 2);
      }
    } else if (value is bool) {
      return value ? 'Да' : 'Нет';
    } else if (value is String) {
      return value;
    } else if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    } else {
      return value?.toString() ?? 'Нет данных';
    }
  }

  /// Возвращает описание периода анализа в зависимости от timeframe инсайта
  String _getAnalysisPeriod() {
    final timeframe = _getTimeframe(widget.insight);
    switch (timeframe) {
      case InsightTimeframe.retrospective:
        return 'последние 3 месяца';
      case InsightTimeframe.predictive:
        return 'следующие 3 месяца';
      case InsightTimeframe.combined:
      default:
        return 'анализируемый период';
    }
  }
}
