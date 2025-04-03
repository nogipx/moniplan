#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, ParseMode
from telegram.ext import CallbackContext, ConversationHandler

from utils.config import settings
from utils.license_store import LicenseStore
from ..constants import *
from ..services.license_service import license_service

logger = logging.getLogger(__name__)


def search_command(update: Update, context: CallbackContext) -> int:
    """
    Запускает процесс поиска лицензий (только для администраторов)
    """
    user = update.effective_user
    if not settings.is_admin(user.id):
        update.message.reply_text("⛔ У вас нет доступа к этой команде.")
        return ConversationHandler.END

    return ask_search_param(update, context)


def ask_search_param(update: Update, context: CallbackContext) -> int:
    """
    Запрашивает параметр для поиска лицензий
    """
    keyboard = [
        [InlineKeyboardButton("🔍 По ID", callback_data=SEARCH_BY_ID)],
        [InlineKeyboardButton("🔍 По приложению", callback_data=SEARCH_BY_APP)],
        [InlineKeyboardButton(
            "🔍 По устройству", callback_data=SEARCH_BY_DEVICE)],
        [InlineKeyboardButton("🔍 По типу", callback_data=SEARCH_BY_TYPE)],
        [InlineKeyboardButton("« Отмена", callback_data="cancel")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    if update.callback_query:
        update.callback_query.answer()
        update.callback_query.edit_message_text(
            "🔍 *Поиск лицензий*\n\n"
            "Выберите критерий поиска:",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )
    else:
        update.message.reply_text(
            "🔍 *Поиск лицензий*\n\n"
            "Выберите критерий поиска:",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )

    return AWAITING_SEARCH_PARAM


def handle_search_param_selection(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает выбор параметра поиска и запрашивает поисковый запрос
    """
    query = update.callback_query
    query.answer()

    search_param = query.data

    if search_param == "cancel":
        query.edit_message_text("🔍 Поиск отменен.")
        return ConversationHandler.END

    # Сохраняем выбранный параметр поиска
    context.user_data['search_param'] = search_param

    param_name = {
        SEARCH_BY_ID: "ID лицензии",
        SEARCH_BY_APP: "ID приложения",
        SEARCH_BY_DEVICE: "хеш устройства",
        SEARCH_BY_TYPE: "тип лицензии"
    }.get(search_param, "значение")

    query.edit_message_text(
        f"🔍 Введите {param_name} для поиска:"
    )

    return AWAITING_SEARCH_TERM


def handle_search_term(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает введенный поисковой запрос и выполняет поиск лицензий
    """
    search_term = update.message.text.strip()
    search_param = context.user_data.get('search_param', '')

    if not search_term:
        update.message.reply_text(
            "❌ Поисковой запрос не может быть пустым.\n"
            "Введите значение или /cancel для отмены."
        )
        return AWAITING_SEARCH_TERM

    license_store = LicenseStore(settings.license_db_path)
    # Выполняем поиск в зависимости от выбранного параметра
    if search_param == SEARCH_BY_ID:
        licenses = license_store.get_license_by_id(search_term)
        if licenses:
            licenses = [licenses]  # Преобразуем в список для единообразия
        else:
            licenses = []
    elif search_param == SEARCH_BY_APP:
        licenses = license_store.get_licenses_by_app_id(search_term)
    elif search_param == SEARCH_BY_DEVICE:
        licenses = license_store.get_licenses_by_device_hash(search_term)
    elif search_param == SEARCH_BY_TYPE:
        licenses = [lic for lic in license_store.get_all_licenses()
                    if lic.type.lower() == search_term.lower()]
    else:
        update.message.reply_text("❌ Неизвестный параметр поиска.")
        return ConversationHandler.END

    # Формируем результаты поиска
    if not licenses:
        update.message.reply_text(
            "🔍 По вашему запросу не найдено лицензий."
        )
    else:
        message = f"🔍 *Найдено лицензий: {len(licenses)}*\n\n"

        for idx, license_obj in enumerate(licenses, 1):
            status = "✅ Активна" if not license_obj.is_expired() else "❌ Истекла"
            expiry = license_service.get_expiration_text(license_obj)

            message += (
                f"{idx}. *ID*: `{license_obj.id}`\n"
                f"   *Приложение*: {license_obj.app_id}\n"
                f"   *Тип*: {license_obj.type}\n"
                f"   *Срок*: {expiry}\n"
                f"   *Статус*: {status}\n\n"
            )

        # Добавляем кнопку для отзыва лицензии, если найдена только одна
        if len(licenses) == 1:
            keyboard = [
                [InlineKeyboardButton("⛔ Отозвать эту лицензию",
                                      callback_data=f"revoke_{licenses[0].id}")]
            ]
            reply_markup = InlineKeyboardMarkup(keyboard)

            update.message.reply_text(
                message,
                reply_markup=reply_markup,
                parse_mode='Markdown'
            )
        else:
            update.message.reply_text(
                message,
                parse_mode='Markdown'
            )

    return ConversationHandler.END
