// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_domain/src/features/payment/models/payment/payment.dart';

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

/// Модель финансового инсайта
@freezed
class Insight with _$Insight {
  const factory Insight({
    /// Уникальный идентификатор инсайта
    required String id,

    /// Заголовок инсайта
    required String title,

    /// Подробное описание инсайта
    required String description,

    /// Тип инсайта
    required InsightType type,

    /// Важность инсайта
    required InsightImportance importance,

    /// Связанные платежи (опционально)
    List<Payment>? relatedPayments,

    /// Дополнительные данные для отображения (опционально)
    Map<String, dynamic>? additionalData,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) => _$InsightFromJson(json);
}
