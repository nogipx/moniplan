#!/usr/bin/env python
# -*- coding: utf-8 -*-

import uuid
import json
from typing import List, Dict, Optional, Any
from datetime import datetime, timedelta, timezone
from dataclasses import dataclass, field, asdict


@dataclass
class LicenseFeatures:
    """
    Функциональные возможности лицензии
    """
    premium_features: bool = False
    business_features: bool = False
    custom_features: Dict[str, bool] = field(default_factory=dict)

    def __getattr__(self, name: str) -> Any:
        """
        Позволяет получать значения динамических фич через точечную нотацию
        Например: features.some_custom_feature

        Args:
            name: Имя атрибута

        Returns:
            Any: Значение атрибута или False, если атрибут не найден
        """
        if name in self.custom_features:
            return self.custom_features[name]
        return False

    def __setattr__(self, name: str, value: Any) -> None:
        """
        Позволяет устанавливать значения динамических фич через точечную нотацию
        Например: features.some_custom_feature = True

        Args:
            name: Имя атрибута
            value: Значение атрибута
        """
        # Если это стандартное поле класса, обрабатываем обычным способом
        if name in ['premium_features', 'business_features', 'custom_features']:
            super().__setattr__(name, value)
        else:
            # Иначе добавляем в custom_features
            if not hasattr(self, 'custom_features'):
                self.custom_features = {}
            self.custom_features[name] = value


@dataclass
class LicenseMetadata:
    """
    Метаданные лицензии
    """
    device_hash: str = ""
    issue_hash: str = ""
    telegram_username: Optional[str] = None


@dataclass
class LicenseRequest:
    """
    Запрос на создание лицензии
    """
    app_id: str
    device_id: str
    user_id: str = ""
    device_name: str = ""
    timestamp: Optional[datetime] = None

    def __post_init__(self):
        # Устанавливаем timestamp при создании объекта, если он не был передан
        if self.timestamp is None:
            self.timestamp = datetime.now(timezone.utc)

    def is_expired(self) -> bool:
        """
        Проверяет, истек ли срок действия запроса
        По умолчанию запрос считается действительным 24 часа

        Returns:
            bool: True если запрос истек
        """
        if self.timestamp is None:
            return False

        # Гарантируем, что используем timezone-aware datetime
        now = datetime.now(timezone.utc)
        ts = self.timestamp

        if ts.tzinfo is None:
            ts = ts.replace(tzinfo=timezone.utc)

        expiry_duration = timedelta(hours=24)  # Типичный срок действия запроса
        return now - ts > expiry_duration


@dataclass
class License:
    """
    Лицензия приложения
    """
    id: str
    app_id: str
    device_id: str
    user_id: str
    device_name: str
    type: str  # standard, premium, business
    features: LicenseFeatures = field(default_factory=LicenseFeatures)
    metadata: Optional[LicenseMetadata] = None
    expiration_date: Optional[datetime] = None
    revoked: bool = False

    def __post_init__(self):
        # Если id не передан, генерируем новый UUID
        if not self.id:
            self.id = str(uuid.uuid4())

        # Если metadata не передан, создаем пустой объект
        if self.metadata is None:
            self.metadata = LicenseMetadata()

    def is_expired(self) -> bool:
        """
        Проверяет, истек ли срок действия лицензии

        Returns:
            bool: True если срок действия истек, False в противном случае или для бессрочной лицензии
        """
        if self.expiration_date is None:
            return False  # Бессрочная лицензия

        # Гарантируем, что используем timezone-aware datetime
        now = datetime.now(timezone.utc)
        exp_date = self.expiration_date

        if exp_date.tzinfo is None:
            exp_date = exp_date.replace(tzinfo=timezone.utc)

        return now > exp_date

    def is_active(self) -> bool:
        """
        Проверяет, активна ли лицензия (не истекла и не отозвана)

        Returns:
            bool: True если лицензия активна
        """
        return not self.revoked and not self.is_expired()

    def to_dict(self) -> Dict[str, Any]:
        """
        Преобразует объект в словарь

        Returns:
            Dict[str, Any]: Словарь с данными объекта
        """
        result = asdict(self)

        # Преобразуем даты в строки
        if self.expiration_date:
            # Гарантируем наличие timezone
            exp_date = self.expiration_date
            if exp_date.tzinfo is None:
                exp_date = exp_date.replace(tzinfo=timezone.utc)
            result['expiration_date'] = exp_date.isoformat()

        return result

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'License':
        """
        Создает объект из словаря

        Args:
            data: Словарь с данными

        Returns:
            License: Объект лицензии
        """
        # Копируем словарь, чтобы не изменять оригинал
        data_copy = data.copy()

        # Преобразуем строки в даты с поддержкой часовых поясов
        if 'expiration_date' in data_copy and data_copy['expiration_date']:
            dt = datetime.fromisoformat(data_copy['expiration_date'])
            # Если в строке не было информации о timezone, добавляем UTC
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            data_copy['expiration_date'] = dt

        # Создаем объекты вложенных классов
        if 'features' in data_copy:
            features_data = data_copy.pop('features')
            data_copy['features'] = LicenseFeatures(**features_data)

        if 'metadata' in data_copy:
            metadata_data = data_copy.pop('metadata')
            data_copy['metadata'] = LicenseMetadata(**metadata_data)

        return cls(**data_copy)
