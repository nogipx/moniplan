import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Сервис для категоризации платежей с использованием TensorFlow Lite модели
class PaymentCategorizerService {
  static const String _modelPath = 'assets/tflite/payment_categorizer.tflite';
  static const String _vocabPath = 'assets/tflite/vocab.json';
  static const String _categoryMappingPath = 'assets/tflite/category_mapping.json';
  static const String _metadataPath = 'assets/tflite/model_metadata.json';

  // Статический счетчик для отслеживания количества созданных экземпляров
  static int _instanceCount = 0;
  final int _instanceId;

  /// Конструктор
  PaymentCategorizerService() : _instanceId = ++_instanceCount {
    debugPrint(
      'PaymentCategorizerService: создан экземпляр #$_instanceId (всего: $_instanceCount)',
    );
  }

  /// Максимальная длина последовательности для модели
  static const int maxSequenceLength = 96;

  /// Словарь для токенизации
  final Map<String, int> _vocab = {'<OOV>': 1};

  /// Маппинг индексов категорий в их названия
  final Map<String, String> _categoryMapping = {};

  /// Метаданные модели
  Map<String, dynamic>? _metadata;

  /// Экземпляр интерпретатора TFLite
  Interpreter? _interpreter;

  /// Флаг, указывающий, инициализирован ли сервис
  bool _isInitialized = false;

  /// Геттер для проверки инициализации сервиса
  bool get isInitialized => _isInitialized;

  /// Инициализирует сервис, загружая модель и необходимые данные
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('PaymentCategorizerService #$_instanceId: уже инициализирован, пропускаем');
      return;
    }

    debugPrint('PaymentCategorizerService #$_instanceId: начало инициализации');
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
      debugPrint('PaymentCategorizerService #$_instanceId: инициализация завершена успешно');

      // Выводим информацию о модели
      _printModelInfo();
    } catch (e) {
      debugPrint('PaymentCategorizerService #$_instanceId: ошибка инициализации - $e');
      rethrow;
    }
  }

  /// Загружает словарь и маппинг категорий
  Future<void> _loadVocabAndCategories() async {
    try {
      // Загружаем словарь
      final vocabString = await rootBundle.loadString(_vocabPath);

      final vocabJson = jsonDecode(vocabString) as Map<String, dynamic>;

      _vocab.clear();
      vocabJson.forEach((key, value) {
        _vocab[key] = value as int;
      });

      // Загружаем маппинг категорий
      final categoryMappingString = await rootBundle.loadString(_categoryMappingPath);
      final categoryMappingJson = jsonDecode(categoryMappingString) as Map<String, dynamic>;
      _categoryMapping.clear();
      categoryMappingJson.forEach((key, value) {
        _categoryMapping[key] = value as String;
      });

      // Загружаем метаданные модели
      final metadataString = await rootBundle.loadString(_metadataPath);
      _metadata = jsonDecode(metadataString) as Map<String, dynamic>;

      debugPrint('Загружен словарь с ${_vocab.length} словами');
      debugPrint('Загружен маппинг категорий с ${_categoryMapping.length} категориями');
    } catch (e) {
      debugPrint('Ошибка при загрузке словаря и маппинга категорий: $e');
      rethrow;
    }
  }

  /// Предобрабатывает текст для модели
  String _preprocessText(String text) {
    if (text.isEmpty) return '';

    // Приводим к нижнему регистру
    text = text.toLowerCase();

    // Заменяем специфичные символы, сохраняя кириллицу и латиницу
    // Регулярное выражение: сохраняем буквы (включая кириллицу), цифры, пробелы и некоторые специальные символы
    text = text.replaceAll(RegExp(r'[^\p{L}\p{N}\s№.,-_()€₽$]', unicode: true), ' ');

    // Удаляем лишние пробелы
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  /// Токенизирует текст в последовательность чисел
  List<int> _tokenize(String text) {
    final processed = _preprocessText(text);
    if (processed.isEmpty) {
      return List.filled(maxSequenceLength, 0);
    }

    final words = processed.split(' ');

    // Проверяем каждое слово в словаре
    final tokens = <int>[];
    for (final word in words) {
      if (word.isEmpty) continue;

      final token = _vocab[word];
      if (token != null) {
        tokens.add(token);
      } else {
        tokens.add(1); // 1 - это <OOV> (out of vocabulary)
      }
    }

    if (tokens.isEmpty) {
      return List.filled(maxSequenceLength, 0);
    }

    // Создаем список нужной длины, заполненный нулями
    final result = List<int>.filled(maxSequenceLength, 0);

    // Копируем токены в начало списка
    for (int i = 0; i < tokens.length && i < maxSequenceLength; i++) {
      result[i] = tokens[i];
    }

    return result;
  }

  /// Предсказывает категорию платежа на основе текста и флага дохода
  Future<List<CategoryPrediction>> predict(String text, bool isIncome) async {
    if (!_isInitialized) {
      debugPrint('PaymentCategorizerService #$_instanceId: попытка предсказания без инициализации');
      throw Exception('PaymentCategorizerService не инициализирован');
    }

    if (_interpreter == null) {
      debugPrint(
        'PaymentCategorizerService #$_instanceId: TFLite интерпретатор не инициализирован',
      );
      throw Exception('TFLite интерпретатор не инициализирован');
    }

    try {
      // Токенизируем текст
      final sequence = _tokenize(text);

      // Получаем информацию о входных тензорах
      final inputTensors = _interpreter!.getInputTensors();

      // Подготавливаем выходные данные
      final output = List<List<double>>.filled(1, List<double>.filled(_categoryMapping.length, 0));

      try {
        // Подготавливаем входные данные в соответствии с порядком, выявленным при отладке Python-скрипта
        // Первый вход (input0) - флаг дохода в формате [batch_size, 1]
        final input0 = [
          [isIncome ? 1.0 : 0.0],
        ];

        // Второй вход (input1) - последовательность токенов в формате [batch_size, sequence_length]
        final input1 = [sequence];

        // Объединяем входы в правильном порядке
        final inputs = <Object>[input0, input1];
        final outputs = {0: output};

        // Запускаем модель
        _interpreter!.runForMultipleInputs(inputs, outputs);

        // Обрабатываем результаты
        final result = _processOutput(output[0]);
        return result;
      } catch (e) {
        debugPrint('Ошибка при выполнении предсказания: $e');

        // Пробуем альтернативный вариант с адаптивным определением входов
        try {
          // Определяем, какой вход для чего предназначен по форме
          int? isIncomeTensorIdx;
          int? sequenceTensorIdx;

          for (int i = 0; i < inputTensors.length; i++) {
            final shape = inputTensors[i].shape;
            if (shape.length == 2 && shape[1] == 1) {
              isIncomeTensorIdx = i;
            } else if (shape.length == 2 && shape[1] == maxSequenceLength) {
              sequenceTensorIdx = i;
            }
          }

          if (isIncomeTensorIdx != null && sequenceTensorIdx != null) {
            final adaptiveInputs = <Object>[];
            // Заполняем массив inputs нужного размера
            for (int i = 0; i < inputTensors.length; i++) {
              adaptiveInputs.add([]);
            }

            // Устанавливаем входные данные в соответствии с определенными индексами
            adaptiveInputs[isIncomeTensorIdx] = [
              [isIncome ? 1.0 : 0.0],
            ];
            adaptiveInputs[sequenceTensorIdx] = [sequence];

            final adaptiveOutputs = {0: output};
            _interpreter!.runForMultipleInputs(adaptiveInputs, adaptiveOutputs);

            final result = _processOutput(output[0]);
            return result;
          } else {
            debugPrint(
              'PaymentCategorizerService #$_instanceId: не удалось определить индексы входных тензоров по форме',
            );
            throw Exception('Не удалось определить индексы входных тензоров по форме');
          }
        } catch (e2) {
          debugPrint(
            'PaymentCategorizerService #$_instanceId: не удалось выполнить предсказание: $e, $e2',
          );
          throw Exception('Не удалось выполнить предсказание: $e, $e2');
        }
      }
    } catch (e) {
      debugPrint('PaymentCategorizerService #$_instanceId: ошибка предсказания - $e');
      rethrow;
    }
  }

  /// Выводит информацию о модели для отладки
  void _printModelInfo() {
    try {
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();

      debugPrint('=== Информация о модели ===');
      debugPrint('Количество входных тензоров: ${inputTensors.length}');
      for (int i = 0; i < inputTensors.length; i++) {
        final tensor = inputTensors[i];
        debugPrint('Вход #$i: форма: ${tensor.shape.join('x')}');
      }

      debugPrint('Количество выходных тензоров: ${outputTensors.length}');
      for (int i = 0; i < outputTensors.length; i++) {
        final tensor = outputTensors[i];
        debugPrint('Выход #$i: форма: ${tensor.shape.join('x')}');
      }

      debugPrint('=========================');
    } catch (e) {
      debugPrint('Ошибка при получении информации о модели: $e');
    }
  }

  /// Обрабатывает выходные данные модели
  List<CategoryPrediction> _processOutput(List<double> predictions) {
    // Сортируем категории по вероятности
    final indexedPredictions = List<MapEntry<int, double>>.generate(
      predictions.length,
      (index) => MapEntry(index, predictions[index]),
    );

    indexedPredictions.sort((a, b) => b.value.compareTo(a.value));

    // Берем топ-3 категории
    final topK = _metadata?['top_k'] as int? ?? 3;
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
  }

  /// Освобождает ресурсы
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
