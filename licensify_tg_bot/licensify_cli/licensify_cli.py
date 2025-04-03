#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import logging
import os
import subprocess
import tempfile
from datetime import datetime
from typing import Dict, Optional, Tuple, Union

from utils.config import settings

logger = logging.getLogger(__name__)


class LicensifyCLI:
    """
    Полная интеграция с утилитой licensify CLI
    Предоставляет интерфейс для всех команд CLI инструмента
    """

    def __init__(self, cli_path: Optional[str] = None, private_key_path: Optional[str] = None, public_key_path: Optional[str] = None):
        """
        Инициализирует интеграцию с CLI

        Args:
            cli_path: Путь к бинарному файлу licensify CLI
            private_key_path: Путь к приватному ключу (опционально)
            public_key_path: Путь к публичному ключу (опционально)
        """
        self.cli_path = cli_path or settings.licensify_path
        self.private_key_path = private_key_path
        self.public_key_path = public_key_path

        # Проверяем наличие CLI утилиты
        try:
            version = self.get_version()
            logger.info(f"Licensify CLI версия: {version}")
        except Exception as e:
            logger.error(f"Ошибка при проверке Licensify CLI: {e}")
            raise RuntimeError(
                f"Не удалось инициализировать Licensify CLI: {e}")

    def get_version(self) -> str:
        """Получает версию Licensify CLI"""
        try:
            result = self._run_command(["--version"])
            return result.strip()
        except Exception as e:
            logger.error(f"Ошибка при получении версии: {e}")
            return "Неизвестная версия"

    def _run_command(self, args: list) -> str:
        """
        Запускает команду licensify CLI с указанными аргументами

        Args:
            args: Список аргументов для licensify CLI

        Returns:
            str: Вывод команды

        Raises:
            Exception: Если произошла ошибка выполнения команды
        """
        cmd = [self.cli_path] + args
        logger.debug(f"Выполняю команду: {' '.join(cmd)}")

        try:
            process = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=True
            )

            if not process.stdout.strip():
                logger.warning(
                    f"Команда вернула пустой результат: {' '.join(cmd)}")
                logger.warning(f"Stderr: {process.stderr}")

            return process.stdout

        except subprocess.CalledProcessError as e:
            error = e.stderr.strip() if e.stderr else "Неизвестная ошибка"
            logger.error(f"Ошибка выполнения licensify: {error}")
            logger.error(f"Команда: {' '.join(cmd)}")
            logger.error(f"Stdout: {e.stdout}")
            logger.error(f"Stderr: {e.stderr}")
            logger.error(f"Return code: {e.returncode}")
            raise Exception(f"Ошибка выполнения licensify: {error}")
        except FileNotFoundError:
            error_msg = f"Утилита licensify не найдена. Проверьте путь: {self.cli_path}"
            logger.error(error_msg)
            raise Exception(error_msg)

    def generate_key_pair(self, output_dir: str, name: str = "app") -> Tuple[str, str]:
        """
        Генерирует пару ключей (приватный и публичный)

        Args:
            output_dir: Директория для сохранения ключей
            name: Префикс имени файлов ключей

        Returns:
            Tuple[str, str]: Пути к приватному и публичному ключам
        """
        try:
            # Проверяем существование директории, создаем если нужно
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)

            cmd_args = [
                "keygen",
                "--output", output_dir,
                "--name", name
            ]

            result = self._run_command(cmd_args)
            logger.info(f"Сгенерированы ключи: {result}")

            # Формируем пути к сгенерированным ключам
            private_key_path = os.path.join(output_dir, f"{name}.private.pem")
            public_key_path = os.path.join(output_dir, f"{name}.public.pem")

            # Проверяем, что файлы были созданы
            if not os.path.exists(private_key_path) or not os.path.exists(public_key_path):
                raise FileNotFoundError(
                    "Не удалось найти сгенерированные ключи")

            return private_key_path, public_key_path
        except Exception as e:
            logger.error(f"Ошибка при генерации ключей: {e}")
            raise

    def create_license_request(self, app_id: str, public_key: str,
                               device_id: Optional[str] = None,
                               valid_hours: int = 48,
                               output_path: Optional[str] = None) -> Tuple[bytes, str]:
        """
        Создает запрос на лицензию

        Args:
            app_id: Идентификатор приложения
            public_key: Путь к публичному ключу или содержимое
            device_id: Идентификатор устройства (опционально)
            valid_hours: Время действия запроса в часах
            output_path: Путь для сохранения запроса

        Returns:
            Tuple[bytes, str]: Бинарные данные запроса и путь к файлу
        """
        try:
            # Создаем временный файл для публичного ключа, если передана строка
            temp_pubkey_path = None
            if not os.path.exists(public_key):
                with tempfile.NamedTemporaryFile(delete=False, suffix='.pem', mode='w') as pubkey_file:
                    pubkey_file.write(public_key)
                    temp_pubkey_path = pubkey_file.name
                    public_key = temp_pubkey_path

            # Если путь для сохранения не задан, используем временный
            if not output_path:
                with tempfile.NamedTemporaryFile(delete=False, suffix='.mlr') as temp_file:
                    output_path = temp_file.name

            cmd_args = [
                "request",
                "--appId", app_id,
                "--publicKey", public_key,
                "--validHours", str(valid_hours),
                "--output", output_path
            ]

            # Добавляем deviceId, если он задан
            if device_id:
                cmd_args.extend(["--deviceId", device_id])

            result = self._run_command(cmd_args)
            logger.info(f"Создан запрос лицензии: {result}")

            # Читаем файл запроса
            with open(output_path, 'rb') as request_file:
                request_data = request_file.read()

            return request_data, output_path

        except Exception as e:
            logger.error(f"Ошибка при создании запроса: {e}")
            raise
        finally:
            # Удаляем временный файл ключа, если он был создан
            if temp_pubkey_path and os.path.exists(temp_pubkey_path):
                try:
                    os.unlink(temp_pubkey_path)
                except Exception as e:
                    logger.warning(
                        f"Не удалось удалить временный файл ключа: {e}")

    def decrypt_license_request(self, request_data: Union[bytes, str], private_key: Optional[str] = None) -> dict:
        """
        Расшифровывает запрос лицензии

        Args:
            request_data: Бинарные данные запроса или путь к файлу
            private_key: Путь к приватному ключу (по умолчанию из self.private_key_path)

        Returns:
            dict: Данные запроса
        """
        temp_file_path = None

        try:
            # Используем заданный приватный ключ или из инстанса
            if not private_key:
                if not self.private_key_path:
                    raise ValueError("Не указан путь к приватному ключу")
                private_key = self.private_key_path

            # Если передан путь к файлу запроса
            if isinstance(request_data, str) and os.path.exists(request_data):
                request_file_path = request_data
            else:
                # Создаем временный файл для запроса
                with tempfile.NamedTemporaryFile(delete=False, suffix='.mlr') as temp_file:
                    if isinstance(request_data, str):
                        temp_file.write(request_data.encode('utf-8'))
                    else:
                        temp_file.write(request_data)
                    temp_file_path = temp_file.name
                    request_file_path = temp_file_path

            cmd_args = [
                "decrypt-request",
                "--requestFile", request_file_path,
                "--privateKey", private_key
            ]

            result = self._run_command(cmd_args)

            # Парсим вывод команды
            request_data = self._parse_request_output(result)
            return request_data

        except Exception as e:
            logger.error(f"Ошибка при расшифровке запроса: {e}")
            raise
        finally:
            # Удаляем временный файл, если он был создан
            if temp_file_path and os.path.exists(temp_file_path):
                try:
                    os.unlink(temp_file_path)
                except Exception as e:
                    logger.warning(f"Не удалось удалить временный файл: {e}")

    def _parse_request_output(self, output: str) -> dict:
        """
        Парсит текстовый вывод команды decrypt-request

        Args:
            output: Текстовый вывод команды

        Returns:
            dict: Структура с данными запроса
        """
        # Создаем структуру для результата
        request_data = {
            "appId": "",
            "deviceHash": "",
            "createdAt": None,
            "expiresAt": None,
            "isExpired": False,
            "userId": "",
            "deviceName": ""
        }

        # Парсим строки вывода
        lines = output.strip().split('\n')
        for line in lines:
            line = line.strip()
            logger.debug(f"Парсинг строки: {line}")

            if "App ID:" in line:
                request_data["appId"] = line.split("App ID:")[1].strip()
            elif "Device hash:" in line:
                request_data["deviceHash"] = line.split("Device hash:")[
                    1].strip()
            elif "Created:" in line:
                created_str = line.split("Created:")[1].strip()
                try:
                    # Проверяем формат даты
                    if 'Z' in created_str:
                        created_str = created_str.replace('Z', '+00:00')
                    request_data["createdAt"] = datetime.fromisoformat(
                        created_str)
                except ValueError:
                    logger.warning(
                        f"Не удалось распарсить дату создания: {created_str}")
            elif "Expires:" in line:
                expires_str = line.split("Expires:")[1].strip()
                try:
                    # Проверяем формат даты
                    if 'Z' in expires_str:
                        expires_str = expires_str.replace('Z', '+00:00')
                    request_data["expiresAt"] = datetime.fromisoformat(
                        expires_str)
                except ValueError:
                    logger.warning(
                        f"Не удалось распарсить дату истечения: {expires_str}")
            elif "User ID:" in line:
                request_data["userId"] = line.split("User ID:")[1].strip()
            elif "Device name:" in line:
                request_data["deviceName"] = line.split("Device name:")[
                    1].strip()
            elif "WARNING: This request has already expired" in line:
                request_data["isExpired"] = True

        # Если не указана информация об истечении срока, определяем по датам
        if not request_data["isExpired"] and request_data["expiresAt"]:
            now = datetime.now()
            expires_at = request_data["expiresAt"]

            # Проверяем, является ли expiresAt с информацией о временной зоне
            if hasattr(expires_at, 'tzinfo') and expires_at.tzinfo is not None:
                # Делаем now тоже с часовым поясом
                from datetime import timezone
                now = datetime.now(timezone.utc)

            request_data["isExpired"] = expires_at < now

        return request_data

    def generate_license(self, app_id: str,
                         expiration_date: Union[str, datetime],
                         license_type: str = "standard",
                         features: Optional[Dict[str, str]] = None,
                         metadata: Optional[Dict[str, str]] = None,
                         private_key: Optional[str] = None,
                         output_path: Optional[str] = None) -> Tuple[Dict, str]:
        """
        Создает новую лицензию напрямую (без запроса)

        Args:
            app_id: Идентификатор приложения
            expiration_date: Дата истечения лицензии (YYYY-MM-DD или объект datetime)
            license_type: Тип лицензии (trial, standard, pro)
            features: Словарь функций лицензии (ключ=значение)
            metadata: Словарь метаданных лицензии (ключ=значение)
            private_key: Путь к приватному ключу (по умолчанию из self.private_key_path)
            output_path: Путь для сохранения лицензии

        Returns:
            Tuple[Dict, str]: Данные лицензии и путь к файлу
        """
        try:
            # Используем заданный приватный ключ или из инстанса
            if not private_key:
                if not self.private_key_path:
                    raise ValueError("Не указан путь к приватному ключу")
                private_key = self.private_key_path

            # Если путь для сохранения не задан, используем временный
            if not output_path:
                with tempfile.NamedTemporaryFile(delete=False, suffix='.licensify') as temp_file:
                    output_path = temp_file.name

            # Преобразуем дату в строку если нужно
            if isinstance(expiration_date, datetime):
                expiration_str = expiration_date.strftime("%Y-%m-%d")
            else:
                expiration_str = expiration_date

            cmd_args = [
                "generate",
                "--privateKey", private_key,
                "--appId", app_id,
                "--expiration", expiration_str,
                "--type", license_type,
                "--output", output_path
            ]

            # Добавляем features, если они заданы
            if features:
                for key, value in features.items():
                    cmd_args.extend(["--features", f"{key}={value}"])

            # Добавляем metadata, если они заданы
            if metadata:
                for key, value in metadata.items():
                    cmd_args.extend(["--metadata", f"{key}={value}"])

            result = self._run_command(cmd_args)
            logger.info(f"Создана лицензия: {result}")

            # Читаем файл лицензии и парсим его содержимое
            license_data = self._read_license_file(output_path)

            return license_data, output_path

        except Exception as e:
            logger.error(f"Ошибка при создании лицензии: {e}")
            raise

    def respond_to_request(self, request_data: Union[bytes, str],
                           expiration_date: Union[str, datetime],
                           license_type: str = "standard",
                           features: Optional[Dict[str, str]] = None,
                           metadata: Optional[Dict[str, str]] = None,
                           private_key: Optional[str] = None,
                           output_path: Optional[str] = None) -> Tuple[Dict, str]:
        """
        Создает лицензию на основе запроса

        Args:
            request_data: Бинарные данные запроса или путь к файлу
            expiration_date: Дата истечения лицензии (YYYY-MM-DD или объект datetime)
            license_type: Тип лицензии (trial, standard, pro)
            features: Словарь функций лицензии (ключ=значение)
            metadata: Словарь метаданных лицензии (ключ=значение)
            private_key: Путь к приватному ключу (по умолчанию из self.private_key_path)
            output_path: Путь для сохранения лицензии

        Returns:
            Tuple[Dict, str]: Данные лицензии и путь к файлу
        """
        temp_file_path = None

        try:
            # Используем заданный приватный ключ или из инстанса
            if not private_key:
                if not self.private_key_path:
                    raise ValueError("Не указан путь к приватному ключу")
                private_key = self.private_key_path

            # Если передан путь к файлу запроса
            if isinstance(request_data, str) and os.path.exists(request_data):
                request_file_path = request_data
            else:
                # Создаем временный файл для запроса
                with tempfile.NamedTemporaryFile(delete=False, suffix='.mlr') as temp_file:
                    if isinstance(request_data, str):
                        temp_file.write(request_data.encode('utf-8'))
                    else:
                        temp_file.write(request_data)
                    temp_file_path = temp_file.name
                    request_file_path = temp_file_path

            # Если путь для сохранения не задан, используем временный
            if not output_path:
                with tempfile.NamedTemporaryFile(delete=False, suffix='.licensify') as temp_file:
                    output_path = temp_file.name

            # Преобразуем дату в строку если нужно
            if isinstance(expiration_date, datetime):
                expiration_str = expiration_date.strftime("%Y-%m-%d")
            else:
                expiration_str = expiration_date

            cmd_args = [
                "respond",
                "--requestFile", request_file_path,
                "--privateKey", private_key,
                "--expiration", expiration_str,
                "--type", license_type,
                "--output", output_path
            ]

            # Добавляем features, если они заданы
            if features:
                for key, value in features.items():
                    cmd_args.extend(["--features", f"{key}={value}"])

            # Добавляем metadata, если они заданы
            if metadata:
                for key, value in metadata.items():
                    cmd_args.extend(["--metadata", f"{key}={value}"])

            result = self._run_command(cmd_args)
            logger.info(f"Создана лицензия по запросу: {result}")

            # Читаем файл лицензии и парсим его содержимое
            license_data = self._read_license_file(output_path)

            return license_data, output_path

        except Exception as e:
            logger.error(f"Ошибка при создании лицензии по запросу: {e}")
            raise
        finally:
            # Удаляем временный файл, если он был создан
            if temp_file_path and os.path.exists(temp_file_path):
                try:
                    os.unlink(temp_file_path)
                except Exception as e:
                    logger.warning(f"Не удалось удалить временный файл: {e}")

    def verify_license(self, license_data: Union[Dict, bytes, str],
                       public_key: Optional[str] = None) -> Tuple[bool, dict]:
        """
        Проверяет лицензию

        Args:
            license_data: Данные лицензии (словарь, бинарные данные или путь к файлу)
            public_key: Путь к публичному ключу (по умолчанию из self.public_key_path)

        Returns:
            Tuple[bool, dict]: Результат проверки (True/False) и данные о проверке
        """
        temp_file_path = None

        try:
            # Используем заданный публичный ключ или из инстанса
            if not public_key:
                if not self.public_key_path:
                    raise ValueError("Не указан путь к публичному ключу")
                public_key = self.public_key_path

            # Если передан путь к файлу лицензии
            if isinstance(license_data, str) and os.path.exists(license_data):
                license_file_path = license_data
            else:
                # Создаем временный файл для лицензии
                with tempfile.NamedTemporaryFile(delete=False, suffix='.licensify') as temp_file:
                    if isinstance(license_data, dict):
                        json.dump(license_data, temp_file,
                                  ensure_ascii=False, indent=2)
                    elif isinstance(license_data, str):
                        temp_file.write(license_data.encode('utf-8'))
                    else:
                        temp_file.write(license_data)
                    temp_file_path = temp_file.name
                    license_file_path = temp_file_path

            cmd_args = [
                "verify",
                "--license", license_file_path,
                "--publicKey", public_key
            ]

            result = self._run_command(cmd_args)

            # Парсим результат проверки
            is_valid = "License is valid" in result or "Лицензия действительна" in result
            verification_data = self._parse_verification_output(result)

            return is_valid, verification_data

        except Exception as e:
            logger.error(f"Ошибка при проверке лицензии: {e}")
            return False, {"error": str(e)}
        finally:
            # Удаляем временный файл, если он был создан
            if temp_file_path and os.path.exists(temp_file_path):
                try:
                    os.unlink(temp_file_path)
                except Exception as e:
                    logger.warning(f"Не удалось удалить временный файл: {e}")

    def _parse_verification_output(self, output: str) -> dict:
        """
        Парсит вывод команды verify

        Args:
            output: Текстовый вывод команды

        Returns:
            dict: Структура с данными о проверке
        """
        verification_data = {
            "isValid": False,
            "isExpired": False,
            "expirationDate": None,
            "remainingDays": 0,
            "message": ""
        }

        lines = output.strip().split('\n')
        for line in lines:
            line = line.strip()

            if "License is valid" in line or "Лицензия действительна" in line:
                verification_data["isValid"] = True
            elif "Warning: License has expired" in line or "Предупреждение: Срок лицензии истек" in line:
                verification_data["isExpired"] = True
            elif "License is valid until" in line or "Лицензия действительна до" in line:
                # Пытаемся извлечь дату
                parts = line.split("until")
                if len(parts) > 1:
                    date_str = parts[1].strip()
                    try:
                        if 'Z' in date_str:
                            date_str = date_str.replace('Z', '+00:00')
                        # Обрабатываем разные форматы даты
                        try:
                            verification_data["expirationDate"] = datetime.fromisoformat(
                                date_str)
                        except ValueError:
                            # Пробуем другой формат
                            verification_data["expirationDate"] = datetime.strptime(
                                date_str, "%Y-%m-%d")
                    except ValueError:
                        logger.warning(
                            f"Не удалось распарсить дату истечения: {date_str}")
            elif "Remaining days:" in line or "Осталось дней:" in line:
                # Извлекаем количество оставшихся дней
                parts = line.split(":")
                if len(parts) > 1:
                    try:
                        verification_data["remainingDays"] = int(
                            parts[1].strip())
                    except ValueError:
                        logger.warning(
                            f"Не удалось распарсить количество оставшихся дней: {parts[1]}")

        # Формируем сообщение
        if verification_data["isValid"]:
            if verification_data["isExpired"]:
                verification_data["message"] = "Лицензия просрочена"
            else:
                verification_data[
                    "message"] = f"Лицензия действительна, осталось дней: {verification_data['remainingDays']}"
        else:
            verification_data["message"] = "Недействительная лицензия"

        return verification_data

    def _read_license_file(self, file_path: str) -> Dict:
        """
        Читает и возвращает содержимое файла лицензии

        Args:
            file_path: Путь к файлу лицензии

        Returns:
            Dict: Данные лицензии
        """
        try:
            with open(file_path, 'rb') as license_file:
                license_bytes = license_file.read()

            # Пытаемся разобрать как JSON (если лицензия не в бинарном формате)
            try:
                license_data = json.loads(license_bytes)
            except json.JSONDecodeError:
                # Если не удалось парсить как JSON, возвращаем базовую структуру
                license_data = {
                    "id": "unknown",
                    "appId": "unknown",
                    "type": "unknown",
                    # показываем только начало hex-представления
                    "raw_data": license_bytes.hex()[:32] + "..."
                }

            return license_data

        except Exception as e:
            logger.error(f"Ошибка при чтении файла лицензии: {e}")
            return {"error": str(e)}
