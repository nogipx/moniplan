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

## Создание нового анализатора

Для создания нового анализатора необходимо:

1. Выбрать подходящий базовый класс (BaseRetrospectiveAnalyzer, BasePredictiveAnalyzer или BaseCombinedAnalyzer)
2. Реализовать метод `analyzeInternal`
3. Использовать геттеры для доступа к отфильтрованным операциям

Пример:

```dart
class MyAnalyzer extends BaseRetrospectiveAnalyzer {
  @override
  List<Insight> analyzeInternal(IFinancialSource source, {Map<String, dynamic>? analysisData}) {
    final insights = <Insight>[];
    
    // Используем геттер для получения только завершенных операций
    final operations = retrospectiveOperations;
    
    // Логика анализа...
    
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

## Настройки анализаторов

Для управления настройками анализаторов используется сервис `AnalyzerSettingsService`, который реализует интерфейс `IAnalyzerSettingsService`. Сервис позволяет:

1. Включать и отключать анализаторы
2. Сохранять и загружать настройки
3. Получать список включенных анализаторов

## Генератор инсайтов

Для генерации инсайтов используется класс `InsightGeneratorImpl`, который реализует интерфейс `IInsightGenerator`. Генератор:

1. Создает анализаторы с помощью фабрики
2. Загружает настройки анализаторов
3. Применяет анализаторы к финансовым данным
4. Возвращает список инсайтов 