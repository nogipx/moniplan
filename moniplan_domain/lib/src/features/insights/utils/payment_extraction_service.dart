// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Сервис для извлечения платежей из финансовых данных
class PaymentExtractionService {
  /// Извлекает оригинальные платежи из финансовых данных
  ///
  /// Этот метод пытается извлечь платежи из различных типов финансовых данных,
  /// используя полиморфизм и дополнительные данные.
  static List<Payment>? extractPayments(List<IFinancialData> operations) {
    try {
      final payments = <Payment>[];

      for (final operation in operations) {
        // Используем паттерн Visitor через метод расширения
        final payment = operation.extractPayment();
        if (payment != null) {
          payments.add(payment);
        }
      }

      return payments.isNotEmpty ? payments : null;
    } catch (e) {
      return null;
    }
  }
}

/// Расширение для извлечения платежей из финансовых данных
extension PaymentExtraction on IFinancialData {
  /// Извлекает платеж из финансовых данных
  Payment? extractPayment() {
    // Проверяем, есть ли в дополнительных данных оригинальный платеж
    if (additionalData != null && additionalData!['originalPayment'] is Payment) {
      return additionalData!['originalPayment'] as Payment;
    }

    // Для других типов данных можно добавить специфическую логику
    // Например, для MoniplanPaymentAdapter можно было бы использовать:
    // if (this is MoniplanPaymentAdapter) {
    //   return (this as MoniplanPaymentAdapter).originalPayment;
    // }

    return null;
  }
}
