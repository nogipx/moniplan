import 'package:moniplan_app/core/_index.dart';

/// Сумма по метке за один месяц.
class TagMonth {
  TagMonth({
    required this.year,
    required this.month,
    required this.total,
    required this.count,
  });

  final int year;
  final int month;
  final num total;
  final int count;
}

/// Агрегат по одной метке: итог, число платежей и разбивка по месяцам.
class TagAggregate {
  TagAggregate({
    required this.tag,
    required this.total,
    required this.count,
    required this.months,
  });

  final String tag;
  final num total;
  final int count;

  /// Месяцы от недавних к старым.
  final List<TagMonth> months;
}

/// Считает суммы по пользовательским меткам с разбивкой по месяцам.
/// Метка может стоять на нескольких платежах и наоборот; платёж с двумя
/// метками попадает в оба среза (суммы срезов пересекаются).
class AggregateByTagsUseCase {
  const AggregateByTagsUseCase({required this.payments});

  final List<Payment> payments;

  List<TagAggregate> call() {
    final acc = <String, _TagAcc>{};

    for (final p in payments) {
      if (!p.isEnabled) {
        continue;
      }
      final tags = p.details.tags
          .where((t) => t.trim().isNotEmpty && !t.contains(':'));
      if (tags.isEmpty) {
        continue;
      }
      final value = p.normalizedMoney;
      final ym = p.date.year * 100 + p.date.month;

      for (final tag in tags) {
        final a = acc.putIfAbsent(tag, _TagAcc.new);
        a.total += value;
        a.count += 1;
        final m = a.months.putIfAbsent(
          ym,
          () => _MonthAcc(p.date.year, p.date.month),
        );
        m.total += value;
        m.count += 1;
      }
    }

    final result = acc.entries.map((e) {
      final months = e.value.months.values.toList()
        ..sort((a, b) =>
            (b.year * 100 + b.month).compareTo(a.year * 100 + a.month));
      return TagAggregate(
        tag: e.key,
        total: e.value.total,
        count: e.value.count,
        months: months
            .map((m) => TagMonth(
                  year: m.year,
                  month: m.month,
                  total: m.total,
                  count: m.count,
                ))
            .toList(),
      );
    }).toList()
      ..sort((a, b) => b.total.abs().compareTo(a.total.abs()));

    return result;
  }
}

class _TagAcc {
  num total = 0;
  int count = 0;
  final Map<int, _MonthAcc> months = {};
}

class _MonthAcc {
  _MonthAcc(this.year, this.month);

  final int year;
  final int month;
  num total = 0;
  int count = 0;
}
