#!/usr/bin/env python
# -*- coding: utf-8 -*-

from utils.config import settings
from bot.bot import start_bot
import os
import sys
import logging
import argparse
from dotenv import load_dotenv

# Добавляем путь к текущей директории, чтобы модули могли найтись
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


logger = logging.getLogger(__name__)

if __name__ == "__main__":
    # Загружаем переменные окружения из .env файла, если он существует
    load_dotenv()

    # Настраиваем логирование
    logging.basicConfig(
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        level=logging.INFO
    )

    # Парсим аргументы командной строки
    parser = argparse.ArgumentParser(
        description='Запуск бота для выдачи лицензий')
    parser.add_argument('--webhook', action='store_true',
                        help='Использовать webhook вместо long polling')
    args = parser.parse_args()

    # Проверяем наличие необходимых настроек
    if not settings.bot_token:
        logger.error(
            "Токен бота не указан. Укажите BOT_TOKEN в переменных окружения.")
        sys.exit(1)

    # Запускаем бота
    logger.info("Запускаем бота для выдачи лицензий...")
    start_bot(use_webhook=args.webhook)
