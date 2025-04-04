#!/usr/bin/env python
# -*- coding: utf-8 -*-
import hashlib
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
from utils.license_config import license_config

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
                       telegram_username: Optional[str] = None, license_features: Optional[Dict[str, bool]] = None) -> Tuple[bool, Optional[License], str]:
        """
        Создает новую лицензию на основе запроса

        Args:
            license_request: Объект запроса лицензии
            license_type: Тип лицензии
            duration_days: Срок действия лицензии в днях (None для бессрочной)
            telegram_user_id: ID пользователя Telegram
            telegram_username: Имя пользователя Telegram
            license_features: Словарь с фичами лицензии из конфигурации

        Returns:
            Tuple[bool, Optional[License], str]:
                - успех операции
                - объект лицензии (если успешно)
                - сообщение об ошибке (если есть)
        """
        try:
            # Проверяем входные данные
            if not license_request:
                return False, None, "Не предоставлен запрос лицензии"

            if not license_request.app_id:
                return False, None, "В запросе не указан идентификатор приложения"

            if not license_request.device_id:
                return False, None, "В запросе не указан идентификатор устройства"

            # Проверяем, что тип лицензии присутствует в конфигурации
            if license_type not in license_config.license_types:
                return False, None, f"Неверный тип лицензии: {license_type}"

            if duration_days is not None and duration_days <= 0:
                return False, None, "Срок действия лицензии должен быть положительным числом"

            # Определяем параметры лицензии на основе типа
            features = LicenseFeatures()

            # Если переданы фичи из конфигурации, устанавливаем их
            if license_features:
                # Обрабатываем стандартные фичи
                if "premium_features" in license_features:
                    features.premium_features = license_features["premium_features"]
                if "business_features" in license_features:
                    features.business_features = license_features["business_features"]

                # Обрабатываем все остальные фичи как кастомные
                for feature_name, feature_value in license_features.items():
                    if feature_name not in ["premium_features", "business_features"]:
                        features.custom_features[feature_name] = feature_value
            else:
                # Фоллбек для обратной совместимости, если фичи не переданы
                license_type_config = license_config.get_license_type(
                    license_type)
                if license_type_config:
                    # Используем конфигурацию из файла
                    for feature_name, feature_value in license_type_config.features.items():
                        if feature_name == "premium_features":
                            features.premium_features = feature_value
                        elif feature_name == "business_features":
                            features.business_features = feature_value
                        else:
                            features.custom_features[feature_name] = feature_value
                else:
                    # Запасная логика, если тип не найден в конфигурации
                    logger.warning(
                        f"Тип лицензии {license_type} не найден в конфигурации")
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
                device_hash=license_request.device_id,
                issue_hash=f"{settings.bot_token.split(':')[0]}_{telegram_user_id}" if telegram_user_id else "unknown",
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
            # Проверяем входные данные
            if not license_obj:
                logger.error("Не предоставлен объект лицензии для подписи")
                return False, None, "", ""

            if not license_obj.app_id:
                logger.error("В лицензии не указан app_id")
                return False, None, "", ""

            if not license_obj.device_id:
                logger.error("В лицензии не указан device_id")
                return False, None, "", ""

            if not license_obj.type:
                logger.error("В лицензии не указан тип")
                return False, None, "", ""

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
                # Добавляем кастомные фичи
                for feature_name, feature_value in license_obj.features.custom_features.items():
                    # Преобразуем имя из snake_case в camelCase для JSON
                    camel_case_name = ''.join(word.capitalize() if i > 0 else word
                                              for i, word in enumerate(feature_name.split('_')))
                    features[camel_case_name] = "true" if feature_value else "false"

            # Подготавливаем metadata
            metadata = {}
            if license_obj.metadata:
                if license_obj.metadata.telegram_username:
                    metadata["telegramUsername"] = license_obj.metadata.telegram_username
                if license_obj.metadata.device_hash:
                    metadata["deviceHash"] = license_obj.metadata.device_hash
                if license_obj.metadata.issue_hash:
                    h = hashlib.sha512()
                    h.update(license_obj.metadata.issue_hash.encode())
                    metadata["issueHash"] = h

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
                raise FileNotFoundError()

            # Создаем имя файла лицензии
            file_name = f"{settings.license_file_prefix}_{license_obj.app_id}_{license_obj.device_id[:8]}.licensify"

            return True, license_data, temp_file_path, file_name

        except Exception as e:
            logger.error(f"Error signing license: {e}")
            # Удаляем созданную лицензию из хранилища, так как её не удалось подписать
            if license_obj and license_obj.id:
                try:
                    self.license_store.delete_license(license_obj.id)
                    logger.info(
                        f"Deleted invalid license {license_obj.id} due to signing error")
                except Exception as del_e:
                    logger.error(f"Failed to delete invalid license: {del_e}")
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
