import json
import os
from datetime import datetime, timedelta, timezone
from typing import List, Dict, Optional
from pathlib import Path
import logging

from .models import License, LicenseFeatures, LicenseMetadata
from .license_config import license_config

logger = logging.getLogger(__name__)


class LicenseStore:
    def __init__(self, db_path: str):
        """
        Инициализация хранилища лицензий

        Args:
            db_path: Путь к файлу хранилища лицензий
        """
        self.db_path = db_path
        self.licenses: Dict[str, License] = {}
        self._ensure_db_exists()
        self._load_licenses()

    def _ensure_db_exists(self):
        """Проверяет наличие файла БД и создает его при необходимости"""
        db_dir = os.path.dirname(self.db_path)
        if db_dir and not os.path.exists(db_dir):
            os.makedirs(db_dir)

        if not os.path.exists(self.db_path):
            with open(self.db_path, 'w') as file:
                json.dump({}, file)

    def _load_licenses(self):
        """Загружает лицензии из файла хранилища"""
        with open(self.db_path, 'r') as file:
            try:
                licenses_data = json.load(file)
                for license_id, license_data in licenses_data.items():
                    # Преобразуем некоторые поля в соответствующие типы
                    if "creation_date" in license_data:
                        license_data["creation_date"] = datetime.fromisoformat(
                            license_data["creation_date"].replace("Z", "+00:00"))

                    if "expiration_date" in license_data and license_data["expiration_date"]:
                        license_data["expiration_date"] = datetime.fromisoformat(
                            license_data["expiration_date"].replace("Z", "+00:00"))

                    if "features" in license_data:
                        license_data["features"] = LicenseFeatures(
                            **license_data["features"])

                    if "metadata" in license_data:
                        metadata_data = license_data["metadata"]

                        # Обеспечиваем наличие нужных полей
                        if "device_hash" not in metadata_data:
                            metadata_data["device_hash"] = ""
                        if "issue_hash" not in metadata_data:
                            metadata_data["issue_hash"] = ""
                        if "telegram_username" not in metadata_data:
                            metadata_data["telegram_username"] = None

                        # Удаляем ненужные поля, если они есть
                        if "issuer" in metadata_data:
                            del metadata_data["issuer"]
                        if "issuer_id" in metadata_data:
                            del metadata_data["issuer_id"]
                        if "issue_date" in metadata_data:
                            del metadata_data["issue_date"]

                        license_data["metadata"] = LicenseMetadata(
                            **metadata_data)

                    self.licenses[license_id] = License(**license_data)
            except json.JSONDecodeError:
                # Если файл поврежден, создаем пустой словарь
                self.licenses = {}

    def _save_licenses(self):
        """Сохраняет лицензии в файл хранилища"""
        licenses_data = {}
        for license_id, license_obj in self.licenses.items():
            license_dict = license_obj.to_dict()
            # Преобразуем datetime в строки для JSON уже не нужно,
            # так как to_dict сам это делает
            licenses_data[license_id] = license_dict

        with open(self.db_path, 'w') as file:
            json.dump(licenses_data, file, indent=2)

    def add_license(self, license_obj: License) -> License:
        """
        Добавляет лицензию в хранилище

        Args:
            license_obj: Объект лицензии

        Returns:
            License: Сохраненный объект лицензии
        """
        self.licenses[license_obj.id] = license_obj
        self._save_licenses()
        return license_obj

    def get_license(self, license_id: str) -> Optional[License]:
        """
        Получает лицензию по идентификатору

        Args:
            license_id: Идентификатор лицензии

        Returns:
            Optional[License]: Объект лицензии или None, если лицензия не найдена
        """
        return self.licenses.get(license_id)

    def get_license_by_id(self, license_id: str) -> Optional[License]:
        """
        Получает лицензию по идентификатору (алиас для get_license)

        Args:
            license_id: Идентификатор лицензии

        Returns:
            Optional[License]: Объект лицензии или None, если лицензия не найдена
        """
        return self.get_license(license_id)

    def get_licenses_by_device_hash(self, device_hash: str) -> List[License]:
        """
        Получает лицензии по хешу устройства

        Args:
            device_hash: Хеш устройства

        Returns:
            List[License]: Список лицензий с указанным хешем устройства
        """
        return [
            license_obj for license_obj in self.licenses.values()
            if license_obj.metadata and license_obj.metadata.device_hash == device_hash
        ]

    def get_licenses_by_app_id(self, app_id: str) -> List[License]:
        """
        Получает лицензии по идентификатору приложения

        Args:
            app_id: Идентификатор приложения

        Returns:
            List[License]: Список лицензий для указанного приложения
        """
        return [
            license_obj for license_obj in self.licenses.values()
            if license_obj.app_id == app_id
        ]

    def get_all_licenses(self) -> List[License]:
        """
        Возвращает все лицензии из хранилища

        Returns:
            List[License]: Список всех лицензий
        """
        return list(self.licenses.values())

    def delete_license(self, license_id: str) -> bool:
        """
        Удаляет лицензию из хранилища

        Args:
            license_id: Идентификатор лицензии

        Returns:
            bool: True если лицензия успешно удалена, False если лицензия не найдена
        """
        if license_id in self.licenses:
            del self.licenses[license_id]
            self._save_licenses()
            return True
        return False

    def create_license(
        self,
        app_id: str,
        device_hash: str,
        user_hash: Optional[str] = None,
        license_type: Optional[str] = None,
        features: Optional[LicenseFeatures] = None,
        expiration_days: Optional[int] = None
    ) -> License:
        """
        Создает новую лицензию

        Args:
            app_id: Идентификатор приложения
            device_hash: Хеш устройства
            user_hash: Хеш пользователя (опционально)
            license_type: Тип лицензии (если None, будет использован первый из конфигурации)
            features: Функции, доступные по лицензии
            expiration_days: Срок действия лицензии в днях

        Returns:
            License: Созданный объект лицензии

        Raises:
            ValueError: Если переданы некорректные данные
        """
        # Если тип лицензии не указан, используем первый из конфигурации
        if license_type is None:
            license_types = license_config.get_sorted_license_types()
            if license_types:
                license_type = license_types[0].id
            else:
                # Запасной вариант, если конфигурация пуста
                license_type = "standard"

        # Проверяем обязательные поля
        if not app_id:
            raise ValueError("Идентификатор приложения не может быть пустым")
        if not device_hash:
            raise ValueError("Хеш устройства не может быть пустым")
        if license_type not in license_config.license_types:
            raise ValueError(f"Неверный тип лицензии: {license_type}")

        # Устанавливаем дату истечения, если указан срок действия
        expiration_date = None
        if expiration_days is not None:
            if expiration_days <= 0:
                raise ValueError(
                    "Срок действия лицензии должен быть положительным числом")
            # Используем UTC для установки времени истечения
            expiration_date = datetime.now(
                timezone.utc) + timedelta(days=expiration_days)

        # Если функции не указаны, создаем объект по умолчанию
        if not features:
            features = LicenseFeatures()

        # Создаем метаданные лицензии
        metadata = LicenseMetadata(
            device_hash=device_hash,
            issue_hash=user_hash if user_hash else ""
        )

        # Создаем объект лицензии
        license_obj = License(
            app_id=app_id,
            expiration_date=expiration_date,
            type=license_type,
            metadata=metadata
        )

        # Добавляем лицензию в хранилище
        self.add_license(license_obj)

        return license_obj

    def revoke_license(self, license_id: str, reason: Optional[str] = None) -> bool:
        """
        Отзывает лицензию

        Args:
            license_id: ID лицензии для отзыва
            reason: Причина отзыва (опционально)

        Returns:
            bool: True если успешно, False в случае ошибки
        """
        license_obj = self.get_license_by_id(license_id)

        if not license_obj:
            logger.warning(
                f"License with ID {license_id} not found for revocation")
            return False

        license_obj.is_active = False
        license_obj.revocation_reason = reason
        license_obj.revocation_date = datetime.now(timezone.utc)

        self.update_license(license_obj)
        return True

    def update_license(self, license_obj: License) -> None:
        """
        Обновляет лицензию в хранилище

        Args:
            license_obj: Объект лицензии
        """
        self.licenses[license_obj.id] = license_obj
        self._save_licenses()
