#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
from telegram.ext import (
    Updater, CommandHandler, MessageHandler, CallbackQueryHandler,
    Filters, ConversationHandler, CallbackContext
)

from utils.config import settings
from .constants import *
from .handlers.common import (
    start, help_command, cancel_conversation, handle_text_buttons, error_handler
)
from .handlers.license import (
    license_command, handle_license_request_file, handle_license_type_selection,
    handle_license_duration_selection, process_license_confirmation
)
from .handlers.admin import (
    admin_command, handle_admin_menu, stats_command,
    revoke_command, revoke_license_callback, cleanup_expired_licenses,
    ask_export_format, handle_export_format
)
from .handlers.search import (
    search_command, ask_search_param, handle_search_param_selection, handle_search_term
)

logger = logging.getLogger(__name__)


def setup_bot(telegram_token: str):
    """
    Настройка и запуск бота
    """
    # Создаем Updater и получаем диспетчер
    updater = Updater(token=telegram_token)
    dispatcher = updater.dispatcher

    # Настраиваем логирование
    logging.basicConfig(
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        level=logging.INFO
    )

    # Обработчик для процесса создания лицензии
    license_conv_handler = ConversationHandler(
        entry_points=[
            CommandHandler('license', license_command),
            MessageHandler(Filters.regex(
                '^(Получить лицензию)$'), license_command)
        ],
        states={
            AWAITING_REQUEST_FILE: [
                MessageHandler(Filters.document, handle_license_request_file),
                CommandHandler('cancel', cancel_conversation)
            ],
            AWAITING_CONFIRMATION: [
                CallbackQueryHandler(
                    process_license_confirmation, pattern='^(replace_license|cancel)$')
            ],
            AWAITING_LICENSE_TYPE: [
                CallbackQueryHandler(
                    handle_license_type_selection, pattern='^(type_|cancel)')
            ],
            AWAITING_LICENSE_DURATION: [
                CallbackQueryHandler(
                    handle_license_duration_selection, pattern='^(duration_|cancel)')
            ]
        },
        fallbacks=[
            CommandHandler('cancel', cancel_conversation),
            MessageHandler(Filters.regex('^Отмена$'), cancel_conversation)
        ],
        name="license_conversation",
        persistent=False
    )

    # Обработчик для поиска лицензий
    search_conv_handler = ConversationHandler(
        entry_points=[
            CommandHandler('search', search_command),
            MessageHandler(Filters.regex('^(Поиск лицензий)$'), search_command)
        ],
        states={
            AWAITING_SEARCH_PARAM: [
                CallbackQueryHandler(
                    handle_search_param_selection, pattern='^(search_|cancel)')
            ],
            AWAITING_SEARCH_TERM: [
                MessageHandler(Filters.text & ~Filters.command,
                               handle_search_term),
                CommandHandler('cancel', cancel_conversation)
            ]
        },
        fallbacks=[
            CommandHandler('cancel', cancel_conversation),
            MessageHandler(Filters.regex('^Отмена$'), cancel_conversation)
        ],
        name="search_conversation",
        persistent=False
    )

    # Основные команды
    dispatcher.add_handler(CommandHandler("start", start))
    dispatcher.add_handler(CommandHandler("help", help_command))

    # Обработчики лицензий
    dispatcher.add_handler(license_conv_handler)

    # Админские команды
    dispatcher.add_handler(CommandHandler("admin", admin_command))
    dispatcher.add_handler(CommandHandler("stats", stats_command))
    dispatcher.add_handler(CommandHandler("revoke", revoke_command))
    dispatcher.add_handler(CallbackQueryHandler(
        revoke_license_callback, pattern='^revoke_license_'))
    dispatcher.add_handler(CallbackQueryHandler(
        handle_admin_menu, pattern='^admin_menu_'))
    dispatcher.add_handler(CallbackQueryHandler(
        ask_export_format, pattern='^export_licenses$'))
    dispatcher.add_handler(CallbackQueryHandler(
        handle_export_format, pattern='^export_(csv|json)$'))
    dispatcher.add_handler(CallbackQueryHandler(
        cleanup_expired_licenses, pattern='^cleanup_expired$'))

    # Поиск лицензий
    dispatcher.add_handler(search_conv_handler)

    # Обработчик текстовых кнопок
    dispatcher.add_handler(MessageHandler(
        Filters.text & ~Filters.command, handle_text_buttons))

    # Обработчик ошибок
    dispatcher.add_error_handler(error_handler)

    return updater


def run_bot(telegram_token: str, use_webhook: bool = False, webhook_url: str = None,
            webhook_port: int = None, webhook_path: str = None):
    """
    Запуск бота с использованием long polling или webhook
    """
    updater = setup_bot(telegram_token)

    if use_webhook:
        # Настройка webhook
        updater.start_webhook(
            listen='0.0.0.0',
            port=webhook_port,
            url_path=webhook_path,
            webhook_url=webhook_url
        )
        logger.info(f"Bot started using webhook on {webhook_url}")
    else:
        # Используем long polling
        updater.start_polling()
        logger.info("Bot started using long polling")

    # Запускаем бота до получения сигнала остановки (Ctrl+C)
    updater.idle()
