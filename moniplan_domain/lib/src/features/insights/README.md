# Модуль Insights

Модуль для анализа финансовых данных и генерации инсайтов.

## Архитектура

Модуль построен на основе следующих ключевых компонентов:

1. **Интерфейсы** - определяют контракты для анализаторов и источников данных
2. **Анализаторы** - реализуют логику анализа финансовых данных
3. **Модели** - определяют структуры данных для инсайтов и результатов анализа
4. **Сервисы** - предоставляют дополнительную функциональность для анализаторов
5. **Утилиты** - содержат вспомогательные функции и классы

## Анализаторы

В системе реализованы следующие анализаторы:

### Ретроспективные анализаторы

- **AnomalyAnalyzer** - выявляет аномалии в финансовых данных
- **FinancialRatioAnalyzer** - анализирует ключевые финансовые показатели
- **LifestyleInflationAnalyzer** - отслеживает рост расходов относительно роста доходов
- **SeasonalPatternAnalyzer** - выявляет сезонные тренды в расходах и доходах

### Прогностические анализаторы

- **PredictiveAnalyzer** - прогнозирует будущие финансовые тенденции

### Комбинированные анализаторы

- **BudgetOptimizationAnalyzer** - предлагает способы оптимизации бюджета
- **FinancialIndependenceAnalyzer** - рассчитывает показатели на пути к финансовой независимости

## Базовые классы анализаторов

Для упрощения разработки новых анализаторов созданы базовые классы:

- **BaseRetrospectiveAnalyzer** - базовый класс для ретроспективных анализаторов
- **BasePredictiveAnalyzer** - базовый класс для прогностических анализаторов
- **BaseCombinedAnalyzer** - базовый класс для комбинированных анализаторов

Эти классы предоставляют общую функциональность, включая:

- Хранение источника данных
- Фильтрацию операций по временному признаку
- Шаблонный метод для анализа
- Создание инсайтов с автоматическим добавлением информации об анализаторе

## Фильтрация операций

Все анализаторы имеют доступ к методу `getFilteredOperations`, который фильтрует операции по временному признаку:

- **retrospective** - возвращает только завершенные операции
- **predictive** - возвращает только запланированные операции
- **combined** - возвращает все операции

Кроме того, каждый тип анализатора имеет специальные геттеры для удобного доступа к отфильтрованным операциям:

### RetrospectiveAnalyzer

```dart
List<IFinancialData> get retrospectiveOperations => 
    getFilteredOperations(period, InsightTimeframe.retrospective);
```

### PredictiveAnalyzer

```dart
List<IFinancialData> get predictiveOperations => 
    getFilteredOperations(period, InsightTimeframe.predictive);
```

### CombinedAnalyzer

```dart
List<IFinancialData> get retrospectiveOperations => 
    getFilteredOperations(period, InsightTimeframe.retrospective);
    
List<IFinancialData> get predictiveOperations => 
    getFilteredOperations(period, InsightTimeframe.predictive);
    
List<IFinancialData> get combinedOperations => 
    getFilteredOperations(period, InsightTimeframe.combined);
```

## Создание инсайтов

Все анализаторы имеют доступ к методу `createInsight`, который создает инсайт с автоматическим добавлением информации об анализаторе:

```dart
Insight createInsight({
  required String id,
  required String title,
  required String description,
  required InsightType type,
  required InsightImportance importance,
  InsightTimeframe timeframe = InsightTimeframe.combined,
  List<Payment>? relatedPayments,
  Map<String, dynamic>? additionalData,
}) {
  // Создаем копию дополнительных данных, чтобы не изменять оригинал
  final Map<String, dynamic> data = additionalData != null ? Map<String, dynamic>.from(additionalData) : {};
  
  // Добавляем информацию об анализаторе
  data['analyzerType'] = runtimeType.toString();
  
  return Insight(
    id: id,
    title: title,
    description: description,
    type: type,
    importance: importance,
    timeframe: timeframe,
    relatedPayments: relatedPayments,
    additionalData: data,
  );
}
```

Это позволяет отслеживать, какой анализатор создал каждый инсайт, что полезно для отладки и анализа работы системы.

## Создание нового анализатора

Для создания нового анализатора необходимо:

1. Выбрать подходящий базовый класс (BaseRetrospectiveAnalyzer, BasePredictiveAnalyzer или BaseCombinedAnalyzer)
2. Реализовать метод `analyzeInternal`
3. Использовать геттеры для доступа к отфильтрованным операциям
4. Использовать метод `createInsight` для создания инсайтов

Пример:

```dart
class MyAnalyzer extends BaseRetrospectiveAnalyzer {
  @override
  List<Insight> analyzeInternal(IFinancialSource source, {Map<String, dynamic>? analysisData}) {
    final insights = <Insight>[];
    
    // Используем геттер для получения только завершенных операций
    final operations = retrospectiveOperations;
    
    // Логика анализа...
    
    // Создаем инсайт с автоматическим добавлением информации об анализаторе
    insights.add(createInsight(
      id: uuid.v4(),
      title: 'Мой инсайт',
      description: 'Описание инсайта',
      type: InsightType.advice,
      importance: InsightImportance.medium,
      timeframe: InsightTimeframe.retrospective,
      additionalData: {
        'someData': 'someValue',
      },
    ));
    
    return insights;
  }
}
```

## Фабрика анализаторов

Для создания экземпляров анализаторов используется фабрика `AnalyzerFactoryImpl`, которая реализует интерфейс `IAnalyzerFactory`. Фабрика позволяет:

1. Получать список доступных анализаторов
2. Создавать анализаторы по идентификатору
3. Фильтровать анализаторы по типу или тегам
4. Регистрировать пользовательские анализаторы

## Генератор инсайтов

Для генерации инсайтов используется класс `InsightGeneratorImpl`, который реализует интерфейс `IInsightGenerator`. Генератор:

1. Создает адаптер для финансовых данных
2. Инициализирует анализаторы с помощью фабрики
3. Применяет все доступные анализаторы к финансовым данным
4. Возвращает список инсайтов 