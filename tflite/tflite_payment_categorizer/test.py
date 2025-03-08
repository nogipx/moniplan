# -*- coding: utf-8 -*-
import json
import numpy as np
import tensorflow as tf
import os

# Пути к файлам
MODEL_PATH = 'payment_categorizer.tflite'
VOCAB_PATH = 'vocab.json'
CATEGORY_MAPPING_PATH = 'category_mapping.json'
METADATA_PATH = 'model_metadata.json'

# Максимальная длина последовательности
MAX_SEQUENCE_LENGTH = 96

def load_files():
    """Загружает необходимые файлы для работы модели"""
    # Загружаем словарь
    with open(VOCAB_PATH, 'r', encoding='utf-8') as f:
        vocab = json.load(f)
    
    # Загружаем маппинг категорий
    with open(CATEGORY_MAPPING_PATH, 'r', encoding='utf-8') as f:
        category_mapping = json.load(f)
    
    # Загружаем метаданные модели
    with open(METADATA_PATH, 'r', encoding='utf-8') as f:
        metadata = json.load(f)
    
    return vocab, category_mapping, metadata

def preprocess_text(text):
    """Предобрабатывает текст для модели"""
    if not text:
        return ''
    
    # Приводим к нижнему регистру
    text = text.lower()
    
    # Заменяем специфичные символы
    import re
    text = re.sub(r'[^\w\s№.,-_()€₽$]', ' ', text)
    
    # Удаляем лишние пробелы
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text

def tokenize(text, vocab):
    """Токенизирует текст в последовательность чисел"""
    processed = preprocess_text(text)
    if not processed:
        return [0] * MAX_SEQUENCE_LENGTH
    
    words = processed.split(' ')
    tokens = [vocab.get(word, 1) for word in words]  # 1 - это <OOV> (out of vocabulary)
    
    if len(tokens) > MAX_SEQUENCE_LENGTH:
        return tokens[:MAX_SEQUENCE_LENGTH]
    else:
        return tokens + [0] * (MAX_SEQUENCE_LENGTH - len(tokens))

def predict_category(text, is_income, interpreter, vocab, category_mapping):
    """Предсказывает категорию платежа на основе текста и флага дохода"""
    # Токенизируем текст
    sequence = tokenize(text, vocab)
    
    # Получаем информацию о входных и выходных тензорах
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"Входные тензоры: {len(input_details)}")
    for i, detail in enumerate(input_details):
        print(f"Вход #{i}: форма={detail['shape']}, тип={detail['dtype']}")
    
    print(f"Выходные тензоры: {len(output_details)}")
    for i, detail in enumerate(output_details):
        print(f"Выход #{i}: форма={detail['shape']}, тип={detail['dtype']}")
    
    # Подготавливаем входные данные
    # Пробуем разные форматы входных данных
    
    # Вариант 1: Стандартный формат, но меняем порядок входов
    try:
        print("\nПробуем вариант 1: Стандартный формат с правильным порядком")
        # Первый вход - флаг дохода
        input0 = np.array([[1.0 if is_income else 0.0]], dtype=np.float32)
        # Второй вход - последовательность токенов
        input1 = np.array([sequence], dtype=np.float32)
        
        print(f"Форма input0 (is_income): {input0.shape}")
        print(f"Форма input1 (sequence): {input1.shape}")
        
        interpreter.set_tensor(input_details[0]['index'], input0)
        interpreter.set_tensor(input_details[1]['index'], input1)
        
        interpreter.invoke()
        
        # Получаем результаты
        output_data = interpreter.get_tensor(output_details[0]['index'])
        print("Вариант 1 успешно выполнен!")
        return process_output(output_data[0], category_mapping)
    except Exception as e:
        print(f"Ошибка в варианте 1: {e}")
    
    # Вариант 2: Проверяем форму входных тензоров и адаптируемся
    try:
        print("\nПробуем вариант 2: Адаптивный формат")
        # Определяем, какой вход для чего предназначен по форме
        is_income_tensor_idx = -1
        sequence_tensor_idx = -1
        
        for i, detail in enumerate(input_details):
            shape = detail['shape']
            if len(shape) == 2 and shape[1] == 1:
                is_income_tensor_idx = i
            elif len(shape) == 2 and shape[1] == MAX_SEQUENCE_LENGTH:
                sequence_tensor_idx = i
        
        if is_income_tensor_idx != -1 and sequence_tensor_idx != -1:
            print(f"Определили индексы: is_income={is_income_tensor_idx}, sequence={sequence_tensor_idx}")
            
            # Подготавливаем входные данные в соответствии с определенными индексами
            is_income_input = np.array([[1.0 if is_income else 0.0]], dtype=np.float32)
            sequence_input = np.array([sequence], dtype=np.float32)
            
            print(f"Форма is_income_input: {is_income_input.shape}")
            print(f"Форма sequence_input: {sequence_input.shape}")
            
            interpreter.set_tensor(input_details[is_income_tensor_idx]['index'], is_income_input)
            interpreter.set_tensor(input_details[sequence_tensor_idx]['index'], sequence_input)
            
            interpreter.invoke()
            
            # Получаем результаты
            output_data = interpreter.get_tensor(output_details[0]['index'])
            print("Вариант 2 успешно выполнен!")
            return process_output(output_data[0], category_mapping)
        else:
            print("Не удалось определить индексы входных тензоров по форме")
    except Exception as e:
        print(f"Ошибка в варианте 2: {e}")
    
    # Вариант 3: Пробуем все возможные комбинации входов
    try:
        print("\nПробуем вариант 3: Все возможные комбинации")
        
        # Подготавливаем входные данные
        is_income_input = np.array([[1.0 if is_income else 0.0]], dtype=np.float32)
        sequence_input = np.array([sequence], dtype=np.float32)
        
        # Пробуем обе возможные комбинации
        for first_is_income in [True, False]:
            try:
                print(f"\nПробуем комбинацию: первый вход - {'is_income' if first_is_income else 'sequence'}")
                
                if first_is_income:
                    interpreter.set_tensor(input_details[0]['index'], is_income_input)
                    interpreter.set_tensor(input_details[1]['index'], sequence_input)
                else:
                    interpreter.set_tensor(input_details[0]['index'], sequence_input)
                    interpreter.set_tensor(input_details[1]['index'], is_income_input)
                
                interpreter.invoke()
                
                # Получаем результаты
                output_data = interpreter.get_tensor(output_details[0]['index'])
                print("Комбинация успешно выполнена!")
                return process_output(output_data[0], category_mapping)
            except Exception as e:
                print(f"Ошибка в комбинации: {e}")
    except Exception as e:
        print(f"Ошибка в варианте 3: {e}")
    
    raise Exception("Все варианты форматирования входных данных не удались")

def process_output(predictions, category_mapping):
    """Обрабатывает выходные данные модели"""
    # Сортируем категории по вероятности
    indexed_predictions = [(i, prob) for i, prob in enumerate(predictions)]
    indexed_predictions.sort(key=lambda x: x[1], reverse=True)
    
    # Берем топ-3 категории
    top_k = 3
    top_categories = []
    
    for i in range(min(top_k, len(indexed_predictions))):
        index, probability = indexed_predictions[i]
        
        # Добавляем только если вероятность выше порога
        if probability > 0.05:
            category = category_mapping.get(str(index), "Неизвестно")
            top_categories.append((category, probability))
    
    return top_categories

def main():
    # Загружаем необходимые файлы
    vocab, category_mapping, metadata = load_files()
    print(f"Загружен словарь с {len(vocab)} словами")
    print(f"Загружен маппинг категорий с {len(category_mapping)} категориями")
    print(f"Загружены метаданные модели: точность = {metadata['accuracy']}")
    
    # Загружаем модель
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    
    # Тестовые примеры
    test_examples = [
        ("оплата за интернет", False),
        ("зп", True),
        ("перевод другу", False),
        ("ремонт 2 этап", False),
        ("одолжить", False)
    ]
    
    # Предсказываем категории для тестовых примеров
    for text, is_income in test_examples:
        print(f"\n=== Предсказание для текста: '{text}', доход: {is_income} ===")
        try:
            predictions = predict_category(text, is_income, interpreter, vocab, category_mapping)
            print("Предсказанные категории:")
            for category, probability in predictions:
                print(f"  {category}: {probability * 100:.1f}%")
        except Exception as e:
            print(f"Ошибка при предсказании: {e}")

if __name__ == "__main__":
    main() 