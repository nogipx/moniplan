// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Доменные сущности
export 'domain/entities/license.dart';
export 'domain/entities/license_status.dart';

// Доменные репозитории (интерфейсы)
export 'domain/repositories/i_license_directory_provider.dart';
export 'domain/repositories/i_license_repository.dart';
export 'domain/repositories/i_license_storage.dart';
export 'domain/repositories/i_license_validator.dart';

// Доменные сценарии использования
export 'domain/usecases/check_license_usecase.dart';
export 'domain/usecases/monitor_license_usecase.dart';
export 'domain/usecases/generate_license_usecase.dart';

// Реализации репозиториев
export 'data/repositories/license_repository.dart';
export 'data/repositories/license_validator.dart';

// Источники данных
export 'data/datasources/file_license_storage.dart';
export 'data/datasources/in_memory_license_storage.dart';
