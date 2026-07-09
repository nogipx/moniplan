import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Поиск платежей по названию и меткам с суммой найденного.
/// Возвращает выбранный платёж — планер прыгает к его дате.
class PaymentSearchDelegate extends SearchDelegate<Payment?> {
  PaymentSearchDelegate({required this.payments})
      : super(searchFieldLabel: 'Поиск по названию или метке');

  final List<Payment> payments;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const SizedBox.shrink();
    }

    final matches = payments
        .where((p) =>
            p.details.name.toLowerCase().contains(q) ||
            p.details.tags.any((t) => t.toLowerCase().contains(q)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (matches.isEmpty) {
      return Center(
        child: Text('Ничего не найдено', style: context.text.bodyMedium),
      );
    }

    final total = matches.fold<num>(0, (s, p) => s + p.normalizedMoney);
    final df = DateFormat('d MMM y', 'ru');
    final now = DateTime.now();
    final todayDay = DateTime(now.year, now.month, now.day);
    final monthFmt = DateFormat('LLLL y', 'ru');

    // Группировка по месяцам, порядок — от недавних к старым (как matches).
    final groups = <String, List<Payment>>{};
    for (final p in matches) {
      final key = '${p.date.year}-${p.date.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(p);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s16,
            vertical: AppSpace.s12,
          ),
          color: context.color.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Найдено: ${matches.length}',
                      style: context.text.bodyMedium),
                  MoneyColoredWidget(
                    value: total,
                    currency: CurrencyDataCommon.rub,
                    textStyle: context.text.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s8),
              Row(
                children: [
                  Opacity(
                    opacity: 0.45,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _legendDot(context.color.onSurfaceVariant),
                        Text(' прошлое', style: context.text.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _legendDot(context.color.primaryContainer),
                  Text(' сегодня', style: context.text.bodySmall),
                  const SizedBox(width: 12),
                  _legendDot(context.color.tertiaryContainer),
                  Text(' будущее', style: context.text.bodySmall),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final entry in groups.entries) ...[
                _monthHeader(
                  context,
                  entry.value.first.date,
                  monthFmt,
                  entry.value,
                ),
                for (final p in entry.value)
                  _paymentTile(context, p, todayDay, df),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthHeader(
    BuildContext context,
    DateTime date,
    DateFormat fmt,
    List<Payment> items,
  ) {
    final subtotal = items.fold<num>(0, (s, p) => s + p.normalizedMoney);
    final label = fmt.format(date);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s16,
        vertical: AppSpace.s8,
      ),
      color: context.color.surfaceContainerLow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.isEmpty
                ? label
                : '${label[0].toUpperCase()}${label.substring(1)}',
            style: context.text.labelLarge
                ?.copyWith(color: context.color.onSurfaceVariant),
          ),
          MoneyColoredWidget(
            value: subtotal,
            currency: CurrencyDataCommon.rub,
            textStyle:
                context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(
    BuildContext context,
    Payment p,
    DateTime todayDay,
    DateFormat df,
  ) {
    final d = DateTime(p.date.year, p.date.month, p.date.day);
    final isPast = d.isBefore(todayDay);
    final isToday = d.isAtSameMomentAs(todayDay);

    final tile = ListTile(
      // Прошлое — без фона (приглушаем всю плитку прозрачностью).
      // Сегодня — primaryContainer, будущее — tertiaryContainer (разные тона).
      tileColor: isToday
          ? context.color.primaryContainer.withValues(alpha: 0.55)
          : (isPast
              ? null
              : context.color.tertiaryContainer.withValues(alpha: 0.45)),
      title: Text(p.details.name),
      subtitle: Text(df.format(p.date)),
      trailing: MoneyColoredWidget(
        value: p.normalizedMoney,
        currency: CurrencyDataCommon.rub,
        textStyle: context.text.bodyMedium,
      ),
      onTap: () => close(context, p),
    );
    return isPast ? Opacity(opacity: 0.45, child: tile) : tile;
  }

  Widget _legendDot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
