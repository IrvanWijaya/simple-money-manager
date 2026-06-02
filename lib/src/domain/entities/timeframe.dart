import 'period_range.dart';

/// The period granularity used to filter and summarize transactions.
///
/// Previous/next navigation and period boundaries are derived from the selected
/// timeframe. Weekly periods run Sunday through Saturday.
enum Timeframe {
  daily,
  weekly,
  monthly,
  yearly;

  /// The inclusive [PeriodRange] that [instant] falls into for this timeframe.
  PeriodRange rangeFor(DateTime instant) =>
      PeriodRange.forTimeframe(this, instant);
}
