import os
import json
import sqlite3
import logging
from datetime import datetime
from typing import List, Optional, Dict, Any

from models import User, License, Device

logger = logging.getLogger(__name__)


class Database:
    """Класс для работы с SQLite базой данных."""

    def __init__(self, db_path: str):
        self.db_path = db_path
        self.conn = None
        self.cursor = None

        # Создаем директорию для базы данных, если её нет
        os.makedirs(os.path.dirname(db_path), exist_ok=True)

    async def initialize(self):
        """Инициализация базы данных."""
        try:
            self.conn = sqlite3.connect(self.db_path)
            self.cursor = self.conn.cursor()

            # Создаем таблицы, если они не существуют
            self._create_tables()

            logger.info(f"База данных инициализирована: {self.db_path}")
        except Exception as e:
            logger.error(f"Ошибка инициализации базы данных: {e}")
            raise

    def _create_tables(self):
        """Создание таблиц в базе данных."""
        # Таблица пользователей
        self.cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            user_id INTEGER PRIMARY KEY,
            username TEXT,
            full_name TEXT,
            created_at TEXT
        )
        ''')

        # Таблица лицензий
        self.cursor.execute('''
        CREATE TABLE IF NOT EXISTS licenses (
            id TEXT PRIMARY KEY,
            user_id INTEGER,
            type TEXT,
            created_at TEXT,
            expiration_date TEXT,
            owner_name TEXT,
            FOREIGN KEY (user_id) REFERENCES users (user_id)
        )
        ''')

        # Таблица устройств
        self.cursor.execute('''
        CREATE TABLE IF NOT EXISTS devices (
            device_id TEXT PRIMARY KEY,
            user_id INTEGER,
            name TEXT,
            model TEXT,
            activated_at TEXT,
            FOREIGN KEY (user_id) REFERENCES users (user_id)
        )
        ''')

        self.conn.commit()

    def _close(self):
        """Закрытие соединения с базой данных."""
        if self.conn:
            self.conn.close()
            self.conn = None
            self.cursor = None

    # Методы для работы с пользователями
    async def get_user(self, user_id: int) -> Optional[User]:
        """Получить пользователя по ID."""
        self.cursor.execute(
            "SELECT user_id, username, full_name, created_at FROM users WHERE user_id = ?",
            (user_id,)
        )
        row = self.cursor.fetchone()

        if not row:
            return None

        return User(
            user_id=row[0],
            username=row[1],
            full_name=row[2],
            created_at=datetime.fromisoformat(row[3])
        )

    async def create_user(self, user_id: int, username: str, full_name: str) -> User:
        """Создать нового пользователя."""
        now = datetime.now().isoformat()

        self.cursor.execute(
            "INSERT INTO users (user_id, username, full_name, created_at) VALUES (?, ?, ?, ?)",
            (user_id, username, full_name, now)
        )
        self.conn.commit()

        return User(
            user_id=user_id,
            username=username,
            full_name=full_name,
            created_at=datetime.fromisoformat(now)
        )

    async def update_user(self, user: User) -> None:
        """Обновить данные пользователя."""
        self.cursor.execute(
            "UPDATE users SET username = ?, full_name = ? WHERE user_id = ?",
            (user.username, user.full_name, user.user_id)
        )
        self.conn.commit()

    # Методы для работы с лицензиями
    async def get_active_license(self, user_id: int) -> Optional[License]:
        """Получить активную лицензию пользователя."""
        now = datetime.now().isoformat()

        self.cursor.execute(
            "SELECT id, user_id, type, created_at, expiration_date, owner_name "
            "FROM licenses "
            "WHERE user_id = ? AND expiration_date > ? "
            "ORDER BY expiration_date DESC LIMIT 1",
            (user_id, now)
        )

        row = self.cursor.fetchone()

        if not row:
            return None

        return License(
            id=row[0],
            user_id=row[1],
            type=row[2],
            created_at=datetime.fromisoformat(row[3]),
            expiration_date=datetime.fromisoformat(row[4]),
            owner_name=row[5]
        )

    async def has_used_trial(self, user_id: int) -> bool:
        """Проверить, использовал ли пользователь пробную лицензию."""
        self.cursor.execute(
            "SELECT COUNT(*) FROM licenses WHERE user_id = ? AND type = 'TRIAL'",
            (user_id,)
        )

        count = self.cursor.fetchone()[0]
        return count > 0

    async def add_license(self, license: License) -> None:
        """Добавить новую лицензию."""
        self.cursor.execute(
            "INSERT INTO licenses (id, user_id, type, created_at, expiration_date, owner_name) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (
                license.id,
                license.user_id,
                license.type,
                license.created_at.isoformat(),
                license.expiration_date.isoformat(),
                license.owner_name
            )
        )
        self.conn.commit()

    async def get_license_by_id(self, license_id: str) -> Optional[License]:
        """Получить лицензию по ID."""
        self.cursor.execute(
            "SELECT id, user_id, type, created_at, expiration_date, owner_name "
            "FROM licenses "
            "WHERE id = ?",
            (license_id,)
        )

        row = self.cursor.fetchone()

        if not row:
            return None

        return License(
            id=row[0],
            user_id=row[1],
            type=row[2],
            created_at=datetime.fromisoformat(row[3]),
            expiration_date=datetime.fromisoformat(row[4]),
            owner_name=row[5]
        )

    # Методы для работы с устройствами
    async def add_device(self, device: Device) -> None:
        """Добавить новое устройство."""
        self.cursor.execute(
            "INSERT INTO devices (device_id, user_id, name, model, activated_at) "
            "VALUES (?, ?, ?, ?, ?)",
            (
                device.device_id,
                device.user_id,
                device.name,
                device.model,
                device.activated_at.isoformat()
            )
        )
        self.conn.commit()

    async def get_user_devices(self, user_id: int) -> List[Device]:
        """Получить список устройств пользователя."""
        self.cursor.execute(
            "SELECT device_id, user_id, name, model, activated_at "
            "FROM devices "
            "WHERE user_id = ? "
            "ORDER BY activated_at DESC",
            (user_id,)
        )

        rows = self.cursor.fetchall()

        devices = []
        for row in rows:
            devices.append(Device(
                device_id=row[0],
                user_id=row[1],
                name=row[2],
                model=row[3],
                activated_at=datetime.fromisoformat(row[4])
            ))

        return devices

    async def get_device(self, device_id: str) -> Optional[Device]:
        """Получить устройство по ID."""
        self.cursor.execute(
            "SELECT device_id, user_id, name, model, activated_at "
            "FROM devices "
            "WHERE device_id = ?",
            (device_id,)
        )

        row = self.cursor.fetchone()

        if not row:
            return None

        return Device(
            device_id=row[0],
            user_id=row[1],
            name=row[2],
            model=row[3],
            activated_at=datetime.fromisoformat(row[4])
        )
