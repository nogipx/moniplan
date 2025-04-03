#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import uuid
import tempfile
import logging
from datetime import datetime, timedelta, timezone
from typing import Dict, List, Tuple, Optional, Any

from utils.config import settings
from utils.license_store import LicenseStore
from licensify_cli.licensify_cli import LicensifyCLI
from utils.models import License, LicenseRequest, LicenseMetadata, LicenseFeatures

logger = logging.getLogger(__name__)


class LicenseService:
    """
    Сервис для работы с лицензиями
    """

    def __init__(self, license_store: LicenseStore, licensify_cli: LicensifyCLI):
        self.license_store = license_store
        self.licensify_cli = licensify_cli

    def process_license_request_file(self, file_path: str) -> Tuple[bool, Optional[LicenseRequest], str, List[License]]:
        """
        Обрабатывает файл запроса лицензии

        Args:
            file_path: Путь к файлу запроса лицензии

        Returns:
            Tuple[bool, Optional[LicenseRequest], str, List[License]]: 
                - успех операции
                - объект запроса лицензии (если успешно)
                - сообщение об ошибке (если есть)
                - список существующих лицензий для устройства
        """
        try:
            logger.info(
                f"Начинаем обработку файла запроса лицензии: {file_path}")

            # Чтение зашифрованных данных из файла
            with open(file_path, 'rb') as f:
                encrypted_data = f.read()

            logger.debug(f"Прочитано {len(encrypted_data)} байт данных")

            # Декодирование запроса лицензии
            request_info = self.licensify_cli.decrypt_license_request(
                encrypted_data)

            logger.debug(f"Расшифрованный запрос: {request_info}")

            if not request_info:
                logger.error("Получен пустой результат расшифровки")
                return False, None, "Некорректный формат запроса лицензии", []

            # Создаем объект запроса
            license_request = LicenseRequest(
                app_id=request_info.get("appId", ""),
                device_id=request_info.get("deviceHash", ""),
                user_id=request_info.get("userId", ""),
                device_name=request_info.get("deviceName", ""),
                timestamp=request_info.get(
                    "createdAt", datetime.now(timezone.utc))
            )

            logger.debug(f"Создан объект запроса: {license_request}")
            logger.debug(
                f"Timestamp: {license_request.timestamp}, тип: {type(license_request.timestamp)}, timezone: {license_request.timestamp.tzinfo}")

            # Проверяем срок действия запроса
            request_time = license_request.timestamp
            # Если timestamp не имеет часового пояса, устанавливаем UTC
            if request_time.tzinfo is None:
                logger.debug(
                    "Timestamp не имеет часового пояса, устанавливаем UTC")
                request_time = request_time.replace(tzinfo=timezone.utc)

            # Используем datetime.now с часовым поясом UTC для совместимости
            current_time = datetime.now(timezone.utc)
            expiration_hours = settings.license_request_expiration_hours

            logger.debug(
                f"Request time: {request_time}, Current time: {current_time}")
            logger.debug(
                f"Разница: {(current_time - request_time).total_seconds()} секунд")
            logger.debug(f"Лимит: {expiration_hours * 3600} секунд")

            if (current_time - request_time).total_seconds() > expiration_hours * 3600:
                logger.warning(
                    f"Срок действия запроса истек. Создан: {request_time}, текущее время: {current_time}")
                return False, None, f"Срок действия запроса истек. Пожалуйста, создайте новый запрос в приложении (максимальный срок действия: {expiration_hours} часов)", []

            # Проверяем, есть ли уже лицензии для этого устройства
            existing_licenses = self.license_store.get_licenses_by_device_hash(
                license_request.device_id)

            logger.info(
                f"Обработка запроса завершена успешно. Найдено {len(existing_licenses)} существующих лицензий.")

            return True, license_request, "", existing_licenses

        except Exception as e:
            logger.error(
                f"Error processing license request file: {e}", exc_info=True)
            return False, None, f"Ошибка при обработке запроса лицензии: {e}", []

    def create_license(self, license_request: LicenseRequest, license_type: str,
                       duration_days: Optional[int] = None, telegram_user_id: Optional[int] = None,
                       telegram_username: Optional[str] = None) -> Tuple[bool, Optional[License], str]:
        """
        Создает новую лицензию на основе запроса

        Args:
            license_request: Объект запроса лицензии
            license_type: Тип лицензии
            duration_days: Срок действия лицензии в днях (None для бессрочной)
            telegram_user_id: ID пользователя Telegram
            telegram_username: Имя пользователя Telegram

        Returns:
            Tuple[bool, Optional[License], str]:
                - успех операции
                - объект лицензии (если успешно)
                - сообщение об ошибке (если есть)
        """
        try:
            # Определяем параметры лицензии на основе типа
            features = LicenseFeatures()

            # Устанавливаем особенности в зависимости от типа лицензии
            if license_type == "standard":
                features.premium_features = False
                features.business_features = False
            elif license_type == "premium":
                features.premium_features = True
                features.business_features = False
            elif license_type == "business":
                features.premium_features = True
                features.business_features = True

            # Определяем срок действия (с UTC часовым поясом)
            issue_date = datetime.now(timezone.utc)
            expiration_date = None if duration_days is None else issue_date + \
                timedelta(days=duration_days)

            # Создаем метаданные
            metadata = LicenseMetadata(
                issuer="Telegram Bot",
                issuer_id=str(
                    telegram_user_id) if telegram_user_id else "unknown",
                issue_date=issue_date,
                telegram_username=telegram_username
            )

            # Создаем лицензию
            license_obj = License(
                id=str(uuid.uuid4()),
                app_id=license_request.app_id,
                device_id=license_request.device_id,
                user_id=license_request.user_id,
                device_name=license_request.device_name,
                type=license_type,
                features=features,
                metadata=metadata,
                expiration_date=expiration_date,
                revoked=False
            )

            # Сохраняем лицензию
            self.license_store.add_license(license_obj)

            return True, license_obj, ""

        except Exception as e:
            logger.error(f"Error creating license: {e}")
            return False, None, f"Ошибка при создании лицензии: {e}"

    def sign_and_save_license(self, license_obj: License, request_file_path: Optional[str] = None) -> Tuple[bool, Optional[Dict], str, str]:
        """
        Подписывает лицензию и сохраняет во временный файл

        Args:
            license_obj: Объект лицензии
            request_file_path: Путь к файлу запроса лицензии (опционально)

        Returns:
            Tuple[bool, Optional[Dict], str, str]:
                - успех операции
                - словарь с данными лицензии (если успешно)
                - путь к временному файлу с лицензией (если успешно)
                - имя файла лицензии (если успешно)
        """
        try:
            # Подготавливаем данные для создания лицензии
            # Если дата не указана, используем максимальную дату (бессрочная лицензия)
            expiration_date = license_obj.expiration_date
            if expiration_date is None:
                # Используем None или далёкую дату в будущем в зависимости от реализации CLI
                expiration_date = None
            else:
                # Убедимся, что дата имеет часовой пояс
                if expiration_date.tzinfo is None:
                    expiration_date = expiration_date.replace(
                        tzinfo=timezone.utc)

            # Подготавливаем features
            features = {}
            if license_obj.features:
                if license_obj.features.premium_features:
                    features["premiumFeatures"] = "true"
                if license_obj.features.business_features:
                    features["businessFeatures"] = "true"

            # Подготавливаем metadata
            metadata = {}
            if license_obj.metadata:
                metadata["issuer"] = license_obj.metadata.issuer
                metadata["issuerId"] = license_obj.metadata.issuer_id
                if license_obj.metadata.telegram_username:
                    metadata["telegramUsername"] = license_obj.metadata.telegram_username

                # Гарантируем, что дата выпуска имеет часовой пояс
                issue_date = license_obj.metadata.issue_date
                if issue_date.tzinfo is None:
                    issue_date = issue_date.replace(tzinfo=timezone.utc)
                metadata["issueDate"] = issue_date.isoformat()

            # Подписываем лицензию с использованием licensify CLI
            if request_file_path and os.path.exists(request_file_path):
                with open(request_file_path, 'rb') as f:
                    request_data = f.read()

                license_data, temp_file_path = self.licensify_cli.respond_to_request(
                    request_data=request_data,
                    expiration_date=expiration_date,
                    license_type=license_obj.type,
                    features=features,
                    metadata=metadata
                )
            else:
                license_data, temp_file_path = self.licensify_cli.generate_license(
                    app_id=license_obj.app_id,
                    expiration_date=expiration_date,
                    license_type=license_obj.type,
                    features=features,
                    metadata={
                        "deviceId": license_obj.device_id,
                        "userId": license_obj.user_id,
                        "deviceName": license_obj.device_name,
                        **metadata
                    }
                )

            # Создаем имя файла лицензии
            file_name = f"{settings.license_file_prefix}_{license_obj.app_id}_{license_obj.device_id[:8]}.licensify"

            return True, license_data, temp_file_path, file_name

        except Exception as e:
            logger.error(f"Error signing license: {e}")
            return False, None, "", ""

    def get_expiration_text(self, license_obj: License) -> str:
        """
        Возвращает текстовое представление срока действия лицензии

        Args:
            license_obj: Объект лицензии

        Returns:
            str: Текстовое представление срока действия
        """
        if not license_obj.expiration_date:
            return "Бессрочно"

        return license_obj.expiration_date.strftime(settings.date_format)


# Создаем глобальные экземпляры
license_store = LicenseStore(settings.license_db_path)
licensify_cli = LicensifyCLI(
    cli_path=settings.licensify_path,
    private_key_path=settings.private_key_path,
    public_key_path=settings.public_key_path
)
license_service = LicenseService(license_store, licensify_cli)
