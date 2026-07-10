import 'package:flutter_test/flutter_test.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/tags/usecases/aggregate_by_tags_usecase.dart';

Payment _p({
  required DateTime date,
  required num money,
  required Set<String> tags,
}) =>
    Payment(
      paymentId: '${date.day}-$money-${tags.join()}',
      date: date,
      details: PaymentDetails(
        name: 't',
        type: PaymentType.expense,
        currency: CurrencyDataCommon.rub,
        money: money,
        tags: tags,
      ),
    );

void main() {
  final payments = [
    _p(date: DateTime(2026, 3, 10), money: 5000, tags: {'даша'}),
    _p(date: DateTime(2026, 4, 15), money: 3000, tags: {'даша'}),
    _p(date: DateTime(2026, 3, 20), money: 2000, tags: {'гена'}),
    _p(date: DateTime(2026, 3, 25), money: 1000, tags: {'даша', 'подарок'}),
    _p(date: DateTime(2026, 3, 1), money: 9999, tags: {}), // untagged, ignored
    _p(date: DateTime(2026, 3, 2), money: 100, tags: {'import:x:1'}), // system
  ];

  test('aggregates by tag, sorted by absolute total', () {
    final res = AggregateByTagsUseCase(payments: payments).call();

    expect(res.map((a) => a.tag).toList(), ['даша', 'гена', 'подарок']);

    final dasha = res.first;
    expect(dasha.total, -9000); // 5000 + 3000 + 1000, as expenses
    expect(dasha.count, 3);
    // Months recent-first: April then March.
    expect(dasha.months.map((m) => m.month).toList(), [4, 3]);
    expect(dasha.months[0].total, -3000); // April
    expect(dasha.months[1].total, -6000); // March: 5000 + 1000
    expect(dasha.months[1].count, 2);
  });

  test('a payment with two tags counts in both slices', () {
    final res = AggregateByTagsUseCase(payments: payments).call();
    final podarok = res.firstWhere((a) => a.tag == 'подарок');
    expect(podarok.total, -1000);
    expect(podarok.count, 1);
  });

  test('untagged and system-tagged payments are ignored', () {
    final res = AggregateByTagsUseCase(payments: payments).call();
    expect(res.any((a) => a.tag.contains(':')), isFalse);
    // Only даша, гена, подарок.
    expect(res.length, 3);
  });
}
