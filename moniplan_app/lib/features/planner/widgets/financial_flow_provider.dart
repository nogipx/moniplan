// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Провайдер для сервисов финансового потока
class FinancialFlowProvider extends StatelessWidget {
  final Widget child;
  final PaymentToFinancialInstrumentAdapter? adapter;
  final FinancialFlowCalculationService? calculationService;

  const FinancialFlowProvider({
    super.key,
    required this.child,
    this.adapter,
    this.calculationService,
  });

  @override
  Widget build(BuildContext context) {
    return _FinancialFlowInheritedWidget(
      adapter: adapter ?? PaymentToFinancialInstrumentAdapter(),
      calculationService:
          calculationService ?? FinancialFlowCalculationServiceImpl(),
      child: child,
    );
  }

  /// Получение адаптера из контекста
  static PaymentToFinancialInstrumentAdapter adapterOf(BuildContext context) {
    final inherited =
        context
            .dependOnInheritedWidgetOfExactType<
              _FinancialFlowInheritedWidget
            >();
    assert(inherited != null, 'FinancialFlowProvider not found in context');
    return inherited!.adapter;
  }

  /// Получение сервиса расчета из контекста
  static FinancialFlowCalculationService calculationServiceOf(
    BuildContext context,
  ) {
    final inherited =
        context
            .dependOnInheritedWidgetOfExactType<
              _FinancialFlowInheritedWidget
            >();
    assert(inherited != null, 'FinancialFlowProvider not found in context');
    return inherited!.calculationService;
  }
}

class _FinancialFlowInheritedWidget extends InheritedWidget {
  final PaymentToFinancialInstrumentAdapter adapter;
  final FinancialFlowCalculationService calculationService;

  const _FinancialFlowInheritedWidget({
    required this.adapter,
    required this.calculationService,
    required super.child,
  });

  @override
  bool updateShouldNotify(_FinancialFlowInheritedWidget oldWidget) {
    return adapter != oldWidget.adapter ||
        calculationService != oldWidget.calculationService;
  }
}
