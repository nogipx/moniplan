#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import tempfile
import logging
from typing import Dict, Any, Optional

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, ParseMode
from telegram.ext import CallbackContext, ConversationHandler
from telegram.error import TelegramError

from utils.config import settings
from ..constants import *
from ..services.license_service import license_service
from .common import cancel_conversation
from utils.license_config import license_config

logger = logging.getLogger(__name__)


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

    # Обрабатываем запрос лицензии
    success, license_request, error_message, existing_licenses = license_service.process_license_request_file(
        temp_file_path)

    if not success:
        update.message.reply_text(f"❌ {error_message}")
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)
        return AWAITING_REQUEST_FILE if "Срок действия запроса истек" in error_message else ConversationHandler.END

    # Сохраняем данные запроса в контексте для последующей обработки
    context.user_data['license_request_data'] = {
        'request': license_request,
        'temp_file': temp_file_path
    }

    # Проверяем, есть ли уже лицензии для этого устройства
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


def ask_license_type(update: Update, context: CallbackContext) -> int:
    """
    Показывает меню выбора типа лицензии
    """
    # Получаем отсортированный список типов лицензий
    license_types = license_config.get_sorted_license_types()

    # Создаем кнопки для каждого типа лицензии
    keyboard = []
    for lt in license_types:
        keyboard.append([InlineKeyboardButton(
            lt.name, callback_data=f'{TYPE_PREFIX}{lt.id}')])

    # Добавляем кнопку отмены
    keyboard.append([InlineKeyboardButton("Отмена", callback_data='cancel')])

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
    from utils.license_config import license_config

    query = update.callback_query
    query.answer()

    if query.data == 'cancel':
        return cancel_conversation(update, context)

    # Сохраняем выбранный тип лицензии
    license_type = query.data.replace(TYPE_PREFIX, '')
    context.user_data['license_request_data']['license_type'] = license_type

    # Получаем информацию о выбранном типе лицензии
    license_type_config = license_config.get_license_type(license_type)
    if not license_type_config:
        logger.error(f"Выбран неизвестный тип лицензии: {license_type}")
        query.edit_message_text("❌ Ошибка: выбран неизвестный тип лицензии.")
        return ConversationHandler.END

    # Выбор срока действия лицензии
    durations = license_config.get_sorted_durations()

    # Создаем кнопки для каждого срока действия
    keyboard = []
    for duration in durations:
        keyboard.append([InlineKeyboardButton(
            duration.name, callback_data=f'{DURATION_PREFIX}{duration.id}')])

    # Добавляем кнопку отмены
    keyboard.append([InlineKeyboardButton("Отмена", callback_data='cancel')])

    reply_markup = InlineKeyboardMarkup(keyboard)

    query.edit_message_text(
        f"🔹 Выбран тип лицензии: *{license_type_config.name}*\n\n"
        f"{license_type_config.description}\n\n"
        f"Теперь выберите срок действия лицензии:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )

    return AWAITING_LICENSE_DURATION


def handle_license_duration_selection(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает выбор срока действия лицензии и выдает лицензию
    """
    from utils.license_config import license_config

    query = update.callback_query
    query.answer()

    user = update.effective_user
    user_id = user.id

    if query.data == 'cancel':
        return cancel_conversation(update, context)

    # Получаем данные из контекста
    request_data = context.user_data['license_request_data']
    license_request = request_data['request']
    license_type_id = request_data['license_type']

    # Получаем тип лицензии из конфигурации
    license_type_config = license_config.get_license_type(license_type_id)
    if not license_type_config:
        logger.error(f"Не найден тип лицензии: {license_type_id}")
        query.edit_message_text(f"❌ Ошибка: неизвестный тип лицензии")
        return ConversationHandler.END

    # Определяем срок действия
    duration_id = query.data.replace(DURATION_PREFIX, '')
    duration_config = license_config.get_duration(duration_id)
    if not duration_config:
        logger.error(f"Не найден срок действия: {duration_id}")
        query.edit_message_text(f"❌ Ошибка: неизвестный срок действия")
        return ConversationHandler.END

    duration_days = duration_config.days  # None для бессрочной лицензии

    # Создаем лицензию
    try:
        # Создаем лицензию
        success, license_obj, error_message = license_service.create_license(
            license_request=license_request,
            license_type=license_type_id,
            license_features=license_type_config.features,  # Передаем фичи из конфигурации
            duration_days=duration_days,
            telegram_user_id=user_id,
            telegram_username=user.username
        )

        if not success:
            query.edit_message_text(f"❌ {error_message}")

            # Очищаем данные запроса
            if 'license_request_data' in context.user_data:
                if 'temp_file' in context.user_data['license_request_data'] and os.path.exists(context.user_data['license_request_data']['temp_file']):
                    os.unlink(
                        context.user_data['license_request_data']['temp_file'])
                del context.user_data['license_request_data']

            return ConversationHandler.END

        # Подписываем лицензию и сохраняем во временный файл
        success, license_dict, file_path, file_name = license_service.sign_and_save_license(
            license_obj,
            request_file_path=request_data.get('temp_file')
        )

        if not success:
            query.edit_message_text(
                "❌ Ошибка при подписи лицензии. Пожалуйста, попробуйте снова позже."
            )

            # Очищаем данные запроса
            if 'license_request_data' in context.user_data:
                if 'temp_file' in context.user_data['license_request_data'] and os.path.exists(context.user_data['license_request_data']['temp_file']):
                    os.unlink(
                        context.user_data['license_request_data']['temp_file'])
                del context.user_data['license_request_data']

            return ConversationHandler.END

        # Отправляем файл пользователю
        with open(file_path, 'rb') as license_file:
            context.bot.send_document(
                chat_id=user_id,
                document=license_file,
                filename=file_name,
                caption=(
                    f"✅ Лицензия успешно создана!\n\n"
                    f"*Тип:* {license_type_config.name}\n"
                    f"*Срок действия:* {license_service.get_expiration_text(license_obj)}\n\n"
                    f"Импортируйте этот файл в приложение для активации лицензии."
                ),
                parse_mode='Markdown'
            )

        # Отправляем сообщение администраторам
        for admin_id in settings.admin_ids:
            if admin_id != user_id:  # Не отправляем себе же
                try:
                    context.bot.send_message(
                        chat_id=admin_id,
                        text=(
                            f"🔔 *Выдана новая лицензия*\n\n"
                            f"*Пользователь:* {user.first_name} ({user.id})\n"
                            f"*Приложение:* {license_request.app_id}\n"
                            f"*Тип:* {license_type_config.name}\n"
                            f"*Срок действия:* {license_service.get_expiration_text(license_obj)}\n"
                            f"*ID лицензии:* `{license_obj.id}`"
                        ),
                        parse_mode='Markdown'
                    )
                except TelegramError as e:
                    logger.warning(
                        f"Failed to send notification to admin {admin_id}: {e}")

        # Удаляем временные файлы
        if os.path.exists(file_path):
            os.unlink(file_path)

        if 'temp_file' in request_data and os.path.exists(request_data['temp_file']):
            os.unlink(request_data['temp_file'])

        # Очищаем данные контекста
        if 'license_request_data' in context.user_data:
            del context.user_data['license_request_data']

        query.edit_message_text(
            "✅ Лицензия успешно создана и отправлена вам!\n\n"
            "Импортируйте файл лицензии в приложение для активации."
        )

        return ConversationHandler.END

    except Exception as e:
        logger.error(f"Error creating license: {e}")

        # Если лицензия была создана, но возникла ошибка при дальнейшей обработке,
        # нужно удалить её из хранилища
        if 'license_obj' in locals() and license_obj and license_obj.id:
            try:
                license_service.license_store.delete_license(license_obj.id)
                logger.info(
                    f"Deleted license {license_obj.id} due to error during creation process")
            except Exception as del_e:
                logger.error(f"Failed to delete invalid license: {del_e}")

        query.edit_message_text(
            "❌ Ошибка при создании лицензии. Пожалуйста, попробуйте снова позже."
        )

        # Удаляем временный файл запроса
        if 'license_request_data' in context.user_data:
            if 'temp_file' in context.user_data['license_request_data'] and os.path.exists(context.user_data['license_request_data']['temp_file']):
                os.unlink(
                    context.user_data['license_request_data']['temp_file'])
            del context.user_data['license_request_data']

        return ConversationHandler.END


def process_license_confirmation(update: Update, context: CallbackContext) -> int:
    """
    Обрабатывает подтверждение замены существующей лицензии
    """
    query = update.callback_query
    query.answer()

    if query.data == 'cancel':
        return cancel_conversation(update, context)

    elif query.data == 'replace_license':
        # Продолжаем процесс выдачи лицензии
        return ask_license_type(update, context)
