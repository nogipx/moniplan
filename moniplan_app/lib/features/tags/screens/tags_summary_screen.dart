import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/features/planner/planner_bloc/_index.dart';
import 'package:moniplan_app/features/tags/usecases/aggregate_by_tags_usecase.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Экран «По меткам» — суммы по каждой метке с разбивкой по месяцам.
/// Требует PlannerBloc в контексте.
class TagsSummaryScreen extends StatelessWidget {
  const TagsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monthFmt = DateFormat('LLLL y', 'ru');
    return Scaffold(
      appBar: AppBar(title: const Text('По меткам')),
      body: SafeArea(
        child: BlocBuilder<PlannerBloc, PlannerState>(
          builder: (context, state) {
            final aggregates =
                AggregateByTagsUseCase(payments: state.getPayments).call();

            if (aggregates.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.s24),
                  child: Text(
                    'Пока нет меток. Добавь метки платежам '
                    '(в редакторе платежа) — здесь появятся суммы по каждой.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.color.onSurfaceVariant),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.s8),
              itemCount: aggregates.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final agg = aggregates[i];
                return ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          agg.tag,
                          style: context.text.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      MoneyColoredWidget(
                        value: agg.total,
                        currency: CurrencyDataCommon.rub,
                        textStyle: context.text.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${agg.count} платежей',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.color.onSurfaceVariant),
                  ),
                  childrenPadding: const EdgeInsets.only(
                    left: AppSpace.s16,
                    right: AppSpace.s16,
                    bottom: AppSpace.s12,
                  ),
                  children: [
                    for (final m in agg.months)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _capitalize(
                                monthFmt.format(DateTime(m.year, m.month)),
                              ),
                              style: context.text.bodyMedium,
                            ),
                            MoneyColoredWidget(
                              value: m.total,
                              currency: CurrencyDataCommon.rub,
                              textStyle: context.text.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
