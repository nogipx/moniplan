#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
import tempfile
import logging
from typing import Dict, Optional, Any, Tuple
from datetime import datetime

from .config import settings
from .models import License, LicenseRequest
from licensify_cli.licensify_cli import LicensifyCLI

logger = logging.getLogger(__name__)


class CryptoUtils:
    """
    Утилита для работы с криптографией (подпись и проверка лицензий)
    Используется как обертка над LicensifyCLI для обеспечения обратной совместимости
    """

    def __init__(self, private_key_path: str, public_key_path: str):
        """
        Инициализирует утилиту с путями к ключам

        Args:
            private_key_path: Путь к приватному ключу
            public_key_path: Путь к публичному ключу
        """
        self.private_key_path = private_key_path
        self.public_key_path = public_key_path

        # Проверяем наличие ключей
        if not os.path.exists(private_key_path):
            logger.warning(f"Приватный ключ не найден: {private_key_path}")

        if not os.path.exists(public_key_path):
            logger.warning(f"Публичный ключ не найден: {public_key_path}")

        # Инициализируем CLI клиент
        self.cli = LicensifyCLI(
            cli_path=settings.licensify_path,
            private_key_path=private_key_path,
            public_key_path=public_key_path
        )

    def decode_license_request(self, request_data: bytes) -> Optional[LicenseRequest]:
        """
        Расшифровывает файл запроса лицензии

        Args:
            request_data: Бинарные данные запроса лицензии

        Returns:
            Optional[LicenseRequest]: Объект запроса лицензии или None, если произошла ошибка
        """
        try:
            # Используем LicensifyCLI для расшифровки запроса
            request_info = self.cli.decrypt_license_request(request_data)

            # Преобразуем ответ в объект LicenseRequest
            license_request = LicenseRequest(
                app_id=request_info.get("appId", ""),
                device_id=request_info.get("deviceHash", ""),
                user_id=request_info.get("userId", ""),
                device_name=request_info.get("deviceName", ""),
                timestamp=request_info.get("createdAt", datetime.now())
            )

            return license_request

        except Exception as e:
            logger.error(f"Ошибка при расшифровке запроса лицензии: {e}")
            return None

    def sign_license(self, license_obj: License, request_file_path: Optional[str] = None) -> Optional[Dict]:
        """
        Подписывает лицензию

        Args:
            license_obj: Объект лицензии для подписи
            request_file_path: Путь к файлу запроса лицензии (необязательно)

        Returns:
            Optional[Dict]: Подписанная лицензия в виде словаря
        """
        try:
            # Подготавливаем данные для создания лицензии
            expiration_date = license_obj.expiration_date if license_obj.expiration_date else datetime.max

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
                metadata["issueDate"] = license_obj.metadata.issue_date.isoformat()

            # Если предоставлен файл запроса, используем respond_to_request
            if request_file_path and os.path.exists(request_file_path):
                with open(request_file_path, 'rb') as f:
                    request_data = f.read()

                license_data, _ = self.cli.respond_to_request(
                    request_data=request_data,
                    expiration_date=expiration_date,
                    license_type=license_obj.type,
                    features=features,
                    metadata=metadata
                )

                return license_data
            else:
                # Используем generate_license для создания лицензии напрямую
                license_data, _ = self.cli.generate_license(
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

                return license_data

        except Exception as e:
            logger.error(f"Ошибка при создании лицензии: {e}")
            return None

    def verify_license(self, license_data: Dict) -> Tuple[bool, str]:
        """
        Проверяет действительность лицензии

        Args:
            license_data: Данные лицензии в виде словаря

        Returns:
            Tuple[bool, str]: Результат проверки (True - действительна, False - недействительна)
                              и сообщение с результатом или ошибкой
        """
        try:
            # Создаем временный файл для лицензии
            with tempfile.NamedTemporaryFile(delete=False, suffix='.mln', mode='w') as license_file:
                json.dump(license_data, license_file,
                          ensure_ascii=False, indent=2)
                license_path = license_file.name

            # Проверяем лицензию через licensify CLI
            result = self.cli.verify_license(license_path)

            # Удаляем временный файл
            try:
                os.unlink(license_path)
            except:
                pass

            # Анализируем результат
            if "Подпись верна" in result or "Signature is valid" in result:
                return True, "Лицензия действительна"
            else:
                return False, "Лицензия недействительна: подпись не соответствует"

        except Exception as e:
            logger.error(f"Ошибка при проверке лицензии: {e}")
            return False, f"Ошибка при проверке лицензии: {str(e)}"
