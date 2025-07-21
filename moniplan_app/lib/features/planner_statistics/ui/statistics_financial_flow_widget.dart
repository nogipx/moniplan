// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/widgets/advanced_financial_flow_widget.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Виджет для отображения анализа финансового потока на экране статистики
class StatisticsFinancialFlowWidget extends StatelessWidget {
  final String plannerId;

  const StatisticsFinancialFlowWidget({super.key, required this.plannerId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Planner?>(
      future: _loadPlanner(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка анализа финансового потока...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ошибка при загрузке планировщика',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final planner = snapshot.data;
        if (planner == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Планировщик не найден',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return AdvancedFinancialFlowWidget(planner: planner);
      },
    );
  }

  Future<Planner?> _loadPlanner() async {
    try {
      final plannerRepo = AppDi.instance.getPlannerRepo();

      // Получаем планировщик с платежами
      final planner = await plannerRepo.getPlannerById(
        plannerId,
        withActualInfo: false,
      );
      if (planner == null) return null;

      // Получаем платежи
      final payments = await plannerRepo.getPaymentsByPlannerId(
        plannerId: plannerId,
      );

      // Возвращаем планировщик с платежами
      return planner.copyWith(payments: payments);
    } catch (e) {
      rethrow;
    }
  }
}
