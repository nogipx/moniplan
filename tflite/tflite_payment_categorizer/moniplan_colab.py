#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Скрипт для обучения модели TensorFlow Lite для категоризации платежей.
Оптимизирован для запуска в Google Colab.

Инструкция по использованию:
1. Открой Google Colab (https://colab.research.google.com/)
2. Создай новый ноутбук
3. Скопируй и вставь этот код в ячейку
4. Запусти ячейку
"""

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import json
import tensorflow as tf
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from google.colab import files, drive
import time
import re
import random
import datetime
from nltk.corpus import stopwords
from nltk.stem import SnowballStemmer

# Принудительно отключаем смешанную точность
tf.keras.mixed_precision.set_global_policy('float32')

print("TensorFlow версия:", tf.__version__)
print("Доступные GPU:", tf.config.list_physical_devices('GPU'))
print("Политика точности:", tf.keras.mixed_precision.global_policy().name)

# Константы - сбалансированы для работы с улучшенными данными
MAX_SEQUENCE_LENGTH = 96  # Достаточно для обработки более длинных названий с эмодзи
EMBEDDING_DIM = 96  # Увеличиваем для лучшего представления сложных данных
VOCAB_SIZE = 10000  # Увеличиваем для покрытия эмодзи и специальных символов
BATCH_SIZE = 256  # Оптимальный размер батча
EPOCHS = 15  # Достаточно для обучения
DROPOUT_RATE = 0.25  # Оптимальный дропаут
L2_REGULARIZATION = 0.0001  # Оставляем ту же регуляризацию

# Функция для очистки и нормализации текста - улучшена для работы с эмодзи и спецсимволами
def preprocess_text(text):
    if not isinstance(text, str):
        return ""
    
    # Приводим к нижнему регистру
    text = text.lower()
    
    # Сохраняем эмодзи и специальные символы, которые могут быть информативными
    # Заменяем только очень специфичные символы, сохраняем эмодзи, номера, даты и т.д.
    text = re.sub(r'[^\w\s\u2600-\u26FF\u2700-\u27BF№.,-_()€₽$]', ' ', text)
    
    # Удаляем лишние пробелы
    text = re.sub(r'\s+', ' ', text).strip()
    
    # Удаляем стоп-слова и применяем стемминг, если доступно
    if stemmer:
        words = text.split()
        words = [stemmer.stem(word) for word in words if word not in russian_stopwords and word not in english_stopwords]
        text = ' '.join(words)
    
    return text

# Шаг 1: Загрузка данных
print("\n=== Шаг 1: Загрузка данных ===")

# Выбор метода загрузки данных
upload_method = input("Выберите метод загрузки данных (1 - загрузить с компьютера, 2 - загрузить с Google Drive): ")

if upload_method == "1":
    print("Пожалуйста, выберите CSV-файл с данными для обучения...")
    uploaded = files.upload()  # Откроется диалог выбора файла
    csv_file = list(uploaded.keys())[0]
    print(f"Загружен файл: {csv_file}")
elif upload_method == "2":
    print("Подключение к Google Drive...")
    drive.mount('/content/drive')
    drive_path = input("Введите путь к CSV-файлу на Google Drive (например, '/content/drive/My Drive/training_data.csv'): ")
    csv_file = drive_path
else:
    raise ValueError("Неверный выбор метода загрузки")

# Загрузка данных
print(f"Загрузка данных из {csv_file}...")
df = pd.read_csv(csv_file)
print(f"Загружено {len(df)} записей")

# Проверка структуры данных
print("\nСтруктура данных:")
print(f"Колонки: {df.columns.tolist()}")
print(f"Первые 5 записей:")
print(df.head(5))

# Проверка на пропущенные значения
missing_values = df.isnull().sum()
print(f"\nПропущенные значения:\n{missing_values}")

# Шаг 2: Предобработка данных
print("\n=== Шаг 2: Предобработка данных ===")

# Очистка данных
print("Очистка данных...")
initial_rows = len(df)
df = df.dropna(subset=['text', 'category'])
df = df[df['text'].astype(str).str.strip() != '']
df = df[df['category'].astype(str).str.strip() != '']
print(f"Удалено {initial_rows - len(df)} строк с пустыми значениями")

# Предобработка текста
print("Предобработка текста...")

# Загружаем необходимые ресурсы NLTK
try:
    import nltk
    nltk.download('stopwords', quiet=True)
    russian_stopwords = set(stopwords.words('russian'))
    english_stopwords = set(stopwords.words('english'))
    stemmer = SnowballStemmer('russian')
except:
    print("Не удалось загрузить NLTK ресурсы, используем базовую предобработку")
    russian_stopwords = set()
    english_stopwords = set()
    stemmer = None

# Применяем предобработку к описаниям
df['processed_description'] = df['text'].apply(preprocess_text)
print("Предобработка текста завершена")

# Выводим примеры предобработанных текстов
print("\nПримеры предобработанных текстов:")
for i in range(min(5, len(df))):
    print(f"Оригинал: {df['text'].iloc[i]}")
    print(f"Обработанный: {df['processed_description'].iloc[i]}")
    print()

# Кодирование категорий
print("Кодирование категорий...")
label_encoder = LabelEncoder()
y = label_encoder.fit_transform(df['category'])

# Сохраняем маппинг категорий
category_mapping = {i: category for i, category in enumerate(label_encoder.classes_)}
print(f"Категории закодированы. Количество классов: {len(label_encoder.classes_)}")

# Анализ распределения категорий
category_counts = df['category'].value_counts()
print(f"Распределение категорий (топ-10):\n{category_counts.head(10)}")

# Токенизация текста
print("Токенизация описаний...")
tokenizer = Tokenizer(num_words=VOCAB_SIZE, oov_token="<OOV>")
tokenizer.fit_on_texts(df['processed_description'])  # Используем предобработанный текст
print(f"Словарь создан. Размер словаря: {len(tokenizer.word_index)} слов")

# Преобразование текстов в последовательности
sequences = tokenizer.texts_to_sequences(df['processed_description'])
X_text = pad_sequences(sequences, maxlen=MAX_SEQUENCE_LENGTH, padding='post')
print(f"Тексты преобразованы в последовательности. Форма: {X_text.shape}")

# Подготовка признака типа транзакции (доход/расход)
print("Подготовка признака типа транзакции...")
if 'type' in df.columns:
    X_type = df['type'].values.reshape(-1, 1)
    print(f"Признак типа транзакции подготовлен. Форма: {X_type.shape}")
else:
    # Если колонки type нет, создаем фиктивную
    print("Колонка 'type' отсутствует. Создаем фиктивную колонку...")
    X_type = np.zeros((len(df), 1))

# Разделение данных на обучающую и тестовую выборки
print("Разделение данных на обучающую и тестовую выборки...")
X_text_train, X_text_test, X_type_train, X_type_test, y_train, y_test = train_test_split(
    X_text, X_type, y, test_size=0.2, random_state=42, stratify=y
)
print(f"Размер обучающей выборки: {len(X_text_train)} записей")
print(f"Размер тестовой выборки: {len(X_text_test)} записей")

# Шаг 3: Создание сбалансированной модели
print("\n=== Шаг 3: Создание сбалансированной модели ===")

# Модель для текста с поддержкой сложных данных
text_input = tf.keras.Input(shape=(MAX_SEQUENCE_LENGTH,), name='text_input')

# Слой эмбеддинга с небольшой регуляризацией
x = tf.keras.layers.Embedding(
    VOCAB_SIZE, 
    EMBEDDING_DIM, 
    input_length=MAX_SEQUENCE_LENGTH,
    embeddings_regularizer=tf.keras.regularizers.l2(L2_REGULARIZATION/10)  # Очень легкая регуляризация
)(text_input)

# Эффективные свертки для захвата разных паттернов
x = tf.keras.layers.SpatialDropout1D(0.1)(x)  # Легкий дропаут для эмбеддингов
conv1 = tf.keras.layers.Conv1D(filters=48, kernel_size=3, padding='valid', activation='relu')(x)
conv2 = tf.keras.layers.Conv1D(filters=48, kernel_size=4, padding='valid', activation='relu')(x)

# Глобальный пулинг
pool1 = tf.keras.layers.GlobalMaxPooling1D()(conv1)
pool2 = tf.keras.layers.GlobalMaxPooling1D()(conv2)

# Объединяем результаты сверток
x = tf.keras.layers.concatenate([pool1, pool2])
x = tf.keras.layers.Dense(96, activation='relu')(x)
x = tf.keras.layers.Dropout(DROPOUT_RATE)(x)

text_model = tf.keras.Model(inputs=text_input, outputs=x)
print(f"Создана сбалансированная модель для текста: {text_model.output_shape}")

# Модель для типа транзакции
type_input = tf.keras.Input(shape=(1,), name='type_input')
y = tf.keras.layers.Dense(8, activation='relu')(type_input)
type_model = tf.keras.Model(inputs=type_input, outputs=y)
print(f"Создана модель для типа транзакции: {type_model.output_shape}")

# Объединяем модели
combined = tf.keras.layers.concatenate([text_model.output, type_model.output])
z = tf.keras.layers.Dense(96, activation='relu')(combined)
z = tf.keras.layers.Dropout(DROPOUT_RATE)(z)
output = tf.keras.layers.Dense(len(label_encoder.classes_), activation='softmax')(z)

model = tf.keras.Model(inputs=[text_input, type_input], outputs=output)

# Используем оптимизатор Adam с фиксированной скоростью обучения
# Убираем планировщик, чтобы ReduceLROnPlateau мог работать
optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)

# Компилируем модель
model.compile(
    loss='sparse_categorical_crossentropy',
    optimizer=optimizer,
    metrics=[
        'accuracy',
        tf.keras.metrics.SparseTopKCategoricalAccuracy(k=3, name='top_3_accuracy'),
        tf.keras.metrics.SparseTopKCategoricalAccuracy(k=5, name='top_5_accuracy')
    ]
)

print("Сбалансированная модель создана и скомпилирована")
model.summary()

# Шаг 4: Обучение модели
print("\n=== Шаг 4: Обучение модели ===")

# Создаем директорию для логов и чекпоинтов
os.makedirs("logs", exist_ok=True)
os.makedirs("checkpoints", exist_ok=True)

# Оптимальные колбэки
callbacks = [
    # Ранняя остановка
    tf.keras.callbacks.EarlyStopping(
        monitor='val_accuracy',
        patience=4,  # Оптимальное терпение
        restore_best_weights=True
    ),
    # Сохранение лучшей модели
    tf.keras.callbacks.ModelCheckpoint(
        "checkpoints/best_model.h5",
        monitor='val_accuracy',
        save_best_only=True,
        verbose=1
    ),
    # Адаптивное уменьшение скорости обучения
    tf.keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.7,  # Более мягкое уменьшение
        patience=2,
        min_lr=0.0001,
        verbose=1
    )
]

# Засекаем время обучения
start_time = time.time()

# Обучаем модель
print(f"Начало обучения на {len(X_text_train)} примерах, валидация на {len(X_text_test)} примерах")
print(f"Параметры обучения: batch_size={BATCH_SIZE}, epochs={EPOCHS}")

history = model.fit(
    [X_text_train, X_type_train],
    y_train,
    batch_size=BATCH_SIZE,
    epochs=EPOCHS,
    validation_data=([X_text_test, X_type_test], y_test),
    callbacks=callbacks,
    verbose=1
)

training_time = time.time() - start_time
print(f"Обучение завершено за {training_time:.2f} секунд")

# Шаг 5: Оценка модели
print("\n=== Шаг 5: Оценка модели ===")

# Оцениваем модель
evaluation = model.evaluate([X_text_test, X_type_test], y_test, verbose=1)
print(f"Точность на тестовой выборке: {evaluation[1]:.4f}, потери: {evaluation[0]:.4f}")
print(f"Top-3 точность: {evaluation[2]:.4f}")
print(f"Top-5 точность: {evaluation[3]:.4f}")

# Предсказываем категории
y_pred = model.predict([X_text_test, X_type_test])
y_pred_classes = np.argmax(y_pred, axis=1)

# Вычисляем метрики
from sklearn.metrics import classification_report, confusion_matrix

# Создаем отчет о классификации
class_report = classification_report(
    y_test, 
    y_pred_classes, 
    target_names=label_encoder.classes_,
    zero_division=0
)
print(f"Отчет о классификации:\n{class_report}")

# Анализ ошибок классификации
print("\nАнализ ошибок классификации:")
errors = []
for i in range(len(y_test)):
    if y_test[i] != y_pred_classes[i]:
        true_category = label_encoder.inverse_transform([y_test[i]])[0]
        pred_category = label_encoder.inverse_transform([y_pred_classes[i]])[0]
        confidence = y_pred[i][y_pred_classes[i]]
        
        # Находим соответствующее описание
        idx = X_text_test.shape[0] - i - 1
        if idx < len(df):
            description = df['text'].iloc[idx]
            transaction_type = df['type'].iloc[idx] if 'type' in df.columns else 0
            
            errors.append({
                'description': description,
                'type': transaction_type,
                'true_category': true_category,
                'pred_category': pred_category,
                'confidence': confidence
            })

# Выводим первые 10 ошибок
print("Примеры ошибок классификации:")
for i, error in enumerate(errors[:10]):
    print(f"Ошибка {i+1}:")
    print(f"  Описание: {error['description']}")
    print(f"  Тип: {error['type']}")
    print(f"  Истинная категория: {error['true_category']}")
    print(f"  Предсказанная категория: {error['pred_category']}")
    print(f"  Уверенность: {error['confidence']:.4f}")
    print()

# Шаг 6: Визуализация результатов
print("\n=== Шаг 6: Визуализация результатов ===")

plt.figure(figsize=(15, 10))

# График точности
plt.subplot(2, 2, 1)
plt.plot(history.history['accuracy'])
plt.plot(history.history['val_accuracy'])
plt.title('Точность модели')
plt.ylabel('Точность')
plt.xlabel('Эпоха')
plt.legend(['Обучающая выборка', 'Тестовая выборка'], loc='lower right')

# График функции потерь
plt.subplot(2, 2, 2)
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('Функция потерь')
plt.ylabel('Потери')
plt.xlabel('Эпоха')
plt.legend(['Обучающая выборка', 'Тестовая выборка'], loc='upper right')

# График Top-K точности
plt.subplot(2, 2, 3)
plt.plot(history.history['top_3_accuracy'])
plt.plot(history.history['val_top_3_accuracy'])
plt.plot(history.history['top_5_accuracy'])
plt.plot(history.history['val_top_5_accuracy'])
plt.title('Top-K точность')
plt.ylabel('Точность')
plt.xlabel('Эпоха')
plt.legend(['Top-3 (обучение)', 'Top-3 (валидация)', 'Top-5 (обучение)', 'Top-5 (валидация)'], loc='lower right')

# Матрица ошибок для топ-10 категорий
plt.subplot(2, 2, 4)
top_categories = category_counts.head(10).index
top_cat_indices = [label_encoder.transform([cat])[0] for cat in top_categories]

# Фильтруем только топ-10 категорий
mask_test = np.isin(y_test, top_cat_indices)
y_test_top = y_test[mask_test]
y_pred_top = y_pred_classes[mask_test]

# Создаем матрицу ошибок
cm = confusion_matrix(y_test_top, y_pred_top)
cm_norm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]

# Визуализируем матрицу ошибок
import seaborn as sns
sns.heatmap(cm_norm, annot=True, fmt='.2f', cmap='Blues',
            xticklabels=[label_encoder.classes_[i] for i in top_cat_indices],
            yticklabels=[label_encoder.classes_[i] for i in top_cat_indices])
plt.title('Матрица ошибок (нормализованная)')
plt.ylabel('Истинная категория')
plt.xlabel('Предсказанная категория')
plt.xticks(rotation=45, ha='right')
plt.yticks(rotation=45)

plt.tight_layout()
plt.savefig('training_history.png', dpi=300)
plt.show()

# Шаг 7: Конвертация модели в TensorFlow Lite
print("\n=== Шаг 7: Конвертация модели в TensorFlow Lite ===")

# Анализ топ-3 предсказаний
print("\n=== Анализ топ-3 предсказаний ===")
# Получаем топ-3 предсказания для каждой транзакции
top_k = 3
top_k_indices = np.argsort(y_pred, axis=1)[:, -top_k:][:, ::-1]  # Сортируем и берем последние k элементов, затем переворачиваем
top_k_probabilities = np.sort(y_pred, axis=1)[:, -top_k:][:, ::-1]  # То же самое для вероятностей

# Преобразуем индексы в названия категорий
top_k_categories = []
for indices in top_k_indices:
    categories = [label_encoder.classes_[idx] for idx in indices]
    top_k_categories.append(categories)

# Выводим примеры топ-3 предсказаний
print("Примеры топ-3 предсказаний:")
for i in range(min(10, len(y_test))):
    print(f"Пример {i+1}:")
    print(f"  Описание: {df['text'].iloc[X_text_test.shape[0] - i - 1] if X_text_test.shape[0] - i - 1 < len(df) else 'Н/Д'}")
    print(f"  Истинная категория: {label_encoder.inverse_transform([y_test[i]])[0]}")
    for j in range(top_k):
        print(f"  Предсказание {j+1}: {top_k_categories[i][j]} ({top_k_probabilities[i][j]:.4f})")
    print()

# Анализируем точность топ-3 предсказаний
top_3_accuracy = sum(1 for i in range(len(y_test)) if label_encoder.inverse_transform([y_test[i]])[0] in top_k_categories[i]) / len(y_test)
print(f"Точность топ-3 предсказаний: {top_3_accuracy:.4f}")

# Сохраняем примеры топ-3 предсказаний для использования в приложении
top_k_examples = []
for i in range(min(100, len(y_test))):
    if X_text_test.shape[0] - i - 1 < len(df):
        example = {
            'text': df['text'].iloc[X_text_test.shape[0] - i - 1],
            'true_category': label_encoder.inverse_transform([y_test[i]])[0],
            'predictions': [
                {'category': top_k_categories[i][j], 'probability': float(top_k_probabilities[i][j])}
                for j in range(top_k)
            ]
        }
        top_k_examples.append(example)

# Сохраняем примеры в JSON
with open('top_k_examples.json', 'w', encoding='utf-8') as f:
    json.dump(top_k_examples, f, ensure_ascii=False, indent=4)
print(f"Сохранено {len(top_k_examples)} примеров топ-3 предсказаний в top_k_examples.json")

# Пример кода для использования топ-3 предсказаний в приложении
print("\nПример кода для использования топ-3 предсказаний в приложении:")
print("""
// Dart код для использования топ-3 предсказаний
List<CategoryPrediction> predictCategory(String text, bool isIncome) {
  // Предобработка текста
  final processedText = preprocessText(text);
  
  // Токенизация и преобразование в последовательность
  final sequence = tokenize(processedText);
  
  // Получение предсказаний от модели
  final predictions = model.predict([sequence, [isIncome ? 1.0 : 0.0]]);
  
  // Получение топ-3 категорий с вероятностями
  final List<CategoryPrediction> topCategories = [];
  for (int i = 0; i < 3; i++) {
    final maxIndex = argmax(predictions, exclude: topCategories.map((p) => p.index).toList());
    final probability = predictions[maxIndex];
    
    // Добавляем только если вероятность выше порога
    if (probability > 0.05) {
      topCategories.add(CategoryPrediction(
        category: categoryMapping[maxIndex],
        probability: probability,
        index: maxIndex,
      ));
    }
  }
  
  return topCategories;
}

// Пример использования
void categorizeTransaction() {
  final text = "Кроссовки Adidas";
  final isIncome = false;
  
  final predictions = predictCategory(text, isIncome);
  
  // Вывод результатов
  print("Транзакция: $text");
  for (int i = 0; i < predictions.length; i++) {
    print("Категория ${i+1}: ${predictions[i].category} (${(predictions[i].probability * 100).toStringAsFixed(1)}%)");
  }
  
  // Автоматически выбираем категорию с наибольшей вероятностью,
  // но можем предложить пользователю выбрать из топ-3, если вероятность не очень высокая
  final selectedCategory = predictions.first;
  if (selectedCategory.probability < 0.7) {
    // Предлагаем пользователю выбрать из вариантов
    showCategorySelectionDialog(predictions);
  } else {
    // Автоматически используем категорию с наибольшей вероятностью
    applyCategory(selectedCategory.category);
  }
}
""")

# Конвертируем модель
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# Квантизация для уменьшения размера модели
print("Применение квантизации для уменьшения размера модели...")
converter.optimizations = [tf.lite.Optimize.DEFAULT]

tflite_model = converter.convert()

# Сохраняем модель
tflite_file = 'payment_categorizer.tflite'
with open(tflite_file, 'wb') as f:
    f.write(tflite_model)

model_size_kb = len(tflite_model) / 1024
print(f"Модель сохранена в {tflite_file} (размер: {model_size_kb:.2f} КБ)")

# Сохраняем маппинг категорий
with open('category_mapping.json', 'w', encoding='utf-8') as f:
    json.dump(category_mapping, f, ensure_ascii=False, indent=4)
print("Маппинг категорий сохранен в category_mapping.json")

# Сохраняем словарь
with open('vocab.json', 'w', encoding='utf-8') as f:
    json.dump(tokenizer.word_index, f, ensure_ascii=False, indent=4)
print("Словарь сохранен в vocab.json")

# Сохраняем метаданные модели
metadata = {
    'accuracy': float(evaluation[1]),
    'top_3_accuracy': float(evaluation[2]),
    'top_5_accuracy': float(evaluation[3]),
    'top_k_accuracy': float(top_3_accuracy),  # Добавляем точность топ-3 предсказаний
    'loss': float(evaluation[0]),
    'num_classes': len(label_encoder.classes_),
    'vocab_size': len(tokenizer.word_index) + 1,
    'max_sequence_length': MAX_SEQUENCE_LENGTH,
    'embedding_dim': EMBEDDING_DIM,
    'training_date': time.strftime('%Y-%m-%d %H:%M:%S'),
    'model_size_kb': model_size_kb,
    'training_samples': len(X_text_train),
    'test_samples': len(X_text_test),
    'epochs_used': len(history.history['accuracy']),
    'batch_size_used': BATCH_SIZE,
    'training_time_seconds': training_time,
    'categories': list(label_encoder.classes_),
    'top_k': top_k  # Добавляем информацию о количестве топ предсказаний
}

with open('model_metadata.json', 'w', encoding='utf-8') as f:
    json.dump(metadata, f, ensure_ascii=False, indent=4)
print("Метаданные модели сохранены в model_metadata.json")

# Шаг 8: Скачивание результатов
print("\n=== Шаг 8: Скачивание результатов ===")
print("Вы можете скачать следующие файлы:")

download_files = input("Хотите скачать файлы? (да/нет): ")
if download_files.lower() in ['да', 'yes', 'y', 'д']:
    files.download('payment_categorizer.tflite')
    files.download('category_mapping.json')
    files.download('vocab.json')
    files.download('model_metadata.json')
    files.download('training_history.png')
    files.download('top_k_examples.json')  # Добавляем скачивание примеров топ-3 предсказаний
    print("Файлы скачаны")

print("\nОбучение модели успешно завершено!") 