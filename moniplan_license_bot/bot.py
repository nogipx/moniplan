import logging
import os
from datetime import datetime, timedelta

from aiogram import Bot, Dispatcher, Router, types
from aiogram.filters import Command
from aiogram.types import Message, InlineKeyboardMarkup, InlineKeyboardButton, CallbackQuery
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.fsm.storage.memory import MemoryStorage
from dotenv import load_dotenv

from models import License, User, Device
from license_service import LicenseService
from database import Database
from utils import load_messages, generate_activation_code

# Загрузка переменных окружения
load_dotenv()

# Настройка логирования
logging.basicConfig(level=getattr(logging, os.getenv('LOG_LEVEL', 'INFO')),
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Инициализация бота
BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')
if not BOT_TOKEN:
    raise ValueError(
        "Не указан токен бота. Установите TELEGRAM_BOT_TOKEN в файле .env")

# Настройки для лицензий
TRIAL_DURATION = int(os.getenv('TRIAL_DURATION_DAYS', 60))
PRO_DURATION = int(os.getenv('PRO_DURATION_DAYS', 365))
PRO_LICENSE_PRICE = int(os.getenv('PRO_LICENSE_PRICE', 4990))

# Инициализация служб
bot = Bot(token=BOT_TOKEN)
dp = Dispatcher(storage=MemoryStorage())
router = Router()
db = Database(os.getenv('DATABASE_PATH', './data/moniplan_licenses.db'))
license_service = LicenseService(
    private_key_path=os.getenv('PRIVATE_KEY_PATH'),
    public_key_path=os.getenv('PUBLIC_KEY_PATH')
)

# Загрузка текстовых сообщений
messages = load_messages()

# Состояния для FSM


class LicenseStates(StatesGroup):
    waiting_for_activation_code = State()
    waiting_for_payment = State()


# Обработчики команд
@router.message(Command("start"))
async def cmd_start(message: Message):
    """Обработка команды /start."""
    user_id = message.from_user.id
    user = await db.get_user(user_id)

    if not user:
        await db.create_user(user_id, message.from_user.username, message.from_user.full_name)

    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="📋 Доступные лицензии",
                              callback_data="show_licenses")],
        [InlineKeyboardButton(text="🔑 Активировать устройство",
                              callback_data="activate_device")],
        [InlineKeyboardButton(text="📱 Мои устройства",
                              callback_data="my_devices")],
        [InlineKeyboardButton(text="❓ Справка", callback_data="help")]
    ])

    await message.answer(messages["welcome"], reply_markup=keyboard)


@router.message(Command("license"))
async def cmd_license(message: Message):
    """Обработка команды /license."""
    user_id = message.from_user.id
    user = await db.get_user(user_id)

    # Проверяем, есть ли у пользователя активная лицензия
    active_license = await db.get_active_license(user_id)

    # Проверяем, использовал ли пользователь пробную лицензию
    trial_used = await db.has_used_trial(user_id)

    keyboard = []

    if not active_license:
        if not trial_used:
            keyboard.append([InlineKeyboardButton(text="⭐ Активировать TRIAL (бесплатно)",
                                                  callback_data="activate_trial")])

        keyboard.append([InlineKeyboardButton(text="💎 Купить PRO (4990₽/год)",
                                              callback_data="buy_pro")])
    else:
        expiry_date = active_license.expiration_date.strftime("%d.%m.%Y")
        await message.answer(
            f"У тебя уже есть активная лицензия {active_license.type} до {expiry_date}."
        )
        return

    keyboard.append([InlineKeyboardButton(
        text="◀️ Назад", callback_data="back_to_main")])
    reply_markup = InlineKeyboardMarkup(inline_keyboard=keyboard)

    await message.answer(messages["license_info"], reply_markup=reply_markup)


@router.message(Command("activate"))
async def cmd_activate(message: Message, state: FSMContext):
    """Обработка команды /activate."""
    user_id = message.from_user.id

    # Проверяем, есть ли у пользователя активная лицензия
    active_license = await db.get_active_license(user_id)

    if not active_license:
        await message.answer(
            "У тебя нет активной лицензии. Сначала получи TRIAL или купи PRO лицензию."
        )
        return

    await message.answer(messages["activation_request"])
    await state.set_state(LicenseStates.waiting_for_activation_code)


@router.message(Command("devices"))
async def cmd_devices(message: Message):
    """Обработка команды /devices."""
    user_id = message.from_user.id

    # Получаем список устройств пользователя
    devices = await db.get_user_devices(user_id)

    if not devices:
        await message.answer("У тебя еще нет активированных устройств.")
        return

    # Формируем сообщение со списком устройств
    devices_text = messages["devices_list"]

    for i, device in enumerate(devices, 1):
        activation_date = device.activated_at.strftime("%d.%m.%Y")
        devices_text += f"\n{i}. {device.name} — активировано {activation_date}"

    active_license = await db.get_active_license(user_id)

    if active_license:
        expiry_date = active_license.expiration_date.strftime("%d.%m.%Y")
        devices_text += f"\n\nВсего активировано: {len(devices)} устройств"
        devices_text += f"\nТип лицензии: {active_license.type}"
        devices_text += f"\nСрок действия: до {expiry_date}"

    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(
            text="🔑 Активировать еще устройство", callback_data="activate_device")],
        [InlineKeyboardButton(text="◀️ Назад", callback_data="back_to_main")]
    ])

    await message.answer(devices_text, reply_markup=keyboard)


@router.message(Command("help"))
async def cmd_help(message: Message):
    """Обработка команды /help."""
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="◀️ Назад", callback_data="back_to_main")]
    ])

    await message.answer(messages["help"], reply_markup=keyboard)


# Обработчики состояний
@router.message(LicenseStates.waiting_for_activation_code)
async def process_activation_code(message: Message, state: FSMContext):
    """Обработка кода активации от пользователя."""
    user_id = message.from_user.id
    activation_code = message.text.strip()

    # Проверяем валидность кода активации
    try:
        # Здесь должна быть логика проверки и декодирования кода активации
        device_info = license_service.decode_activation_request(
            activation_code)

        # Получаем активную лицензию пользователя
        active_license = await db.get_active_license(user_id)

        if not active_license:
            await message.answer("У тебя нет активной лицензии. Пожалуйста, получи TRIAL или купи PRO лицензию.")
            await state.clear()
            return

        # Создаем запись об устройстве
        device = Device(
            user_id=user_id,
            device_id=device_info["device_id"],
            name=device_info["device_name"],
            model=device_info["device_model"],
            activated_at=datetime.now()
        )

        await db.add_device(device)

        # Генерируем лицензию для устройства
        license_file = license_service.generate_license_file(
            license_id=active_license.id,
            app_id="com.moniplan.app",
            license_type=active_license.type,
            expiration_date=active_license.expiration_date,
            created_at=datetime.now(),
            device_id=device_info["device_id"],
            client_name=active_license.owner_name
        )

        # Отправляем файл лицензии пользователю
        await message.answer(messages["license_generated"].format(
            device_model=device_info["device_model"],
            license_type=active_license.type,
            expiration_date=active_license.expiration_date.strftime("%d.%m.%Y")
        ))

        # Создаем временный файл лицензии и отправляем его
        license_file_path = f"temp_{user_id}_license.json"
        with open(license_file_path, "w") as f:
            f.write(license_file)

        with open(license_file_path, "rb") as f:
            await bot.send_document(
                user_id,
                types.BufferedInputFile(
                    f.read(),
                    filename=f"moniplan_license_{active_license.type.lower()}_{datetime.now().strftime('%Y%m%d')}.license"
                ),
                caption="📄 Вот твой файл лицензии. Импортируй его в приложение MoniPlan."
            )

        # Удаляем временный файл
        os.remove(license_file_path)

        # Отправляем инструкцию по импорту
        keyboard = InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="📱 Мои устройства",
                                  callback_data="my_devices")],
            [InlineKeyboardButton(text="◀️ Назад в меню",
                                  callback_data="back_to_main")]
        ])

        await message.answer(messages["import_instructions"], reply_markup=keyboard)

    except Exception as e:
        logger.error(f"Ошибка обработки кода активации: {e}")
        await message.answer(
            "❌ Не удалось обработать код активации. Убедись, что ты отправил правильный код."
        )

    finally:
        await state.clear()


# Обработчики callback-запросов
@router.callback_query(lambda c: c.data == "show_licenses")
async def show_licenses(callback_query: CallbackQuery):
    """Показать информацию о доступных лицензиях."""
    await callback_query.answer()
    await cmd_license(callback_query.message)


@router.callback_query(lambda c: c.data == "activate_device")
async def activate_device(callback_query: CallbackQuery, state: FSMContext):
    """Активировать новое устройство."""
    await callback_query.answer()
    await cmd_activate(callback_query.message, state)


@router.callback_query(lambda c: c.data == "my_devices")
async def my_devices(callback_query: CallbackQuery):
    """Показать список устройств пользователя."""
    await callback_query.answer()
    await cmd_devices(callback_query.message)


@router.callback_query(lambda c: c.data == "help")
async def show_help(callback_query: CallbackQuery):
    """Показать справку."""
    await callback_query.answer()
    await cmd_help(callback_query.message)


@router.callback_query(lambda c: c.data == "back_to_main")
async def back_to_main(callback_query: CallbackQuery):
    """Вернуться в главное меню."""
    await callback_query.answer()
    await cmd_start(callback_query.message)


@router.callback_query(lambda c: c.data == "activate_trial")
async def activate_trial(callback_query: CallbackQuery):
    """Активировать TRIAL лицензию."""
    await callback_query.answer()
    user_id = callback_query.from_user.id

    # Проверяем, не использовал ли пользователь уже пробную лицензию
    if await db.has_used_trial(user_id):
        await callback_query.message.answer(
            "Ты уже использовал пробную лицензию. Она доступна только один раз."
        )
        return

    # Получаем данные пользователя
    user = await db.get_user(user_id)

    # Создаем TRIAL лицензию
    expiration_date = datetime.now() + timedelta(days=TRIAL_DURATION)
    license_id = generate_activation_code(8)  # Генерируем уникальный ID

    new_license = License(
        id=license_id,
        user_id=user_id,
        type="TRIAL",
        created_at=datetime.now(),
        expiration_date=expiration_date,
        owner_name=user.full_name
    )

    await db.add_license(new_license)

    # Уведомляем пользователя
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🔑 Активировать устройство",
                              callback_data="activate_device")],
        [InlineKeyboardButton(text="◀️ Назад", callback_data="back_to_main")]
    ])

    await callback_query.message.answer(
        messages["trial_activated"].format(
            expiration_date=expiration_date.strftime("%d.%m.%Y")
        ),
        reply_markup=keyboard
    )


@router.callback_query(lambda c: c.data == "buy_pro")
async def buy_pro(callback_query: CallbackQuery, state: FSMContext):
    """Купить PRO лицензию."""
    await callback_query.answer()

    provider_token = os.getenv("PROVIDER_TOKEN")
    if not provider_token:
        await callback_query.message.answer(
            "❌ Оплата временно недоступна. Пожалуйста, попробуйте позже."
        )
        return

    # Создаем счет на оплату
    prices = [
        types.LabeledPrice(label="MoniPlan PRO (1 год)",
                           amount=PRO_LICENSE_PRICE * 100)  # в копейках
    ]

    # Сохраняем информацию о текущем счете
    await state.set_state(LicenseStates.waiting_for_payment)

    # Отправляем счет пользователю
    await bot.send_invoice(
        chat_id=callback_query.message.chat.id,
        title="MoniPlan PRO Лицензия",
        description="Годовая PRO лицензия MoniPlan с полным доступом ко всем функциям",
        payload="pro_license",
        provider_token=provider_token,
        currency="RUB",
        prices=prices,
        start_parameter="moniplan_pro",
        need_name=True,
        need_email=True
    )


# Обработчик успешных платежей
@router.pre_checkout_query()
async def process_pre_checkout_query(pre_checkout_query: types.PreCheckoutQuery):
    """Обработка пре-чекаут запроса."""
    await bot.answer_pre_checkout_query(pre_checkout_query.id, ok=True)


@router.message(lambda message: message.successful_payment)
async def process_successful_payment(message: Message):
    """Обработка успешного платежа."""
    user_id = message.from_user.id
    payment_info = message.successful_payment

    # Получаем данные пользователя
    user = await db.get_user(user_id)

    # Обновляем имя пользователя, если он предоставил его при оплате
    if payment_info.order_info and payment_info.order_info.name:
        user.full_name = payment_info.order_info.name
        await db.update_user(user)

    # Создаем PRO лицензию
    expiration_date = datetime.now() + timedelta(days=PRO_DURATION)
    license_id = generate_activation_code(8)  # Генерируем уникальный ID

    new_license = License(
        id=license_id,
        user_id=user_id,
        type="PRO",
        created_at=datetime.now(),
        expiration_date=expiration_date,
        owner_name=user.full_name
    )

    await db.add_license(new_license)

    # Уведомляем пользователя
    keyboard = InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🔑 Активировать устройство",
                              callback_data="activate_device")],
        [InlineKeyboardButton(text="◀️ Назад", callback_data="back_to_main")]
    ])

    await message.answer(
        messages["payment_successful"].format(
            expiration_date=expiration_date.strftime("%d.%m.%Y")
        ),
        reply_markup=keyboard
    )


# Регистрация обработчиков
dp.include_router(router)


# Основная функция запуска бота
async def main():
    # Инициализация базы данных
    await db.initialize()

    # Запуск бота
    await dp.start_polling(bot)


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
