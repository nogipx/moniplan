// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

part 'insight.freezed.dart';
part 'insight.g.dart';

/// Тип инсайта, определяющий его категорию
enum InsightType {
  /// Анализ структуры расходов
  expenseStructure,

  /// Выявленный паттерн в финансовом поведении
  pattern,

  /// Прогноз или предупреждение
  forecast,

  /// Сравнение с предыдущими периодами
  comparison,

  /// Рекомендация по оптимизации
  optimization,

  /// Анализ достижения финансовых целей
  goal,

  /// Общий финансовый совет
  advice,
}

/// Уровень важности инсайта
enum InsightImportance {
  /// Информационный инсайт
  low,

  /// Полезный инсайт
  medium,

  /// Важный инсайт
  high,

  /// Критически важный инсайт
  critical,
}

/// Временной признак инсайта
enum InsightTimeframe {
  /// Ретроспективный инсайт (основан на завершенных платежах)
  retrospective,

  /// Прогностический инсайт (основан на запланированных платежах)
  predictive,

  /// Комбинированный инсайт (использует оба типа данных)
  combined,
}

/// Модель финансового инсайта
@freezed
class Insight with _$Insight {
  const factory Insight({
    /// Уникальный идентификатор инсайта
    required String id,

    /// Заголовок инсайта
    required String title,

    /// Краткое описание инсайта для списка
    required String description,

    /// Подробное описание инсайта для экрана деталей
    String? detailedDescription,

    /// Тип инсайта
    required InsightType type,

    /// Важность инсайта
    required InsightImportance importance,

    /// Временной признак инсайта
    @Default(InsightTimeframe.combined) InsightTimeframe timeframe,

    /// Связанные платежи (опционально)
    List<Payment>? relatedPayments,

    /// Дополнительные данные для отображения (опционально)
    Map<String, dynamic>? additionalData,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) => _$InsightFromJson(json);
}
