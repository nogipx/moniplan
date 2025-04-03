import os
import logging
from typing import List, Dict, Optional, Set, ClassVar, Any
from pydantic_settings import BaseSettings
from pydantic import Field, model_validator
from pathlib import Path
from dataclasses import dataclass, field
from functools import lru_cache
from dotenv import load_dotenv

# Путь к .env файлу
ENV_FILE_PATH = Path(__file__).parent.parent / '.env'

# Загружаем переменные окружения из .env файла
load_dotenv(ENV_FILE_PATH)


def parse_admin_ids() -> List[int]:
    """Парсит список ID администраторов из переменных окружения"""
    admin_ids_str = os.environ.get('ADMIN_IDS', '')
    admin_ids = []
    if admin_ids_str:
        admin_ids = [int(id_str) for id_str in admin_ids_str.split(',')
                     if id_str.strip().isdigit()]
    return admin_ids


@dataclass
class Settings:
    # Пути к ключам
    private_key_path: str = os.environ.get(
        'PRIVATE_KEY_PATH', 'keys/private.key')
    public_key_path: str = os.environ.get(
        'PUBLIC_KEY_PATH', 'keys/public.key')

    # Telegram
    bot_token: str = os.environ.get('BOT_TOKEN', '')
    admin_ids: List[int] = field(default_factory=parse_admin_ids)

    # Webhook настройки
    webhook_url: Optional[str] = os.environ.get('WEBHOOK_URL', None)
    webhook_port: Optional[int] = int(os.environ.get(
        'WEBHOOK_PORT', '8443')) if os.environ.get('WEBHOOK_PORT') else None
    webhook_path: Optional[str] = os.environ.get('WEBHOOK_PATH', '/webhook')

    # Пути к базе данных и временным файлам
    license_db_path: str = os.environ.get(
        'LICENSE_DB_PATH', 'data/licenses.sqlite')
    temp_dir: str = os.environ.get('TEMP_DIR', '/tmp')

    # Путь к CLI утилите licensify (по умолчанию считаем, что она в PATH)
    licensify_path: str = os.environ.get('LICENSIFY_PATH', 'licensify')

    # Срок действия запроса лицензии (в часах)
    license_request_expiration_hours: int = int(
        os.environ.get('LICENSE_REQUEST_EXPIRATION_HOURS', '24'))

    # Префикс для имени файла лицензии
    license_file_prefix: str = os.environ.get('LICENSE_FILE_PREFIX', 'license')

    # Формат даты для отображения в сообщениях
    date_format: str = os.environ.get('DATE_FORMAT', '%d.%m.%Y %H:%M')

    # Уровень логирования
    log_level: str = os.environ.get('LOG_LEVEL', 'INFO')

    def is_admin(self, user_id: int) -> bool:
        """
        Проверяет, является ли пользователь администратором

        Args:
            user_id: Идентификатор пользователя Telegram

        Returns:
            bool: True если пользователь является администратором
        """
        return user_id in self.admin_ids


# Создаем глобальный экземпляр настроек
settings = Settings()

# Настраиваем логирование
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=getattr(logging, settings.log_level)
)
