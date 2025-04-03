#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import logging
from typing import Dict, Any, List, Optional

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, ParseMode
from telegram.ext import CallbackContext

from utils.config import settings
from utils.license_store import LicenseStore
from ..constants import *
from ..services.license_service import license_service
from ..services.export_service import export_licenses_to_csv, export_licenses_to_json

logger = logging.getLogger(__name__)


def admin_command(update: Update, context: CallbackContext) -> None:
    """
    Показывает панель управления лицензиями для администратора
    """
    user = update.effective_user
    if not settings.is_admin(user.id):
        update.message.reply_text("⛔ У вас нет доступа к этой команде.")
        return

    keyboard = [
        [InlineKeyboardButton("📋 Список лицензий",
                              callback_data=ADMIN_MENU_LICENSES)],
        [InlineKeyboardButton(
            "📊 Статистика", callback_data=ADMIN_MENU_STATISTICS)],
        [InlineKeyboardButton("🔍 Поиск лицензий",
                              callback_data=ADMIN_MENU_EXPORT)]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    update.message.reply_text(
        "🔐 *Панель администратора*\n\n"
        "Выберите действие из меню ниже:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


def handle_admin_menu(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает нажатия кнопок в меню администратора
    """
    query = update.callback_query
    query.answer()

    user = update.effective_user
    if not settings.is_admin(user.id):
        query.edit_message_text("⛔ У вас нет доступа к этой функции.")
        return

    action = query.data

    if action == ADMIN_MENU_LICENSES:
        show_licenses_list(update, context)
    elif action == ADMIN_MENU_STATISTICS:
        show_license_stats(update, context)
    elif action == ADMIN_MENU_EXPORT:
        ask_export_format(update, context)
    elif action == ADMIN_MENU_BACK:
        # Возвращаемся к главному меню администратора
        keyboard = [
            [InlineKeyboardButton("📋 Список лицензий",
                                  callback_data=ADMIN_MENU_LICENSES)],
            [InlineKeyboardButton(
                "📊 Статистика", callback_data=ADMIN_MENU_STATISTICS)],
            [InlineKeyboardButton("🔍 Поиск лицензий",
                                  callback_data=ADMIN_MENU_EXPORT)]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)

        query.edit_message_text(
            "🔐 *Панель администратора*\n\n"
            "Выберите действие из меню ниже:",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )


def show_licenses_list(update: Update, context: CallbackContext) -> None:
    """
    Отображает список выданных лицензий
    """
    query = update.callback_query
    license_store = LicenseStore(settings.license_db_path)

    # Получаем все лицензии из хранилища
    all_licenses = license_store.get_all_licenses()

    if not all_licenses:
        keyboard = [[InlineKeyboardButton(
            "« Назад", callback_data=ADMIN_MENU_BACK)]]
        reply_markup = InlineKeyboardMarkup(keyboard)

        query.edit_message_text(
            "📋 *Список лицензий*\n\n"
            "В настоящее время нет выданных лицензий.",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )
        return

    # Ограничиваем показ максимум 10 последними лицензиями
    recent_licenses = sorted(
        all_licenses, key=lambda x: x.created_at, reverse=True)[:10]

    message = "📋 *Последние выданные лицензии:*\n\n"
    for idx, license_obj in enumerate(recent_licenses, 1):
        status = "✅ Активна" if not license_obj.is_expired() else "❌ Истекла"
        expiry = license_service.get_expiration_text(license_obj)

        message += (
            f"{idx}. *ID*: `{license_obj.id[:8]}...`\n"
            f"   *Приложение*: {license_obj.app_id}\n"
            f"   *Тип*: {license_obj.type}\n"
            f"   *Срок*: {expiry}\n"
            f"   *Статус*: {status}\n\n"
        )

    # Добавляем информацию о количестве лицензий, если их больше 10
    if len(all_licenses) > 10:
        message += f"_Показаны 10 из {len(all_licenses)} лицензий_\n\n"

    keyboard = [
        [InlineKeyboardButton("🔍 Поиск", callback_data=ADMIN_MENU_EXPORT)],
        [InlineKeyboardButton("« Назад", callback_data=ADMIN_MENU_BACK)]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    query.edit_message_text(
        message,
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


def show_license_stats(update: Update, context: CallbackContext) -> None:
    """
    Отображает статистику по выданным лицензиям
    """
    query = update.callback_query
    license_store = LicenseStore(settings.license_db_path)

    # Получаем все лицензии
    all_licenses = license_store.get_all_licenses()

    if not all_licenses:
        keyboard = [[InlineKeyboardButton(
            "« Назад", callback_data=ADMIN_MENU_BACK)]]
        reply_markup = InlineKeyboardMarkup(keyboard)

        query.edit_message_text(
            "📊 *Статистика лицензий*\n\n"
            "В настоящее время нет выданных лицензий.",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )
        return

    # Подсчет статистики
    total_count = len(all_licenses)
    active_count = sum(1 for lic in all_licenses if not lic.is_expired())
    expired_count = total_count - active_count

    # Распределение по типам
    types_count = {}
    for lic in all_licenses:
        types_count[lic.type] = types_count.get(lic.type, 0) + 1

    # Распределение по приложениям
    apps_count = {}
    for lic in all_licenses:
        apps_count[lic.app_id] = apps_count.get(lic.app_id, 0) + 1

    # Форматируем сообщение
    message = "📊 *Статистика лицензий*\n\n"

    message += f"*Общее количество*: {total_count}\n"
    message += f"*Активных*: {active_count}\n"
    message += f"*Истекших*: {expired_count}\n\n"

    if types_count:
        message += "*По типам:*\n"
        for type_name, count in types_count.items():
            message += f"- {type_name}: {count}\n"
        message += "\n"

    if apps_count:
        message += "*По приложениям:*\n"
        for app_id, count in apps_count.items():
            message += f"- {app_id}: {count}\n"

    keyboard = [[InlineKeyboardButton(
        "« Назад", callback_data=ADMIN_MENU_BACK)]]
    reply_markup = InlineKeyboardMarkup(keyboard)

    query.edit_message_text(
        message,
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


def stats_command(update: Update, context: CallbackContext) -> None:
    """
    Показывает статистику по лицензиям (только для администраторов)
    """
    user_id = update.effective_user.id

    if not settings.is_admin(user_id):
        update.message.reply_text("❌ У вас нет доступа к этой команде.")
        return

    license_store = LicenseStore(settings.license_db_path)
    # Собираем статистику
    all_licenses = license_store.get_all_licenses()
    total_count = len(all_licenses)
    active_count = sum(
        1 for license in all_licenses if not license.is_expired())

    app_stats = {}
    for license in all_licenses:
        app_id = license.app_id
        if app_id not in app_stats:
            app_stats[app_id] = {'total': 0, 'active': 0, 'by_type': {}}

        app_stats[app_id]['total'] += 1
        if not license.is_expired():
            app_stats[app_id]['active'] += 1

        license_type = license.type
        if license_type not in app_stats[app_id]['by_type']:
            app_stats[app_id]['by_type'][license_type] = 0
        app_stats[app_id]['by_type'][license_type] += 1

    # Формируем сообщение
    message = (
        "📊 *Статистика по лицензиям*\n\n"
        f"*Всего лицензий:* {total_count}\n"
        f"*Активных лицензий:* {active_count}\n\n"
    )

    if app_stats:
        message += "*По приложениям:*\n"
        for app_id, stats in app_stats.items():
            message += f"\n*{app_id}*\n"
            message += f"Всего: {stats['total']}, Активных: {stats['active']}\n"
            message += "По типам: "
            types_stats = [f"{t}: {c}" for t, c in stats['by_type'].items()]
            message += ", ".join(types_stats) + "\n"

    update.message.reply_text(message, parse_mode='Markdown')


def revoke_command(update: Update, context: CallbackContext) -> None:
    """
    Отзывает лицензию по идентификатору (только для администраторов)
    """
    user_id = update.effective_user.id

    if not settings.is_admin(user_id):
        update.message.reply_text("❌ У вас нет доступа к этой команде.")
        return

    args = context.args
    if not args or not args[0]:
        update.message.reply_text(
            "❓ Пожалуйста, укажите идентификатор лицензии для отзыва.\n"
            "Пример: `/revoke 550e8400-e29b-41d4-a716-446655440000`",
            parse_mode='Markdown'
        )
        return

    license_store = LicenseStore(settings.license_db_path)
    license_id = args[0]
    result = license_store.revoke_license(license_id)

    if result:
        update.message.reply_text(
            f"✅ Лицензия с ID {license_id} успешно отозвана."
        )
    else:
        update.message.reply_text(
            f"❌ Лицензия с ID {license_id} не найдена."
        )


def ask_export_format(update: Update, context: CallbackContext) -> None:
    """
    Запрашивает формат экспорта лицензий
    """
    keyboard = [
        [InlineKeyboardButton("CSV - Все лицензии",
                              callback_data=f"{EXPORT_CSV}_all")],
        [InlineKeyboardButton("CSV - Только активные",
                              callback_data=f"{EXPORT_CSV}_active")],
        [InlineKeyboardButton("JSON - Все лицензии",
                              callback_data=f"{EXPORT_JSON}_all")],
        [InlineKeyboardButton("JSON - Только активные",
                              callback_data=f"{EXPORT_JSON}_active")],
        [InlineKeyboardButton("🧹 Очистить истекшие",
                              callback_data=CLEANUP_EXPIRED)],
        [InlineKeyboardButton("« Назад", callback_data=ADMIN_MENU_BACK)]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    if update.callback_query:
        update.callback_query.answer()
        update.callback_query.edit_message_text(
            "📥 *Экспорт и управление лицензиями*\n\n"
            "Выберите действие:",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )
    else:
        update.message.reply_text(
            "📥 *Экспорт и управление лицензиями*\n\n"
            "Выберите действие:",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )


def handle_export_format(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает выбор формата экспорта и выполняет экспорт
    """
    query = update.callback_query
    query.answer()

    user = update.effective_user
    if not settings.is_admin(user.id):
        query.edit_message_text("⛔ У вас нет доступа к этой функции.")
        return

    # Получаем данные из callback
    callback_data = query.data
    export_format, export_type = callback_data.split(
        '_')[0], callback_data.split('_')[1]

    license_store = LicenseStore(settings.license_db_path)
    # Получаем лицензии
    if export_type == 'all':
        licenses = license_store.get_all_licenses()
    else:  # active
        licenses = [lic for lic in license_store.get_all_licenses()
                    if not lic.is_expired()]

    if not licenses:
        query.edit_message_text(
            "❌ Нет лицензий для экспорта.",
            parse_mode='Markdown'
        )
        return

    try:
        if export_format == EXPORT_CSV:
            file_path, file_name = export_licenses_to_csv(licenses)
        else:  # JSON
            file_path, file_name = export_licenses_to_json(licenses)

        # Отправляем файл пользователю
        with open(file_path, 'rb') as f:
            context.bot.send_document(
                chat_id=user.id,
                document=f,
                filename=file_name,
                caption=f"📤 Экспортировано {len(licenses)} лицензий"
            )

        # Удаляем временный файл
        os.unlink(file_path)

        # Возвращаемся к меню администратора
        keyboard = [
            [InlineKeyboardButton(
                "« Назад к меню", callback_data=ADMIN_MENU_BACK)]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)

        query.edit_message_text(
            f"✅ Лицензии успешно экспортированы в формате {export_format.upper()}.",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )

    except Exception as e:
        logger.error(f"Error exporting licenses: {e}")
        query.edit_message_text(
            f"❌ Ошибка при экспорте лицензий: {str(e)}",
            parse_mode='Markdown'
        )


def cleanup_expired_licenses(update: Update, context: CallbackContext) -> None:
    """
    Удаляет истекшие лицензии из хранилища
    """
    query = update.callback_query
    query.answer()

    user = update.effective_user
    if not settings.is_admin(user.id):
        query.edit_message_text("⛔ У вас нет доступа к этой функции.")
        return

    license_store = LicenseStore(settings.license_db_path)
    # Получаем все лицензии
    all_licenses = license_store.get_all_licenses()

    # Находим истекшие лицензии
    expired_licenses = [lic for lic in all_licenses if lic.is_expired()]

    if not expired_licenses:
        query.edit_message_text(
            "🧹 Не найдено истекших лицензий для удаления.",
            parse_mode='Markdown'
        )
        return

    # Удаляем истекшие лицензии
    deleted_count = 0
    for license_obj in expired_licenses:
        if license_store.delete_license(license_obj.id):
            deleted_count += 1

    # Формируем ответ
    keyboard = [[InlineKeyboardButton(
        "« Назад", callback_data=ADMIN_MENU_BACK)]]
    reply_markup = InlineKeyboardMarkup(keyboard)

    query.edit_message_text(
        f"✅ Успешно удалено {deleted_count} из {len(expired_licenses)} истекших лицензий.",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


def revoke_license_callback(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает нажатие кнопки для отзыва лицензии
    """
    query = update.callback_query
    query.answer()

    user = update.effective_user
    if not settings.is_admin(user.id):
        query.edit_message_text("⛔ У вас нет доступа к этой функции.")
        return

    # Извлекаем ID лицензии из данных callback
    license_id = query.data.replace("revoke_", "")

    license_store = LicenseStore(settings.license_db_path)
    # Пытаемся отозвать лицензию
    if license_store.revoke_license(license_id):
        query.edit_message_text(
            f"✅ Лицензия с ID `{license_id}` была успешно отозвана.",
            parse_mode='Markdown'
        )
    else:
        query.edit_message_text(
            f"❌ Не удалось отозвать лицензию с ID `{license_id}`. "
            f"Возможно, она не существует или уже отозвана.",
            parse_mode='Markdown'
        )
