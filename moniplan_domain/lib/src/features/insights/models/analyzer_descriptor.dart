// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

import '../interfaces/i_financial_analyzer.dart';

part 'analyzer_descriptor.freezed.dart';
part 'analyzer_descriptor.g.dart';

/// Описание анализатора для предоставления пользователю
/// возможности выбора используемых анализаторов
@freezed
class AnalyzerDescriptor with _$AnalyzerDescriptor {
  const factory AnalyzerDescriptor({
    /// Уникальный идентификатор анализатора
    required String id,

    /// Название анализатора для отображения пользователю
    required String name,

    /// Описание анализатора
    required String description,

    /// Тип анализатора (ретроспективный, прогностический, комбинированный)
    required AnalyzerType type,

    /// Порядок отображения в списке
    @Default(0) int order,

    /// Теги для фильтрации анализаторов
    @Default([]) List<String> tags,
  }) = _AnalyzerDescriptor;

  factory AnalyzerDescriptor.fromJson(Map<String, dynamic> json) =>
      _$AnalyzerDescriptorFromJson(json);
}

/// Тип анализатора
enum AnalyzerType {
  /// Ретроспективный анализатор (анализирует прошлые данные)
  retrospective,

  /// Прогностический анализатор (анализирует будущие данные)
  predictive,

  /// Комбинированный анализатор (анализирует и прошлые, и будущие данные)
  combined,
}
