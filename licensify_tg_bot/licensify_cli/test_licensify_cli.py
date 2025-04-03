#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import logging
import argparse
from datetime import datetime, timedelta

from licensify_cli import LicensifyCLI
from utils.config import settings

# Настраиваем логирование
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('licensify_test.log')
    ]
)

logger = logging.getLogger('licensify_test')


def parse_args():
    parser = argparse.ArgumentParser(
        description='Тестирование интеграции с Licensify CLI')

    parser.add_argument('--cli-path', help='Путь к Licensify CLI',
                        default=settings.licensify_path)
    parser.add_argument(
        '--keys-dir', help='Директория для хранения ключей', default='./keys')
    parser.add_argument(
        '--app-id', help='Идентификатор приложения', default='com.example.testapp')
    parser.add_argument(
        '--device-id', help='Идентификатор устройства', default=None)
    parser.add_argument(
        '--license-type', help='Тип лицензии (trial, standard, pro)', default='standard')
    parser.add_argument('--expiration-days', type=int,
                        help='Срок действия лицензии в днях', default=30)
    parser.add_argument('--features', help='Функции лицензии в формате key1=value1,key2=value2',
                        default='maxUsers=10,premium=true')
    parser.add_argument(
        '--output-dir', help='Директория для выходных файлов', default='./test_output')

    return parser.parse_args()


def main():
    args = parse_args()

    # Создаем выходную директорию, если нужно
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    # Создаем директорию для ключей, если нужно
    if not os.path.exists(args.keys_dir):
        os.makedirs(args.keys_dir)

    # Определяем пути к ключам
    private_key_path = os.path.join(args.keys_dir, 'app.private.pem')
    public_key_path = os.path.join(args.keys_dir, 'app.public.pem')

    # Инициализируем класс LicensifyCLI
    logger.info("Инициализация LicensifyCLI...")
    try:
        cli = LicensifyCLI(
            cli_path=args.cli_path,
            private_key_path=private_key_path if os.path.exists(
                private_key_path) else None,
            public_key_path=public_key_path if os.path.exists(
                public_key_path) else None
        )

        # Проверяем версию CLI
        version = cli.get_version()
        logger.info(f"Версия Licensify CLI: {version}")

        # Шаг 1: Генерируем ключи, если они не существуют
        if not os.path.exists(private_key_path) or not os.path.exists(public_key_path):
            logger.info("Ключи не найдены, генерируем новые...")
            private_key_path, public_key_path = cli.generate_key_pair(
                output_dir=args.keys_dir,
                name="app"
            )
            logger.info(
                f"Сгенерированы ключи: {private_key_path}, {public_key_path}")

            # Обновляем пути к ключам в объекте cli
            cli.private_key_path = private_key_path
            cli.public_key_path = public_key_path
        else:
            logger.info(
                f"Используем существующие ключи: {private_key_path}, {public_key_path}")

        # Шаг 2: Создаем запрос на лицензию
        logger.info(f"Создаем запрос на лицензию для {args.app_id}...")
        request_output_path = os.path.join(
            args.output_dir, 'license_request.mlr')
        request_data, request_path = cli.create_license_request(
            app_id=args.app_id,
            public_key=public_key_path,
            device_id=args.device_id,
            output_path=request_output_path
        )
        logger.info(
            f"Запрос создан: {request_path} ({len(request_data)} байт)")

        # Шаг 3: Расшифровываем запрос
        logger.info("Расшифровываем запрос...")
        request_info = cli.decrypt_license_request(
            request_data=request_path,
            private_key=private_key_path
        )
        logger.info(f"Информация о запросе: {request_info}")

        # Шаг 4: Создаем лицензию на основе запроса
        logger.info("Создаем лицензию на основе запроса...")
        expiration_date = datetime.now() + timedelta(days=args.expiration_days)

        # Парсим features
        features_dict = {}
        if args.features:
            for feature in args.features.split(','):
                if '=' in feature:
                    key, value = feature.split('=', 1)
                    features_dict[key] = value

        # Добавляем метаданные
        metadata = {
            'createdAt': datetime.now().isoformat(),
            'test': 'true'
        }

        license_output_path = os.path.join(
            args.output_dir, 'license.licensify')
        license_data, license_path = cli.respond_to_request(
            request_data=request_path,
            expiration_date=expiration_date,
            license_type=args.license_type,
            features=features_dict,
            metadata=metadata,
            output_path=license_output_path
        )
        logger.info(f"Лицензия создана: {license_path}")
        logger.info(f"Данные лицензии: {license_data}")

        # Шаг 5: Проверяем лицензию
        logger.info("Проверяем лицензию...")
        is_valid, verification_data = cli.verify_license(
            license_data=license_path,
            public_key=public_key_path
        )
        logger.info(f"Результат проверки: {is_valid}")
        logger.info(f"Данные проверки: {verification_data}")

        # Также проверим создание лицензии напрямую (без запроса)
        logger.info("Создаем лицензию напрямую...")
        direct_license_path = os.path.join(
            args.output_dir, 'direct_license.licensify')
        direct_license_data, direct_license_path = cli.generate_license(
            app_id=args.app_id,
            expiration_date=expiration_date,
            license_type=args.license_type,
            features=features_dict,
            metadata={'direct': 'true', **metadata},
            output_path=direct_license_path
        )
        logger.info(f"Прямая лицензия создана: {direct_license_path}")

        # Проверяем прямую лицензию
        is_direct_valid, direct_verification = cli.verify_license(
            license_data=direct_license_path,
            public_key=public_key_path
        )
        logger.info(f"Результат проверки прямой лицензии: {is_direct_valid}")
        logger.info(f"Данные проверки прямой лицензии: {direct_verification}")

        logger.info("Тестирование завершено успешно!")

    except Exception as e:
        logger.error(f"Ошибка при тестировании: {e}", exc_info=True)
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
