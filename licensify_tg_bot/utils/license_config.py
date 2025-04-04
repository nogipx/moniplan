#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
from typing import Dict, List, Any, Optional
import logging
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)

# Путь к файлу конфигурации лицензий по умолчанию
DEFAULT_CONFIG_PATH = Path(__file__).parent.parent / 'data/license_types.json'


@dataclass
class LicenseTypeConfig:
    """Конфигурация типа лицензии"""
    id: str
    name: str
    description: str = ""
    features: Dict[str, bool] = field(default_factory=dict)
    order: int = 0

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'LicenseTypeConfig':
        return cls(
            id=data.get('id', ''),
            name=data.get('name', ''),
            description=data.get('description', ''),
            features=data.get('features', {}),
            order=data.get('order', 0)
        )


@dataclass
class DurationConfig:
    """Конфигурация длительности лицензии"""
    id: str
    name: str
    days: Optional[int] = None  # None означает бессрочную лицензию
    order: int = 0

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'DurationConfig':
        return cls(
            id=data.get('id', ''),
            name=data.get('name', ''),
            days=data.get('days'),
            order=data.get('order', 0)
        )


class LicenseConfig:
    """Конфигурация типов лицензий и длительностей"""

    def __init__(self, config_path: Optional[str] = None):
        self.config_path = config_path or os.environ.get(
            'LICENSE_CONFIG_PATH', str(DEFAULT_CONFIG_PATH))
        self.license_types: Dict[str, LicenseTypeConfig] = {}
        self.durations: Dict[str, DurationConfig] = {}
        self.load_config()

    def load_config(self) -> None:
        """Загружает конфигурацию из JSON файла"""
        try:
            config_path = Path(self.config_path)

            # Создаем каталог, если его нет
            os.makedirs(config_path.parent, exist_ok=True)

            # Если файл не существует, создаем с дефолтными значениями
            if not config_path.exists():
                logger.warning(
                    f"Файл конфигурации не найден: {self.config_path}. Создаем с дефолтными значениями.")
                self._create_default_config()
                return

            with open(self.config_path, 'r', encoding='utf-8') as f:
                config_data = json.load(f)

            # Загружаем типы лицензий
            license_types_data = config_data.get('license_types', [])
            for lt_data in license_types_data:
                license_type = LicenseTypeConfig.from_dict(lt_data)
                self.license_types[license_type.id] = license_type

            # Загружаем длительности
            durations_data = config_data.get('durations', [])
            for dur_data in durations_data:
                duration = DurationConfig.from_dict(dur_data)
                self.durations[duration.id] = duration

            logger.info(
                f"Загружено {len(self.license_types)} типов лицензий и {len(self.durations)} вариантов длительности")

        except Exception as e:
            logger.error(f"Ошибка при загрузке конфигурации лицензий: {e}")
            self._create_default_config()

    def _create_default_config(self) -> None:
        """Создает дефолтную конфигурацию и сохраняет в файл"""
        # Дефолтные типы лицензий
        self.license_types = {
            "standard": LicenseTypeConfig(
                id="standard",
                name="Стандартная",
                description="Базовая лицензия с основным функционалом",
                features={
                    "premium_features": False,
                    "business_features": False
                },
                order=1
            ),
            "premium": LicenseTypeConfig(
                id="premium",
                name="Премиум",
                description="Расширенная лицензия с дополнительными возможностями",
                features={
                    "premium_features": True,
                    "business_features": False
                },
                order=2
            ),
            "business": LicenseTypeConfig(
                id="business",
                name="Бизнес",
                description="Полный доступ ко всем функциям",
                features={
                    "premium_features": True,
                    "business_features": True
                },
                order=3
            )
        }

        # Дефолтные варианты длительности
        self.durations = {
            "30": DurationConfig(
                id="30",
                name="1 месяц",
                days=30,
                order=1
            ),
            "180": DurationConfig(
                id="180",
                name="6 месяцев",
                days=180,
                order=2
            ),
            "365": DurationConfig(
                id="365",
                name="1 год",
                days=365,
                order=3
            ),
            "unlimited": DurationConfig(
                id="unlimited",
                name="Бессрочно",
                days=None,
                order=4
            )
        }

        # Сохраняем дефолтную конфигурацию
        self.save_config()

    def save_config(self) -> None:
        """Сохраняет текущую конфигурацию в файл"""
        try:
            config_data = {
                "license_types": [
                    {
                        "id": lt.id,
                        "name": lt.name,
                        "description": lt.description,
                        "features": lt.features,
                        "order": lt.order
                    } for lt in sorted(self.license_types.values(), key=lambda x: x.order)
                ],
                "durations": [
                    {
                        "id": d.id,
                        "name": d.name,
                        "days": d.days,
                        "order": d.order
                    } for d in sorted(self.durations.values(), key=lambda x: x.order)
                ]
            }

            with open(self.config_path, 'w', encoding='utf-8') as f:
                json.dump(config_data, f, ensure_ascii=False, indent=2)

            logger.info(
                f"Конфигурация лицензий сохранена в {self.config_path}")

        except Exception as e:
            logger.error(f"Ошибка при сохранении конфигурации лицензий: {e}")

    def get_sorted_license_types(self) -> List[LicenseTypeConfig]:
        """Возвращает отсортированный список типов лицензий"""
        return sorted(self.license_types.values(), key=lambda x: x.order)

    def get_sorted_durations(self) -> List[DurationConfig]:
        """Возвращает отсортированный список длительностей"""
        return sorted(self.durations.values(), key=lambda x: x.order)

    def get_license_type(self, type_id: str) -> Optional[LicenseTypeConfig]:
        """Возвращает конфигурацию типа лицензии по ID"""
        return self.license_types.get(type_id)

    def get_duration(self, duration_id: str) -> Optional[DurationConfig]:
        """Возвращает конфигурацию длительности по ID"""
        return self.durations.get(duration_id)


# Глобальный экземпляр конфигурации
license_config = LicenseConfig()
