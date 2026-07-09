import 'package:meta/meta.dart';

/// A single progressive bracket. [upTo] is the exclusive upper bound of the
/// annual base; null means "and above". [rate] applies to the portion inside
/// this bracket (marginal, cumulative).
@immutable
class NdflBracket {
  const NdflBracket({this.upTo, required this.rate});

  final num? upTo;
  final double rate;
}

/// A progressive NDFL scale for a given NK edition (spec 3.2).
@immutable
class NdflScale {
  const NdflScale({required this.effectiveFrom, required this.brackets});

  final DateTime effectiveFrom;

  /// Ascending by [NdflBracket.upTo]; the last bracket has upTo == null.
  final List<NdflBracket> brackets;

  /// Progressive tax on an annual base, piecewise by bracket. Not rounded.
  num taxOn(num annualBase) {
    if (annualBase <= 0) return 0;
    num tax = 0;
    num lower = 0;
    for (final b in brackets) {
      if (annualBase <= lower) break;
      final upper = b.upTo ?? double.infinity;
      final capped = annualBase < upper ? annualBase : upper;
      final portion = capped - lower;
      if (portion > 0) tax += portion * b.rate;
      lower = upper;
    }
    return tax;
  }

  /// The rate applied to the last ruble of [annualBase].
  double marginalRate(num annualBase) {
    for (final b in brackets) {
      final upper = b.upTo ?? double.infinity;
      if (annualBase <= upper) return b.rate;
    }
    return brackets.last.rate;
  }
}

/// Registry of scales; picks the one in force for a payment year.
@immutable
class NdflScaleRegistry {
  const NdflScaleRegistry(this.scales);

  /// Ascending by [NdflScale.effectiveFrom].
  final List<NdflScale> scales;

  factory NdflScaleRegistry.ru() => NdflScaleRegistry([
        // 2021 edition: 13% up to 5M, 15% above.
        NdflScale(
          effectiveFrom: DateTime(2021, 1, 1),
          brackets: const [
            NdflBracket(upTo: 5000000, rate: 0.13),
            NdflBracket(rate: 0.15),
          ],
        ),
        // In force since 2025-01-01.
        NdflScale(
          effectiveFrom: DateTime(2025, 1, 1),
          brackets: const [
            NdflBracket(upTo: 2400000, rate: 0.13),
            NdflBracket(upTo: 5000000, rate: 0.15),
            NdflBracket(upTo: 20000000, rate: 0.18),
            NdflBracket(upTo: 50000000, rate: 0.20),
            NdflBracket(rate: 0.22),
          ],
        ),
      ]);

  NdflScale scaleForYear(int year) {
    NdflScale? chosen;
    for (final s in scales) {
      if (s.effectiveFrom.year <= year) {
        chosen = s;
      }
    }
    return chosen ?? scales.first;
  }
}
