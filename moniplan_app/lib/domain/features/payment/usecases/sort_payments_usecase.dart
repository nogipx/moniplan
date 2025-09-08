// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_app/domain/moniplan_domain.dart';

/// Юзкейс для сортировки платежей по единому алгоритму
///
/// Порядок сортировки:
/// 1. По дате (если указано sortByDate = true)
/// 2. По типу (коррекция всегда в конце списка)
/// 3. По приоритету:
///    - Выполненные платежи (isDone == true)
///    - Выключенные платежи (isEnabled == false)
///    - Активные незавершенные платежи (isDone == false && isEnabled == true)
/// 4. По типу (доходы перед расходами)
/// 5. По сумме (от большей к меньшей)
class SortPaymentsUsecase implements IUseCase<List<Payment>> {
  final List<Payment> payments;

  const SortPaymentsUsecase({required this.payments});

  @override
  List<Payment> run() {
    final sortedPayments = List<Payment>.from(payments);

    sortedPayments.sort((a, b) {
      // Коррекция всегда в конце (после всех других платежей)
      if (a.type == PaymentType.correction && b.type != PaymentType.correction) {
        return 1; // a (коррекция) идет после b
      }
      if (a.type != PaymentType.correction && b.type == PaymentType.correction) {
        return -1; // a идет перед b (коррекция)
      }

      // Создаем приоритет для каждого платежа:
      // 1 - выполненные (isDone == true)
      // 2 - выключенные (isEnabled == false)
      // 3 - активные незавершенные (isDone == false && isEnabled == true)
      int getPriority(Payment p) {
        if (p.isDone && p.isEnabled) return 1;
        if (p.isDone && !p.isEnabled) return 2;
        if (!p.isDone && !p.isEnabled) return 3;
        if (!p.isDone && p.isEnabled) return 4;
        return 5;
      }

      final priorityA = getPriority(a);
      final priorityB = getPriority(b);

      // Сортируем по приоритету
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // Затем сортируем по типу (доходы в начале)
      if (a.type != b.type) {
        return a.type == PaymentType.income ? -1 : 1;
      }

      // Наконец, сортируем по сумме (по убыванию)
      return b.normalizedMoney.abs().compareTo(a.normalizedMoney.abs()) * -1;
    });

    return sortedPayments;
  }
}
