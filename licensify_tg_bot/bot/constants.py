#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Уровни разговора для ConversationHandler
AWAITING_REQUEST_FILE = 0
AWAITING_CONFIRMATION = 1
AWAITING_LICENSE_TYPE = 2
AWAITING_LICENSE_DURATION = 3
AWAITING_SEARCH_PARAM = 4
AWAITING_SEARCH_TERM = 5
AWAITING_EXPORT_FORMAT = 6

# Константы для меню администратора
ADMIN_MENU = "admin_menu"
ADMIN_MENU_LICENSES = "admin_menu_licenses"
ADMIN_MENU_STATISTICS = "admin_menu_statistics"
ADMIN_MENU_EXPORT = "admin_menu_export"
ADMIN_MENU_BACK = "admin_menu_back"

# Константы для поиска
SEARCH_BY_APP = "search_by_app"
SEARCH_BY_DEVICE = "search_by_device"
SEARCH_BY_TYPE = "search_by_type"
SEARCH_BY_ID = "search_by_id"

# Константы для экспорта и очистки
EXPORT_CSV = "export_csv"
EXPORT_JSON = "export_json"
CLEANUP_EXPIRED = "cleanup_expired"

# Типы лицензий
LICENSE_TYPE_STANDARD = "standard"
LICENSE_TYPE_PREMIUM = "premium"
LICENSE_TYPE_BUSINESS = "business"

# Сроки действия лицензий (в днях)
LICENSE_DURATION_30 = 30
LICENSE_DURATION_180 = 180
LICENSE_DURATION_365 = 365
