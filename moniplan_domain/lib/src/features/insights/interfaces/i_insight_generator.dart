// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Интерфейс для генератора финансовых инсайтов
abstract class IInsightGenerator {
  /// Генерирует список всех инсайтов на основе данных планировщика
  ///
  /// [planner] - планировщик, для которого генерируются инсайты
  Future<List<Insight>> generateInsights(Planner planner);

  /// Генерирует только ретроспективные инсайты (на основе завершенных платежей)
  ///
  /// [planner] - планировщик, для которого генерируются инсайты
  Future<List<Insight>> generateRetrospectiveInsights(Planner planner);

  /// Генерирует только прогностические инсайты (на основе запланированных платежей)
  ///
  /// [planner] - планировщик, для которого генерируются инсайты
  Future<List<Insight>> generatePredictiveInsights(Planner planner);

  /// Генерирует только комбинированные инсайты (использующие оба типа данных)
  ///
  /// [planner] - планировщик, для которого генерируются инсайты
  Future<List<Insight>> generateCombinedInsights(Planner planner);

  /// Генерирует инсайты, связанные с ежедневным анализом
  ///
  /// [planner] - планировщик, для которого генерируются инсайты
  Future<List<Insight>> generateDailyInsights(Planner planner);
}
