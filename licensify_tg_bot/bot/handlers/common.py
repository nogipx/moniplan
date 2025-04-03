#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import CallbackContext, ConversationHandler

from utils.config import settings
from ..constants import *

logger = logging.getLogger(__name__)


def start(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает команду /start
    """
    user = update.effective_user
    keyboard = []

    # Кнопка для запроса лицензии
    keyboard.append([InlineKeyboardButton(
        "Получить лицензию", callback_data="license")])

    # Кнопка помощи
    keyboard.append([InlineKeyboardButton("Помощь", callback_data="help")])

    # Админские кнопки
    if settings.is_admin(user.id):
        keyboard.extend([
            [InlineKeyboardButton("Админ-панель", callback_data="admin")],
            [InlineKeyboardButton("Статистика", callback_data="stats")],
            [InlineKeyboardButton("Отозвать лицензию",
                                  callback_data="revoke")],
            [InlineKeyboardButton("Поиск лицензий", callback_data="search")],
        ])

    reply_markup = InlineKeyboardMarkup(keyboard)

    update.message.reply_text(
        f"👋 Привет, {user.first_name}!\n\n"
        f"Я бот для выдачи лицензий приложения. Чтобы получить лицензию, "
        f"отправьте мне файл запроса лицензии (.mlr).\n\n"
        f"Используйте команду /license для начала процесса.",
        reply_markup=reply_markup
    )


def help_command(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает команду /help
    """
    user = update.effective_user
    keyboard = []

    # Кнопка для запроса лицензии
    keyboard.append([InlineKeyboardButton(
        "Получить лицензию", callback_data="license")])

    # Админские кнопки
    if settings.is_admin(user.id):
        keyboard.extend([
            [InlineKeyboardButton("Админ-панель", callback_data="admin")],
            [InlineKeyboardButton("Статистика", callback_data="stats")],
            [InlineKeyboardButton("Отозвать лицензию",
                                  callback_data="revoke")],
            [InlineKeyboardButton("Поиск лицензий", callback_data="search")],
        ])

    reply_markup = InlineKeyboardMarkup(keyboard)

    update.message.reply_text(
        "🔍 *Как получить лицензию:*\n\n"
        "1. В приложении откройте меню \"Запросить лицензию\".\n"
        "2. Сохраните файл запроса (.mlr).\n"
        "3. Отправьте мне этот файл или используйте команду /license.\n"
        "4. Выберите тип и срок действия лицензии.\n"
        "5. Получите файл лицензии и импортируйте его в приложение.\n\n"
        "Если у вас возникли проблемы, обратитесь к администратору.",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


def cancel_conversation(update: Update, context: CallbackContext) -> int:
    """
    Отменяет текущий разговор и возвращает в начальное состояние
    """
    # Очищаем данные контекста
    if 'license_request_data' in context.user_data:
        context.user_data.pop('license_request_data')

    # Отправляем сообщение в зависимости от типа обновления
    if update.callback_query:
        update.callback_query.answer()
        update.callback_query.edit_message_text("❌ Операция отменена.")
    else:
        update.message.reply_text("❌ Операция отменена.")

    return ConversationHandler.END


def handle_text_buttons(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает текстовые кнопки
    """
    text = update.message.text

    if text == "Получить лицензию":
        from .license import license_command
        return license_command(update, context)
    elif text == "Помощь":
        return help_command(update, context)
    elif text == "Поиск лицензий":
        from .search import search_command
        return search_command(update, context)
    else:
        update.message.reply_text(
            "🤔 Не уверен, что вы имеете в виду. Используйте команду /help для получения справки."
        )


def error_handler(update: object, context: CallbackContext) -> None:
    """
    Логирует ошибки, вызванные обновлениями
    """
    logger.error(f"Update {update} caused error {context.error}")
