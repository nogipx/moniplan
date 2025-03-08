// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:collection/collection.dart';

import '../../payment/models/payment/payment.dart';
import '../interfaces/i_financial_data.dart';

/// Интерфейс для категоризатора платежей
abstract class IPaymentCategorizer {
  /// Категоризирует платеж на основе его данных
  ///
  /// Возвращает наиболее вероятную категорию
  String categorize(IFinancialData payment);

  /// Категоризирует список платежей
  ///
  /// Возвращает список платежей с заполненными категориями
  List<IFinancialData> categorizeAll(List<IFinancialData> payments);

  /// Обучает категоризатор на основе размеченных данных
  ///
  /// [labeledPayments] - платежи с уже заданными категориями
  Future<void> train(List<IFinancialData> labeledPayments);
}

/// Простой категоризатор платежей на основе ключевых слов и правил
///
/// Использует предопределенные правила и ключевые слова для категоризации
/// платежей на основе их описания и суммы
class SimplePaymentCategorizer implements IPaymentCategorizer {
  /// Словарь ключевых слов для каждой категории
  final Map<String, List<String>> _categoryKeywords = {
    'Продукты': [
      'продукты',
      'супермаркет',
      'магазин',
      'пятерочка',
      'магнит',
      'ашан',
      'перекресток',
      'лента',
      'дикси',
      'еда',
      'овощи',
      'фрукты',
      'хлеб',
      'молоко',
      'мясо',
      'рыба',
      'grocery',
      'supermarket',
      'food',
    ],
    'Рестораны': [
      'ресторан',
      'кафе',
      'бар',
      'столовая',
      'фастфуд',
      'доставка еды',
      'макдональдс',
      'кфс',
      'бургер кинг',
      'суши',
      'пицца',
      'restaurant',
      'cafe',
      'delivery',
      'food',
    ],
    'Транспорт': [
      'такси',
      'метро',
      'автобус',
      'трамвай',
      'троллейбус',
      'яндекс такси',
      'убер',
      'каршеринг',
      'билет',
      'проезд',
      'транспорт',
      'бензин',
      'заправка',
      'taxi',
      'uber',
      'transport',
      'metro',
      'bus',
      'train',
      'gas',
      'fuel',
    ],
    'Развлечения': [
      'кино',
      'театр',
      'концерт',
      'выставка',
      'музей',
      'парк',
      'аттракцион',
      'игры',
      'подписка',
      'стриминг',
      'netflix',
      'spotify',
      'entertainment',
      'movie',
      'cinema',
      'theatre',
      'concert',
      'subscription',
    ],
    'Здоровье': [
      'аптека',
      'лекарства',
      'врач',
      'клиника',
      'больница',
      'стоматолог',
      'анализы',
      'медицина',
      'pharmacy',
      'medicine',
      'doctor',
      'clinic',
      'hospital',
      'health',
    ],
    'Одежда': [
      'одежда',
      'обувь',
      'магазин одежды',
      'зара',
      'h&m',
      'uniqlo',
      'adidas',
      'nike',
      'clothes',
      'shoes',
      'fashion',
      'wear',
    ],
    'Коммунальные платежи': [
      'жкх',
      'квартплата',
      'электричество',
      'вода',
      'газ',
      'отопление',
      'интернет',
      'телефон',
      'коммуналка',
      'utility',
      'rent',
      'electricity',
      'water',
      'gas',
      'heating',
      'internet',
      'phone',
    ],
    'Образование': [
      'курсы',
      'обучение',
      'школа',
      'университет',
      'книги',
      'учебники',
      'education',
      'course',
      'school',
      'university',
      'books',
      'learning',
    ],
    'Подарки': [
      'подарок',
      'сувенир',
      'праздник',
      'день рождения',
      'новый год',
      'gift',
      'present',
      'souvenir',
      'holiday',
      'birthday',
      'christmas',
    ],
    'Путешествия': [
      'отель',
      'гостиница',
      'авиабилет',
      'самолет',
      'поезд',
      'бронирование',
      'booking',
      'отпуск',
      'путешествие',
      'travel',
      'hotel',
      'flight',
      'airplane',
      'booking',
      'vacation',
    ],
  };

  /// Правила для категоризации на основе суммы платежа
  final List<(double, double, String)> _amountRules = [
    (0, 300, 'Мелкие расходы'),
    (5000, 15000, 'Крупные покупки'),
    (15000, 50000, 'Очень крупные покупки'),
    (50000, double.infinity, 'Инвестиции/Недвижимость'),
  ];

  /// Веса для различных признаков при категоризации
  final Map<String, double> _featureWeights = {'keywords': 0.7, 'amount': 0.3};

  /// Пользовательские правила категоризации
  final Map<String, String> _userRules = {};

  /// Категоризирует платеж на основе его данных
  @override
  String categorize(IFinancialData payment) {
    // Если у платежа уже есть категория, возвращаем её
    if (payment.category.isNotEmpty) {
      return payment.category;
    }

    // Проверяем пользовательские правила
    final description = _getDescription(payment);
    for (final entry in _userRules.entries) {
      if (description.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Рассчитываем вероятности для каждой категории
    final scores = <String, double>{};

    // Анализ по ключевым словам
    for (final entry in _categoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;

      double score = 0;
      for (final keyword in keywords) {
        if (description.contains(keyword.toLowerCase())) {
          score += 1;
        }
      }

      if (score > 0) {
        // Нормализуем оценку по количеству ключевых слов
        score = score / keywords.length;
        scores[category] = (scores[category] ?? 0) + score * _featureWeights['keywords']!;
      }
    }

    // Анализ по сумме платежа
    final amount = payment.amount.toDouble();
    for (final rule in _amountRules) {
      final (min, max, category) = rule;
      if (amount >= min && amount <= max) {
        scores[category] = (scores[category] ?? 0) + _featureWeights['amount']!;
        break;
      }
    }

    // Если не нашли ни одной категории, возвращаем "Прочее"
    if (scores.isEmpty) {
      return 'Прочее';
    }

    // Возвращаем категорию с наивысшей оценкой
    final bestCategory = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return bestCategory;
  }

  /// Категоризирует список платежей
  @override
  List<IFinancialData> categorizeAll(List<IFinancialData> payments) {
    // Просто возвращаем исходный список платежей, так как мы не можем изменить их категории
    // из-за ограничений интерфейса IFinancialData
    // В реальном приложении нужно будет реализовать механизм обновления категорий

    // Категоризируем платежи и выводим информацию в консоль для отладки
    for (final payment in payments) {
      if (payment.category.isEmpty) {
        final suggestedCategory = categorize(payment);
        print('Предложенная категория для платежа ${payment.id}: $suggestedCategory');
      }
    }

    return payments;
  }

  /// Обучает категоризатор на основе размеченных данных
  @override
  Future<void> train(List<IFinancialData> labeledPayments) async {
    // Отбираем только платежи с заполненными категориями
    final validPayments = labeledPayments.where((p) => p.category.isNotEmpty).toList();

    if (validPayments.isEmpty) {
      return;
    }

    // Группируем платежи по категориям
    final paymentsByCategory = <String, List<IFinancialData>>{};
    for (final payment in validPayments) {
      final category = payment.category;
      paymentsByCategory[category] = [...(paymentsByCategory[category] ?? []), payment];
    }

    // Обновляем словарь ключевых слов на основе размеченных данных
    for (final entry in paymentsByCategory.entries) {
      final category = entry.key;
      final payments = entry.value;

      // Извлекаем ключевые слова из описаний платежей
      final words = <String>{};
      for (final payment in payments) {
        final description = _getDescription(payment);
        // Разбиваем описание на слова
        final descriptionWords =
            description
                .split(RegExp(r'[\s,\.;:!?]+'))
                .where((word) => word.length > 3) // Игнорируем короткие слова
                .toList();
        words.addAll(descriptionWords);
      }

      // Добавляем новые ключевые слова в словарь
      _categoryKeywords[category] =
          [
            ...(_categoryKeywords[category] ?? []),
            ...words,
          ].toSet().cast<String>().toList(); // Удаляем дубликаты и приводим к List<String>
    }

    // Обновляем пользовательские правила
    // Ищем уникальные описания, которые всегда соответствуют одной категории
    final descriptionCategories = <String, Set<String>>{};
    for (final payment in validPayments) {
      final description = _getDescription(payment);
      final category = payment.category;

      descriptionCategories[description] = {
        ...(descriptionCategories[description] ?? {}),
        category,
      };
    }

    // Если описание всегда соответствует одной категории, добавляем правило
    for (final entry in descriptionCategories.entries) {
      final description = entry.key;
      final categories = entry.value;

      if (categories.length == 1) {
        _userRules[description] = categories.first;
      }
    }
  }

  /// Получает описание платежа из объекта IFinancialData
  ///
  /// Если в additionalData есть поле description, используем его
  /// В противном случае используем id платежа
  String _getDescription(IFinancialData payment) {
    // Пытаемся получить описание из additionalData
    final additionalData = payment.additionalData;
    if (additionalData != null && additionalData.containsKey('description')) {
      final description = additionalData['description'];
      if (description is String) {
        return description.toLowerCase();
      }
    }

    // Если описания нет, используем id платежа
    return payment.id.toLowerCase();
  }

  /// Добавляет пользовательское правило категоризации
  void addUserRule(String keyword, String category) {
    _userRules[keyword.toLowerCase()] = category;
  }

  /// Удаляет пользовательское правило категоризации
  void removeUserRule(String keyword) {
    _userRules.remove(keyword.toLowerCase());
  }

  /// Очищает все пользовательские правила
  void clearUserRules() {
    _userRules.clear();
  }
}

/// Категоризатор платежей на основе TensorFlow Lite
///
/// Использует предобученную модель TensorFlow Lite для категоризации
/// платежей на основе их описания и суммы
///
/// Примечание: Это заглушка для демонстрации. Для реальной реализации
/// потребуется добавить зависимость tflite_flutter и реализовать
/// загрузку и использование модели.
class TFLitePaymentCategorizer implements IPaymentCategorizer {
  /// Категоризирует платеж на основе его данных
  @override
  String categorize(IFinancialData payment) {
    // Заглушка - в реальной реализации здесь будет код для использования TF Lite
    return 'Прочее';
  }

  /// Категоризирует список платежей
  @override
  List<IFinancialData> categorizeAll(List<IFinancialData> payments) {
    // Заглушка - в реальной реализации здесь будет код для использования TF Lite
    return payments;
  }

  /// Обучает категоризатор на основе размеченных данных
  @override
  Future<void> train(List<IFinancialData> labeledPayments) async {
    // Заглушка - в реальной реализации здесь будет код для обучения модели
  }
}

/// Фабрика для создания категоризаторов платежей
class PaymentCategorizerFactory {
  /// Создает простой категоризатор на основе ключевых слов и правил
  static IPaymentCategorizer createSimpleCategorizer() {
    return SimplePaymentCategorizer();
  }

  /// Создает категоризатор на основе TensorFlow Lite
  ///
  /// Примечание: Это заглушка для демонстрации. Для реальной реализации
  /// потребуется добавить зависимость tflite_flutter и реализовать
  /// загрузку и использование модели.
  static IPaymentCategorizer createTFLiteCategorizer() {
    return TFLitePaymentCategorizer();
  }
}
