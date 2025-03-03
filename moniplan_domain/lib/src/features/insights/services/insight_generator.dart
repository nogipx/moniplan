// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/src/features/insights/models/_index.dart';
import 'package:moniplan_domain/src/features/payment/models/planner/planner.dart';

/// Интерфейс для генератора финансовых инсайтов
abstract class InsightGenerator {
  /// Генерирует список инсайтов на основе данных планировщика
  ///
  /// [planner] - планировщик, для которого генерируются инсайты
  /// [limit] - максимальное количество инсайтов (по умолчанию 5)
  Future<List<Insight>> generateInsights(Planner planner, {int limit = 5});
}
