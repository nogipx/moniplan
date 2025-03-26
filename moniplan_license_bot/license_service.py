import os
import json
import base64
import logging
import time
from datetime import datetime
from typing import Dict, Any, Optional
from pathlib import Path

import jwt
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.exceptions import UnsupportedAlgorithm, InvalidSignature

logger = logging.getLogger(__name__)


class LicenseService:
    """Сервис для работы с лицензиями."""

    def __init__(self, private_key_path: str, public_key_path: str):
        self.private_key_path = private_key_path
        self.public_key_path = public_key_path
        self.private_key = None
        self.public_key = None

        self._load_keys()

    def _load_keys(self):
        """Загрузить ключи для подписи и верификации."""
        try:
            if os.path.exists(self.private_key_path):
                with open(self.private_key_path, "rb") as key_file:
                    self.private_key = serialization.load_pem_private_key(
                        key_file.read(),
                        password=None
                    )
                logger.info("Приватный ключ успешно загружен")
            else:
                logger.warning(
                    f"Файл с приватным ключом не найден: {self.private_key_path}")

            if os.path.exists(self.public_key_path):
                with open(self.public_key_path, "rb") as key_file:
                    self.public_key = serialization.load_pem_public_key(
                        key_file.read()
                    )
                logger.info("Публичный ключ успешно загружен")
            else:
                logger.warning(
                    f"Файл с публичным ключом не найден: {self.public_key_path}")

            # Если ключи не найдены, генерируем новую пару
            if not self.private_key or not self.public_key:
                logger.info("Ключи не найдены. Генерация новой пары ключей...")
                self._generate_key_pair()

        except (UnsupportedAlgorithm, ValueError) as e:
            logger.error(f"Ошибка загрузки ключей: {e}")
            logger.info("Генерация новой пары ключей...")
            self._generate_key_pair()

    def _generate_key_pair(self):
        """Сгенерировать новую пару ключей."""
        try:
            # Создаем директории для ключей, если их нет
            os.makedirs(os.path.dirname(self.private_key_path), exist_ok=True)
            os.makedirs(os.path.dirname(self.public_key_path), exist_ok=True)

            # Генерируем новый приватный ключ RSA
            private_key = rsa.generate_private_key(
                public_exponent=65537,
                key_size=2048
            )

            # Получаем публичный ключ
            public_key = private_key.public_key()

            # Сохраняем приватный ключ
            with open(self.private_key_path, "wb") as f:
                f.write(private_key.private_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PrivateFormat.PKCS8,
                    encryption_algorithm=serialization.NoEncryption()
                ))

            # Сохраняем публичный ключ
            with open(self.public_key_path, "wb") as f:
                f.write(public_key.public_bytes(
                    encoding=serialization.Encoding.PEM,
                    format=serialization.PublicFormat.SubjectPublicKeyInfo
                ))

            self.private_key = private_key
            self.public_key = public_key

            logger.info("Пара ключей успешно сгенерирована и сохранена")

        except Exception as e:
            logger.error(f"Ошибка генерации ключей: {e}")
            raise

    def decode_activation_request(self, activation_code: str) -> Dict[str, Any]:
        """
        Декодировать код запроса активации и извлечь информацию об устройстве.

        Args:
            activation_code: Код запроса активации от клиента.

        Returns:
            Словарь с данными об устройстве.
        """
        try:
            # Декодируем Base64
            decoded_bytes = base64.b64decode(activation_code)
            decoded_data = decoded_bytes.decode('utf-8')

            # Парсим JSON
            device_info = json.loads(decoded_data)

            required_fields = ['device_id', 'device_name', 'device_model']
            for field in required_fields:
                if field not in device_info:
                    raise ValueError(
                        f"В запросе активации отсутствует обязательное поле: {field}")

            return device_info

        except (base64.binascii.Error, json.JSONDecodeError, ValueError) as e:
            logger.error(f"Ошибка декодирования запроса активации: {e}")
            raise ValueError("Неверный формат кода активации")

    def generate_license_file(self,
                              license_id: str,
                              app_id: str,
                              license_type: str,
                              expiration_date: datetime,
                              created_at: datetime,
                              device_id: str,
                              client_name: Optional[str] = None) -> str:
        """
        Генерировать файл лицензии.

        Args:
            license_id: Уникальный идентификатор лицензии.
            app_id: Идентификатор приложения.
            license_type: Тип лицензии (TRIAL или PRO).
            expiration_date: Дата истечения лицензии.
            created_at: Дата создания лицензии.
            device_id: Идентификатор устройства.
            client_name: Имя клиента (опционально).

        Returns:
            Строка с содержимым файла лицензии в формате JSON.
        """
        if not self.private_key:
            raise ValueError("Приватный ключ не загружен")

        # Создаем данные лицензии
        license_data = {
            "id": license_id,
            "appId": app_id,
            "createdAt": created_at.isoformat(),
            "expirationDate": expiration_date.isoformat(),
            "type": license_type.lower(),
            "features": self._get_features_for_license_type(license_type),
            "metadata": {
                "deviceId": device_id
            }
        }

        if client_name:
            license_data["metadata"]["clientName"] = client_name

        # Данные для подписи (без поля signature)
        signature_data = json.dumps(license_data, sort_keys=True)

        # Создаем подпись
        signature = self._sign_data(signature_data)

        # Добавляем подпись в лицензию
        license_data["signature"] = signature

        # Возвращаем лицензию в формате JSON
        return json.dumps(license_data, indent=2)

    def _sign_data(self, data: str) -> str:
        """
        Подписать данные приватным ключом.

        Args:
            data: Строка с данными для подписи.

        Returns:
            Строка с подписью в формате Base64.
        """
        signature = self.private_key.sign(
            data.encode('utf-8'),
            padding.PKCS1v15(),
            hashes.SHA512()
        )

        return base64.b64encode(signature).decode('utf-8')

    def verify_license(self, license_data: Dict[str, Any]) -> bool:
        """
        Проверить подпись лицензии.

        Args:
            license_data: Данные лицензии.

        Returns:
            True, если подпись действительна, иначе False.
        """
        if not self.public_key:
            raise ValueError("Публичный ключ не загружен")

        try:
            # Извлекаем подпись
            signature = license_data.pop("signature", None)
            if not signature:
                logger.error("В лицензии отсутствует подпись")
                return False

            # Данные для проверки подписи
            data_to_verify = json.dumps(license_data, sort_keys=True)

            # Декодируем подпись из Base64
            signature_bytes = base64.b64decode(signature)

            # Проверяем подпись
            self.public_key.verify(
                signature_bytes,
                data_to_verify.encode('utf-8'),
                padding.PKCS1v15(),
                hashes.SHA512()
            )

            # Если не возникло исключение InvalidSignature, подпись верна
            return True

        except (InvalidSignature, ValueError, TypeError) as e:
            logger.error(f"Ошибка проверки подписи лицензии: {e}")
            return False
        finally:
            # Возвращаем подпись обратно в словарь
            license_data["signature"] = signature

    def _get_features_for_license_type(self, license_type: str) -> Dict[str, Any]:
        """
        Получить набор функций для указанного типа лицензии.

        Args:
            license_type: Тип лицензии (TRIAL или PRO).

        Returns:
            Словарь с функциями, доступными для данного типа лицензии.
        """
        if license_type.upper() == "TRIAL":
            return {
                "maxUsers": 1,
                "modules": ["basic"]
            }
        elif license_type.upper() == "PRO":
            return {
                "maxUsers": 50,
                "modules": ["basic", "analytics", "reporting", "export"]
            }
        else:
            return {
                "maxUsers": 1,
                "modules": []
            }
