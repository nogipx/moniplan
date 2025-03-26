from datetime import datetime
from typing import Optional, List


class User:
    """Модель пользователя."""

    def __init__(self,
                 user_id: int,
                 username: Optional[str] = None,
                 full_name: Optional[str] = None,
                 created_at: datetime = None):
        self.user_id = user_id
        self.username = username
        self.full_name = full_name
        self.created_at = created_at or datetime.now()


class License:
    """Модель лицензии."""

    def __init__(self,
                 id: str,
                 user_id: int,
                 type: str,  # "TRIAL" или "PRO"
                 created_at: datetime,
                 expiration_date: datetime,
                 owner_name: Optional[str] = None):
        self.id = id
        self.user_id = user_id
        self.type = type
        self.created_at = created_at
        self.expiration_date = expiration_date
        self.owner_name = owner_name

    @property
    def is_active(self) -> bool:
        """Проверяет, активна ли лицензия."""
        return datetime.now() < self.expiration_date

    @property
    def days_left(self) -> int:
        """Возвращает количество дней до истечения лицензии."""
        if not self.is_active:
            return 0
        delta = self.expiration_date - datetime.now()
        return max(0, delta.days)


class Device:
    """Модель устройства."""

    def __init__(self,
                 user_id: int,
                 device_id: str,
                 name: str,
                 model: str,
                 activated_at: datetime):
        self.user_id = user_id
        self.device_id = device_id
        self.name = name
        self.model = model
        self.activated_at = activated_at
