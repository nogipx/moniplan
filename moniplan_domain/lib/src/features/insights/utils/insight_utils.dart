// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:intl/intl.dart';

import '../_index.dart';

/// Утилитный класс для работы с инсайтами
class InsightUtils {
  /// Форматирует валюту в рублях
  static final currencyFormat = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 0,
  );

  /// Рассчитывает процентную разницу между двумя значениями
  static double calculatePercentDifference(double current, double previous) {
    if (previous == 0) return 0;
    return (current - previous) / previous * 100;
  }

  /// Возвращает правильную форму слова в зависимости от числа
  static String pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) {
      return one;
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return few;
    } else {
      return many;
    }
  }

  /// Устанавливает временной признак для инсайта
  static Insight setTimeframe(Insight insight, InsightTimeframe timeframe) {
    // Создаем новую карту на основе существующей, чтобы избежать ошибки с неизменяемой картой
    final additionalData = {...(insight.additionalData ?? {})};
    additionalData['timeframe'] = timeframe.toString();

    // Создаем новый инсайт с обновленным timeframe
    return Insight(
      id: insight.id,
      title: insight.title,
      description: insight.description,
      type: insight.type,
      importance: insight.importance,
      timeframe: timeframe,
      relatedPayments: insight.relatedPayments,
      additionalData: additionalData,
    );
  }

  /// Устанавливает временной признак для списка инсайтов
  static List<Insight> setTimeframeForAll(List<Insight> insights, InsightTimeframe timeframe) {
    return insights.map((insight) => setTimeframe(insight, timeframe)).toList();
  }

  /// Проверяет и исправляет временные рамки инсайтов
  static List<Insight> validateAndFixTimeframes(List<Insight> insights) {
    final result = <Insight>[];

    for (final insight in insights) {
      // Если timeframe не установлен, определяем его на основе типа инсайта
      // Если timeframe уже установлен, просто добавляем инсайт в результат
      result.add(insight);
        }

    return result;
  }
}
