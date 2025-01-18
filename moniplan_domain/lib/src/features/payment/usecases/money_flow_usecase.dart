// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:moniplan_domain/moniplan_domain.dart';

/// Вычисляет денежный поток для набора платежей.
/// Не зависит от генерации планера.
/// Может быть использован для любого списка платежей.
class MoneyFlowUseCase implements IUseCase<MoneyFlowUseCaseResult> {
  final num initialBudget;
  final Iterable<Payment> payments;

  const MoneyFlowUseCase({
    this.payments = const [],
    this.initialBudget = 0,
  });

  @override
  MoneyFlowUseCaseResult run() {
    num totalIncome = 0;
    num totalOutcome = 0;
    num balance = initialBudget;

    for (var e in payments) {
      if (!e.isEnabled) {
        continue;
      }
      if (e.type == PaymentType.income) {
        totalIncome += e.normalizedMoney;
      } else if (e.type == PaymentType.expense) {
        totalOutcome += e.normalizedMoney;
      }
      balance += e.normalizedMoney;
    }

    return MoneyFlowUseCaseResult(
      totalIncome: totalIncome,
      totalOutcome: totalOutcome,
      balance: balance,
      initialBalance: initialBudget,
    );
  }
}

class MoneyFlowUseCaseResult {
  final num totalIncome;
  final num totalOutcome;
  final num balance;
  final num initialBalance;

  const MoneyFlowUseCaseResult({
    this.totalIncome = 0,
    this.totalOutcome = 0,
    this.balance = 0,
    this.initialBalance = 0,
  });
}
