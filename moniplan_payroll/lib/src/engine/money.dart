// Money rounding fixed points (spec 5.5). Intermediate values are never
// rounded; these are applied only at the boundaries.

/// Average calendar days in a month (clause 10 of Decree 922).
const double kAvgMonthDays = 29.3;

/// Round to kopecks (2 decimals), half away from zero.
num roundKopeck(num v) => (v * 100).round() / 100;

/// Round to whole rubles (art. 52 NK), half away from zero.
num roundRuble(num v) => v.round();
