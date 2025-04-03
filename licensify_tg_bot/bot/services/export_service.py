#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import csv
import json
import tempfile
import logging
from datetime import datetime
from typing import List, Tuple, Dict, Any

from utils.models import License

logger = logging.getLogger(__name__)


def _json_serializer(obj: Any) -> Any:
    """
    Сериализатор для преобразования объектов в JSON

    Args:
        obj: Объект для сериализации

    Returns:
        Any: Сериализованный объект
    """
    if isinstance(obj, datetime):
        return obj.isoformat()
    return str(obj)


def export_licenses_to_csv(licenses: List[License]) -> Tuple[str, str]:
    """
    Экспортирует список лицензий в формат CSV

    Args:
        licenses: Список лицензий

    Returns:
        Tuple[str, str]: Путь к временному файлу и имя файла
    """
    try:
        # Создаем временный файл
        with tempfile.NamedTemporaryFile(delete=False, suffix='.csv', mode='w', newline='') as temp_file:
            temp_file_path = temp_file.name

            # Создаем CSV writer
            fieldnames = [
                'id', 'app_id', 'device_id', 'user_id', 'device_name', 'type',
                'issue_date', 'expiration_date', 'revoked', 'telegram_username'
            ]

            writer = csv.DictWriter(temp_file, fieldnames=fieldnames)
            writer.writeheader()

            # Записываем данные лицензий
            for license_obj in licenses:
                writer.writerow({
                    'id': license_obj.id,
                    'app_id': license_obj.app_id,
                    'device_id': license_obj.device_id,
                    'user_id': license_obj.user_id,
                    'device_name': license_obj.device_name,
                    'type': license_obj.type,
                    'issue_date': license_obj.metadata.issue_date if license_obj.metadata and license_obj.metadata.issue_date else '',
                    'expiration_date': license_obj.expiration_date if license_obj.expiration_date else 'Бессрочно',
                    'revoked': 'Да' if license_obj.revoked else 'Нет',
                    'telegram_username': license_obj.metadata.telegram_username if license_obj.metadata else ''
                })

            file_name = f"licenses_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
            return temp_file_path, file_name

    except Exception as e:
        logger.error(f"Error exporting licenses to CSV: {e}")
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)
        raise


def export_licenses_to_json(licenses: List[License]) -> Tuple[str, str]:
    """
    Экспортирует список лицензий в формат JSON

    Args:
        licenses: Список лицензий

    Returns:
        Tuple[str, str]: Путь к временному файлу и имя файла
    """
    try:
        # Создаем временный файл
        with tempfile.NamedTemporaryFile(delete=False, suffix='.json', mode='w') as temp_file:
            temp_file_path = temp_file.name

            # Сериализуем лицензии в список словарей
            licenses_data = []
            for license_obj in licenses:
                license_dict = {
                    'id': license_obj.id,
                    'app_id': license_obj.app_id,
                    'device_id': license_obj.device_id,
                    'user_id': license_obj.user_id,
                    'device_name': license_obj.device_name,
                    'type': license_obj.type,
                    'issue_date': license_obj.metadata.issue_date if license_obj.metadata and license_obj.metadata.issue_date else None,
                    'expiration_date': license_obj.expiration_date,
                    'revoked': license_obj.revoked,
                    'metadata': {
                        'issuer': license_obj.metadata.issuer if license_obj.metadata else None,
                        'issuer_id': license_obj.metadata.issuer_id if license_obj.metadata else None,
                        'telegram_username': license_obj.metadata.telegram_username if license_obj.metadata else None
                    },
                    'features': {
                        'premium_features': license_obj.features.premium_features if license_obj.features else False,
                        'business_features': license_obj.features.business_features if license_obj.features else False
                    }
                }
                licenses_data.append(license_dict)

            # Записываем данные в JSON файл
            json.dump(licenses_data, temp_file,
                      default=_json_serializer, indent=2)

            file_name = f"licenses_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            return temp_file_path, file_name

    except Exception as e:
        logger.error(f"Error exporting licenses to JSON: {e}")
        if os.path.exists(temp_file_path):
            os.unlink(temp_file_path)
        raise
