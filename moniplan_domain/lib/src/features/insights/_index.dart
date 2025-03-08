// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Анализаторы
export 'analyzers/_index.dart';

// Интерфейсы
export 'interfaces/i_financial_analyzer.dart';
export 'interfaces/i_financial_data.dart';
export 'interfaces/i_insight_generator.dart';
export 'interfaces/i_analyzer_factory.dart';

// Модели
export 'models/insight.dart';
export 'models/analyzer_descriptor.dart';

// Сервисы
export 'services/analyzer_factory_impl.dart';

// Утилиты
export 'utils/insight_utils.dart';
export 'utils/payment_extraction_service.dart';
