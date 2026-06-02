import '../../../domain/entities/period_range.dart';
import '../../../domain/entities/timeframe.dart';

/// Synchronized period view state shared by the Transaction, Calendar, and
/// Statistic home surfaces.
///
/// Holds the active [timeframe] and the inclusive [range] currently selected.
/// A single controller drives all three surfaces so they always filter the same
/// period; the displayed all-time balance is intentionally NOT part of this
/// state because it must stay stable across period changes.
class PeriodState {
  const PeriodState({required this.timeframe, required this.range});

  /// The active period granularity (daily, weekly, monthly, yearly).
  final Timeframe timeframe;

  /// The inclusive [PeriodRange] currently selected for [timeframe].
  final PeriodRange range;

  @override
  bool operator ==(Object other) =>
      other is PeriodState &&
      other.timeframe == timeframe &&
      other.range == range;

  @override
  int get hashCode => Object.hash(timeframe, range);

  @override
  String toString() => 'PeriodState($timeframe, $range)';
}
