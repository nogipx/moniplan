#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import logging
import json
import tempfile
import csv
from datetime import datetime, timedelta, timezone
from typing import Dict, Any, List, Optional, Tuple
from io import StringIO
from dataclasses import asdict

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, ParseMode, ReplyKeyboardMarkup
from telegram.ext import (
    Updater, CommandHandler, CallbackContext, MessageHandler,
    Filters, CallbackQueryHandler, ConversationHandler
)

from utils.config import settings
from licensify_cli.licensify_cli import LicensifyCLI
from utils.license_store import LicenseStore
from utils.models import License, LicenseRequest, LicenseMetadata, LicenseFeatures
from .setup import run_bot

# Уровни разговора для ConversationHandler
(AWAITING_REQUEST_FILE, AWAITING_CONFIRMATION,
 AWAITING_LICENSE_TYPE, AWAITING_LICENSE_DURATION,
 AWAITING_SEARCH_PARAM, AWAITING_SEARCH_TERM,
 AWAITING_EXPORT_FORMAT) = range(7)

# Настройка логирования
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=getattr(logging, settings.log_level)
)
logger = logging.getLogger(__name__)

# Инициализация CLI клиента для работы с лицензиями
licensify_cli = LicensifyCLI(
    cli_path=settings.licensify_path,
    private_key_path=settings.private_key_path,
    public_key_path=settings.public_key_path
)

# Инициализация хранилища лицензий
license_store = LicenseStore(settings.license_db_path)

# Временное хранилище для обрабатываемых запросов
active_requests = {}

# Константы для меню администратора
ADMIN_MENU = "admin_menu"
ADMIN_MENU_LICENSES = "admin_menu_licenses"
ADMIN_MENU_STATISTICS = "admin_menu_statistics"
ADMIN_MENU_EXPORT = "admin_menu_export"
ADMIN_MENU_BACK = "admin_menu_back"
SEARCH_BY_APP = "search_by_app"
SEARCH_BY_DEVICE = "search_by_device"
SEARCH_BY_TYPE = "search_by_type"
SEARCH_BY_ID = "search_by_id"
EXPORT_CSV = "export_csv"
EXPORT_JSON = "export_json"
CLEANUP_EXPIRED = "cleanup_expired"


def start(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает команду /start и показывает приветственное сообщение с клавиатурой
    """
    user = update.effective_user
    message = (
        f"👋 Привет, {user.first_name}!\n\n"
        "Я бот для выдачи лицензий. "
        "Отправь мне файл запроса лицензии (.mlr), "
        "и я сгенерирую лицензионный файл.\n\n"
        "Используй кнопки ниже или следующие команды:\n"
        "/start - Начать сначала\n"
        "/help - Показать помощь\n"
        "/license - Начать процесс выдачи лицензии\n"
    )

    # Создаем клавиатуру с кнопками
    keyboard = [
        ["📄 Получить лицензию", "ℹ️ Помощь"],
    ]

    # Для администратора добавляем дополнительные кнопки
    if settings.is_admin(user.id):
        message += (
            "\nКоманды администратора:\n"
            "/admin - Панель управления лицензиями\n"
            "/stats - Показать статистику по лицензиям\n"
            "/revoke - Отозвать лицензию\n"
            "/search - Поиск лицензий\n"
        )

        # Дополнительный ряд кнопок для админа
        keyboard.append(["🔐 Админпанель", "📊 Статистика"])
        keyboard.append(["🔍 Поиск лицензий", "❌ Отозвать лицензию"])

    reply_markup = ReplyKeyboardMarkup(keyboard, resize_keyboard=True)
    update.message.reply_text(message, reply_markup=reply_markup)


def help_command(update: Update, context: CallbackContext) -> None:
    """
    Показывает справочную информацию и клавиатуру с кнопками
    """
    user = update.effective_user

    # Создаем клавиатуру с кнопками (как в функции start)
    keyboard = [
        ["📄 Получить лицензию", "ℹ️ Помощь"],
    ]

    # Для администратора добавляем дополнительные кнопки
    if settings.is_admin(user.id):
        # Дополнительный ряд кнопок для админа
        keyboard.append(["🔐 Админпанель", "📊 Статистика"])
        keyboard.append(["🔍 Поиск лицензий", "❌ Отозвать лицензию"])

    reply_markup = ReplyKeyboardMarkup(keyboard, resize_keyboard=True)

    update.message.reply_text(
        "🔑 *Как получить лицензию:*\n\n"
        "1. Откройте приложение\n"
        "2. Перейдите в раздел 'Лицензия' (или нажмите кнопку 'Активировать')\n"
        "3. Нажмите 'Запросить лицензию'\n"
        "4. Отправьте полученный файл запроса (.mlr) мне\n"
        "5. После обработки я отправлю вам лицензионный файл\n"
        "6. Импортируйте файл лицензии в приложение\n\n"
        "Для начала процесса нажмите кнопку «📄 Получить лицензию» или отправьте команду /license",
        parse_mode='Markdown',
        reply_markup=reply_markup
    )


def license_command(update: Update, context: CallbackContext) -> int:
    """
    Начало процесса выдачи лицензии
    """
    update.message.reply_text(
        "📤 Отправьте мне файл запроса лицензии (.mlr)\n\n"
        "Файл запроса должен быть создан в приложении через меню 'Запросить лицензию'"
    )
    return AWAITING_REQUEST_FILE


def handle_license_request_file(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает полученный файл запроса лицензии
    """
    user = update.effective_user
    file = update.message.document

    # Проверяем расширение файла
    if not file.file_name.endswith('.mlr'):
        update.message.reply_text(
            "❌ Некорректный формат файла. Пожалуйста, отправьте файл запроса с расширением .mlr"
        )
        return AWAITING_REQUEST_FILE

    # Загружаем файл
    file_id = file.file_id
    new_file = context.bot.get_file(file_id)

    # Создаем временный файл для сохранения
    with tempfile.NamedTemporaryFile(delete=False, suffix='.mlr') as temp_file:
        new_file.download(custom_path=temp_file.name)
        temp_file_path = temp_file.name

    try:
        # Читаем зашифрованные данные
        with open(temp_file_path, 'rb') as f:
            encrypted_data = f.read()

        # Расшифровываем запрос лицензии
        license_request = licensify_cli.decrypt_license_request(encrypted_data)

        # Проверяем срок действия запроса
        if license_request.is_expired():
            update.message.reply_text(
                "❌ Срок действия запроса истек. Пожалуйста, создайте новый запрос в приложении."
            )
            os.unlink(temp_file_path)
            return ConversationHandler.END

        # Сохраняем данные запроса в контексте для последующей обработки
        active_requests[user.id] = {
            'request': license_request,
            'temp_file': temp_file_path
        }

        # Проверяем, есть ли уже лицензии для этого устройства
        existing_licenses = license_store.get_licenses_by_device_hash(
            license_request.device_hash)
        if existing_licenses:
            keyboard = [
                [
                    InlineKeyboardButton(
                        "Да, заменить", callback_data='replace_license'),
                    InlineKeyboardButton("Отмена", callback_data='cancel')
                ]
            ]
            reply_markup = InlineKeyboardMarkup(keyboard)
            update.message.reply_text(
                f"⚠️ Для этого устройства уже есть активная лицензия "
                f"(приложение: {existing_licenses[0].app_id}).\n\n"
                f"Хотите заменить существующую лицензию?",
                reply_markup=reply_markup
            )
            return AWAITING_CONFIRMATION

        # Выбор типа лицензии
        return ask_license_type(update, context)

    except Exception as e:
        logger.error(f"Error processing license request: {e}")
        update.message.reply_text(
            "❌ Ошибка при обработке запроса лицензии. "
            "Пожалуйста, убедитесь, что файл не поврежден и попробуйте снова."
        )
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)
        return AWAITING_REQUEST_FILE


def ask_license_type(update: Update, context: CallbackContext) -> int:
    """
    Показывает меню выбора типа лицензии
    """
    keyboard = [
        [InlineKeyboardButton("Стандартная", callback_data='type_standard')],
        [InlineKeyboardButton("Премиум", callback_data='type_premium')],
        [InlineKeyboardButton("Бизнес", callback_data='type_business')],
        [InlineKeyboardButton("Отмена", callback_data='cancel')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    # Используем reply_text, если сообщение еще не отправлено (из handle_license_request_file)
    if update.message:
        update.message.reply_text(
            "🔹 Выберите тип лицензии:",
            reply_markup=reply_markup
        )
    # Или edit_message_text, если обрабатываем callback (из process_license_confirmation)
    else:
        query = update.callback_query
        query.edit_message_text(
            "🔹 Выберите тип лицензии:",
            reply_markup=reply_markup
        )

    return AWAITING_LICENSE_TYPE


def handle_license_type_selection(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает выбор типа лицензии
    """
    query = update.callback_query
    query.answer()

    user_id = update.effective_user.id

    if query.data == 'cancel':
        return cancel_conversation(update, context)

    # Сохраняем выбранный тип лицензии
    license_type = query.data.replace('type_', '')
    active_requests[user_id]['license_type'] = license_type

    # Настраиваем фичи в зависимости от типа лицензии
    features = LicenseFeatures()
    if license_type == 'premium':
        features.monisync_backup_password = True
        features.monisync_export_data = True
    elif license_type == 'business':
        features.monisync_backup_password = True
        features.monisync_export_data = True
        features.analytics_insights = True
        features.planner_allow_many = True

    active_requests[user_id]['features'] = features

    # Выбор срока действия лицензии
    keyboard = [
        [InlineKeyboardButton("1 месяц", callback_data='duration_30')],
        [InlineKeyboardButton("6 месяцев", callback_data='duration_180')],
        [InlineKeyboardButton("1 год", callback_data='duration_365')],
        [InlineKeyboardButton(
            "Бессрочно", callback_data='duration_unlimited')],
        [InlineKeyboardButton("Отмена", callback_data='cancel')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    query.edit_message_text(
        f"🔹 Выбран тип лицензии: *{license_type.capitalize()}*\n\n"
        f"Теперь выберите срок действия лицензии:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )

    return AWAITING_LICENSE_DURATION


def handle_license_duration_selection(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает выбор срока действия лицензии
    """
    query = update.callback_query
    query.answer()

    user_id = update.effective_user.id

    if query.data == 'cancel':
        return cancel_conversation(update, context)

    # Получаем данные из активного запроса
    request_data = active_requests[user_id]
    license_request = request_data['request']
    license_type = request_data['license_type']
    features = request_data['features']

    # Определяем срок действия
    duration_days = None
    if query.data != 'duration_unlimited':
        duration_days = int(query.data.replace('duration_', ''))

    # Создаем лицензию
    try:
        license_obj = license_store.create_license(
            app_id=license_request.app_id,
            device_hash=license_request.device_hash,
            license_type=license_type,
            features=features,
            expiration_days=duration_days
        )

        # Подписываем лицензию (теперь можем передавать даты с часовым поясом)
        signed_license = licensify_cli.sign_license(
            license_obj,
            request_file_path=request_data.get(
                'temp_file')  # Передаем путь к .mlr файлу
        )

        # Сериализуем лицензию в бинарный файл
        license_filename = f"{settings.license_file_prefix}_{license_obj.app_id}_{license_obj.device_hash[:8]}.licensify"

        # Создаем временный файл с лицензией
        with tempfile.NamedTemporaryFile(delete=False, suffix='.licensify') as temp_file:
            if isinstance(signed_license, dict):
                json.dump(signed_license, temp_file,
                          ensure_ascii=False, indent=2)
            else:
                temp_file.write(signed_license)
            temp_file_path = temp_file.name

        # Отправляем файл пользователю
        with open(temp_file_path, 'rb') as license_file:
            context.bot.send_document(
                chat_id=user_id,
                document=license_file,
                filename=license_filename,
                caption=(
                    f"✅ Лицензия успешно создана!\n\n"
                    f"*Тип:* {license_type.capitalize()}\n"
                    f"*Срок действия:* {get_expiration_text(license_obj)}\n\n"
                    f"Импортируйте этот файл в приложение для активации лицензии."
                ),
                parse_mode='Markdown'
            )

        # Отправляем сообщение администраторам
        for admin_id in settings.admin_user_ids:
            if admin_id != user_id:  # Не отправляем себе же
                context.bot.send_message(
                    chat_id=admin_id,
                    text=(
                        f"🔔 *Выдана новая лицензия*\n\n"
                        f"*Пользователь:* {update.effective_user.first_name} ({update.effective_user.id})\n"
                        f"*Приложение:* {license_request.app_id}\n"
                        f"*Тип:* {license_type.capitalize()}\n"
                        f"*Срок действия:* {get_expiration_text(license_obj)}\n"
                        f"*ID лицензии:* `{license_obj.id}`"
                    ),
                    parse_mode='Markdown'
                )

        # Удаляем временные файлы
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)

        if 'temp_file' in request_data and os.path.exists(request_data['temp_file']):
            os.unlink(request_data['temp_file'])

        # Очищаем данные активного запроса
        if user_id in active_requests:
            del active_requests[user_id]

        query.edit_message_text(
            "✅ Лицензия успешно создана и отправлена вам!\n\n"
            "Импортируйте файл лицензии в приложение для активации."
        )

        return ConversationHandler.END

    except Exception as e:
        logger.error(f"Error creating license: {e}")
        query.edit_message_text(
            "❌ Ошибка при создании лицензии. Пожалуйста, попробуйте снова позже."
        )

        # Удаляем временный файл запроса
        if 'temp_file' in request_data and os.path.exists(request_data['temp_file']):
            os.unlink(request_data['temp_file'])

        if user_id in active_requests:
            del active_requests[user_id]

        return ConversationHandler.END


def process_license_confirmation(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает подтверждение замены существующей лицензии
    """
    query = update.callback_query
    query.answer()

    user_id = update.effective_user.id

    if query.data == 'cancel':
        return cancel_conversation(update, context)

    elif query.data == 'replace_license':
        # Продолжаем процесс выдачи лицензии
        return ask_license_type(update, context)


def cancel_conversation(update: Update, context: CallbackContext) -> int:
    """
    Отменяет процесс выдачи лицензии
    """
    user_id = update.effective_user.id

    # Удаляем временный файл, если он существует
    if user_id in active_requests and 'temp_file' in active_requests[user_id]:
        temp_file = active_requests[user_id]['temp_file']
        if os.path.exists(temp_file):
            os.unlink(temp_file)

    # Очищаем данные активного запроса
    if user_id in active_requests:
        del active_requests[user_id]

    # Используем правильный метод в зависимости от типа обновления
    if update.callback_query:
        update.callback_query.edit_message_text(
            "❌ Процесс выдачи лицензии отменен. "
            "Для начала нового запроса отправьте команду /license"
        )
    else:
        update.message.reply_text(
            "❌ Процесс выдачи лицензии отменен. "
            "Для начала нового запроса отправьте команду /license"
        )

    return ConversationHandler.END


def stats_command(update: Update, context: CallbackContext) -> None:
    """
    Показывает статистику по лицензиям (только для администраторов)
    """
    user_id = update.effective_user.id

    if not settings.is_admin(user_id):
        update.message.reply_text("❌ У вас нет доступа к этой команде.")
        return

    # Собираем статистику
    all_licenses = license_store.licenses.values()
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

    license_id = args[0]
    result = license_store.delete_license(license_id)

    if result:
        update.message.reply_text(
            f"✅ Лицензия с ID {license_id} успешно отозвана."
        )
    else:
        update.message.reply_text(
            f"❌ Лицензия с ID {license_id} не найдена."
        )


def get_expiration_text(license_obj: License) -> str:
    """
    Возвращает текстовое представление срока действия лицензии
    """
    if not license_obj.expiration_date:
        return "Бессрочно"

    return license_obj.expiration_date.strftime("%d.%m.%Y")


def error_handler(update: object, context: CallbackContext) -> None:
    """
    Обрабатывает ошибки, возникающие во время работы бота
    """
    logger.error(f"Exception while handling an update: {context.error}")


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
        expiry = license_obj.expiration_date.strftime(
            "%d.%m.%Y") if license_obj.expiration_date else "Бессрочно"

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


def search_command(update: Update, context: CallbackContext) -> int:
    """
    Запускает процесс поиска лицензий
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

    # Выполняем поиск в зависимости от выбранного параметра
    if search_param == SEARCH_BY_ID:
        licenses = license_store.get_license_by_id(search_term)
        if licenses:
            licenses = [licenses]  # Преобразуем в список для единообразия
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
            expiry = license_obj.expiration_date.strftime(
                "%d.%m.%Y") if license_obj.expiration_date else "Бессрочно"

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
        [InlineKeyboardButton("« Назад", callback_data=ADMIN_MENU_BACK)]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    if update.callback_query:
        update.callback_query.answer()
        update.callback_query.edit_message_text(
            "📥 *Экспорт лицензий*\n\n"
            "Выберите формат экспорта и тип лицензий:",
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )
    else:
        update.message.reply_text(
            "📥 *Экспорт лицензий*\n\n"
            "Выберите формат экспорта и тип лицензий:",
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


def export_licenses_to_csv(licenses: List[License]) -> Tuple[str, str]:
    """
    Экспортирует лицензии в формате CSV

    Returns:
        Tuple[str, str]: Путь к временному файлу и имя файла
    """
    # Создаем временный файл
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"licenses_export_{timestamp}.csv"
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.csv')

    try:
        # Создаем CSV файл
        with open(temp_file.name, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)

            # Записываем заголовки
            writer.writerow([
                'ID', 'Application ID', 'Type', 'Created At', 'Expiration Date',
                'Status', 'Device Hash', 'Features'
            ])

            # Записываем данные
            for license_obj in licenses:
                status = "Active" if not license_obj.is_expired() else "Expired"
                created_at = license_obj.created_at.isoformat() if license_obj.created_at else ''
                expiration_date = license_obj.expiration_date.isoformat(
                ) if license_obj.expiration_date else 'Unlimited'
                device_hash = license_obj.metadata.device_hash if license_obj.metadata else ''
                features = json.dumps(
                    asdict(license_obj.features)) if license_obj.features else '{}'

                writer.writerow([
                    license_obj.id,
                    license_obj.app_id,
                    license_obj.type,
                    created_at,
                    expiration_date,
                    status,
                    device_hash,
                    features
                ])

        return temp_file.name, file_name
    except Exception as e:
        # Если произошла ошибка, удаляем временный файл
        os.unlink(temp_file.name)
        raise e


def export_licenses_to_json(licenses: List[License]) -> Tuple[str, str]:
    """
    Экспортирует лицензии в формате JSON

    Returns:
        Tuple[str, str]: Путь к временному файлу и имя файла
    """
    # Создаем временный файл
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"licenses_export_{timestamp}.json"
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.json')

    try:
        # Создаем список лицензий в формате словарей
        licenses_dict = []
        for license_obj in licenses:
            status = "Active" if not license_obj.is_expired() else "Expired"
            license_dict = license_obj.to_dict()
            license_dict['status'] = status
            licenses_dict.append(license_dict)

        # Записываем JSON
        with open(temp_file.name, 'w', encoding='utf-8') as f:
            # Используем custom encoder для обработки типов данных, которые не сериализуются в JSON напрямую
            json.dump(licenses_dict, f, default=lambda o: o.isoformat()
                      if isinstance(o, datetime) else o.__dict__, indent=2)

        return temp_file.name, file_name
    except Exception as e:
        # Если произошла ошибка, удаляем временный файл
        os.unlink(temp_file.name)
        raise e


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


def cleanup_expired_licenses(update: Update, context: CallbackContext) -> None:
    """
    Предлагает очистить истекшие лицензии
    """
    query = update.callback_query
    query.answer()

    user = update.effective_user
    if not settings.is_admin(user.id):
        query.edit_message_text("⛔ У вас нет доступа к этой функции.")
        return

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


def handle_text_buttons(update: Update, context: CallbackContext) -> None:
    """
    Обрабатывает нажатия на текстовые кнопки для простых команд
    """
    text = update.message.text

    # Проверяем, содержит ли текст определенные строки (игнорируя эмодзи)
    # Кнопки "Получить лицензию" и "Поиск лицензий" обрабатываются через ConversationHandler
    if "Помощь" in text:
        return help_command(update, context)
    elif "Админпанель" in text:
        return admin_command(update, context)
    elif "Статистика" in text:
        return stats_command(update, context)
    elif "Отозвать лицензию" in text:
        return revoke_command(update, context)
    else:
        # Не реагируем на другие текстовые сообщения
        pass


def start_bot(use_webhook: bool = False):
    """
    Главная функция запуска бота
    """
    token = settings.bot_token
    if not token:
        logger.error(
            "Telegram bot token is not set. Please set BOT_TOKEN environment variable.")
        return

    webhook_settings = {}
    if use_webhook:
        webhook_url = settings.webhook_url
        webhook_port = settings.webhook_port
        webhook_path = settings.webhook_path

        if not webhook_url:
            logger.error(
                "Webhook URL is not set. Please set WEBHOOK_URL environment variable.")
            return

        webhook_settings = {
            'use_webhook': True,
            'webhook_url': webhook_url,
            'webhook_port': webhook_port or 8443,
            'webhook_path': webhook_path or '/webhook'
        }

    # Запускаем бота с указанными настройками
    try:
        run_bot(token, **webhook_settings)
    except Exception as e:
        logger.error(f"Error running bot: {e}")
        raise


if __name__ == "__main__":
    start_bot()
