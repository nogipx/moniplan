import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Модель категоризации платежа
class CategoryPrediction {
  final String category;
  final double probability;

  CategoryPrediction({required this.category, required this.probability});

  @override
  String toString() => '$category (${(probability * 100).toStringAsFixed(1)}%)';
}

/// Сервис для категоризации платежей с использованием TensorFlow Lite модели
class PaymentCategorizerService {
  static const String _modelPath = 'assets/tflite/payment_categorizer.tflite';

  /// Максимальная длина последовательности для модели
  static const int maxSequenceLength = 96;

  /// Словарь для токенизации
  final Map<String, int> _vocab = {'<OOV>': 1};

  /// Маппинг индексов категорий в их названия
  final Map<String, String> _categoryMapping = {};

  /// Экземпляр интерпретатора TFLite
  Interpreter? _interpreter;

  /// Флаг, указывающий, инициализирован ли сервис
  bool _isInitialized = false;

  /// Геттер для проверки инициализации сервиса
  bool get isInitialized => _isInitialized;

  /// Инициализирует сервис, загружая модель и необходимые данные
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Загружаем модель
      final interpreterOptions = InterpreterOptions();

      // Для релизной сборки используем модель из assets
      if (kReleaseMode) {
        final modelData = await rootBundle.load(_modelPath);
        _interpreter = await Interpreter.fromBuffer(
          modelData.buffer.asUint8List(),
          options: interpreterOptions,
        );
      } else {
        // Для отладки копируем модель во временную директорию
        final appDir = await getTemporaryDirectory();
        final modelFile = File(join(appDir.path, 'payment_categorizer.tflite'));

        if (!await modelFile.exists()) {
          final modelData = await rootBundle.load(_modelPath);
          await modelFile.writeAsBytes(modelData.buffer.asUint8List());
        }

        _interpreter = await Interpreter.fromFile(modelFile, options: interpreterOptions);
      }

      // Загружаем словарь и маппинг категорий
      await _loadVocabAndCategories();

      _isInitialized = true;
      debugPrint('PaymentCategorizerService: инициализация завершена успешно');
    } catch (e) {
      debugPrint('PaymentCategorizerService: ошибка инициализации - $e');
      rethrow;
    }
  }

  /// Загружает словарь и маппинг категорий
  Future<void> _loadVocabAndCategories() async {
    _categoryMapping.addAll({
      '0': 'Автомобиль',
      '1': 'Бизнес',
      '2': 'Дети и образование',
      '3': 'Домашние животные',
      '4': 'Жильё и коммунальные',
      '5': 'Зарплата',
      '6': 'Инвестиции и накопления',
      '7': 'Красота и здоровье',
      '8': 'Кредиты и долги',
      '9': 'Кэшбэк и бонусы',
      '10': 'Медицина',
      '11': 'Налоги и штрафы',
      '12': 'Обучение',
      '13': 'Одежда и обувь',
      '14': 'Пассивный доход',
      '15': 'Подарки и благотворительность',
      '16': 'Подарки и переводы',
      '17': 'Призы и выигрыши',
      '18': 'Продажа вещей',
      '19': 'Продукты',
      '20': 'Путешествия',
      '21': 'Рабочие расходы',
      '22': 'Развлечения',
      '23': 'Ремонт и обустройство',
      '24': 'Связь и подписки',
      '25': 'Социальные выплаты',
      '26': 'Страхование',
      '27': 'Транспорт',
      '28': 'Фриланс',
      '29': 'Хобби и увлечения',
      '30': 'Экстренные расходы',
    });
  }

  /// Предобрабатывает текст для модели
  String _preprocessText(String text) {
    if (text.isEmpty) return '';
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Токенизирует текст в последовательность чисел
  List<int> _tokenize(String text) {
    final processed = _preprocessText(text);
    if (processed.isEmpty) return List.filled(maxSequenceLength, 0);

    final words = processed.split(' ');
    final tokens = words.map((word) => _vocab[word] ?? 1).toList();

    if (tokens.length > maxSequenceLength) {
      return tokens.sublist(0, maxSequenceLength);
    } else {
      return tokens + List.filled(maxSequenceLength - tokens.length, 0);
    }
  }

  /// Предсказывает категорию платежа на основе текста и флага дохода
  Future<List<CategoryPrediction>> predictCategory(String text, bool isIncome) async {
    if (!_isInitialized) {
      throw Exception('PaymentCategorizerService не инициализирован');
    }

    if (_interpreter == null) {
      throw Exception('TFLite интерпретатор не инициализирован');
    }

    try {
      // Токенизируем текст
      final sequence = _tokenize(text);

      // Подготавливаем входные данные
      final input0 = [sequence];
      final input1 = [isIncome ? 1.0 : 0.0];

      // Подготавливаем выходные данные
      final output = List<List<double>>.filled(1, List<double>.filled(_categoryMapping.length, 0));

      // Запускаем модель
      final inputs = [input0, input1];
      final outputs = {0: output};
      _interpreter!.runForMultipleInputs(inputs, outputs);

      // Получаем результаты
      final predictions = output[0];

      // Сортируем категории по вероятности
      final indexedPredictions = List<MapEntry<int, double>>.generate(
        predictions.length,
        (index) => MapEntry(index, predictions[index]),
      );

      indexedPredictions.sort((a, b) => b.value.compareTo(a.value));

      // Берем топ-3 категории
      final topK = 3;
      final topCategories = <CategoryPrediction>[];

      for (int i = 0; i < min(topK, indexedPredictions.length); i++) {
        final index = indexedPredictions[i].key;
        final probability = indexedPredictions[i].value;

        // Добавляем только если вероятность выше порога
        if (probability > 0.05) {
          topCategories.add(
            CategoryPrediction(
              category: _categoryMapping[index.toString()] ?? 'Неизвестно',
              probability: probability,
            ),
          );
        }
      }

      return topCategories;
    } catch (e) {
      debugPrint('PaymentCategorizerService: ошибка предсказания - $e');
      return [];
    }
  }

  /// Освобождает ресурсы
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
