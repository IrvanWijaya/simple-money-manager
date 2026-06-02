import 'timeframe.dart';

/// An inclusive date-time range for a single period of a [Timeframe].
///
/// Boundaries are deterministic and inclusive on both ends:
/// [start] is the first instant of the period (00:00:00.000000) and [end] is the
/// last instant of the period (23:59:59.999999). A transaction timestamp belongs to
/// the period when `start <= timestamp <= end`.
///
/// Weekly periods run Sunday through Saturday to match the calendar layout.
class PeriodRange {
  const PeriodRange({
    required this.timeframe,
    required this.start,
    required this.end,
  });

  final Timeframe timeframe;

  /// First inclusive instant of the period (local time, 00:00:00.000).
  final DateTime start;

  /// Last inclusive instant of the period (local time, 23:59:59.999999).
  final DateTime end;

  /// Builds the inclusive range that [instant] falls into for [timeframe].
  factory PeriodRange.forTimeframe(Timeframe timeframe, DateTime instant) {
    final local = _toLocalDate(instant);
    switch (timeframe) {
      case Timeframe.daily:
        return PeriodRange(
          timeframe: timeframe,
          start: _startOfDay(local),
          end: _endOfDay(local),
        );
      case Timeframe.weekly:
        // Sunday is the first day of the week. DateTime.weekday is
        // Mon=1..Sun=7, so `weekday % 7` gives the offset back to Sunday.
        final sunday = local.subtract(Duration(days: local.weekday % 7));
        final saturday = sunday.add(const Duration(days: 6));
        return PeriodRange(
          timeframe: timeframe,
          start: _startOfDay(sunday),
          end: _endOfDay(saturday),
        );
      case Timeframe.monthly:
        final firstOfMonth = DateTime(local.year, local.month, 1);
        final lastOfMonth = DateTime(local.year, local.month + 1, 0);
        return PeriodRange(
          timeframe: timeframe,
          start: _startOfDay(firstOfMonth),
          end: _endOfDay(lastOfMonth),
        );
      case Timeframe.yearly:
        final firstOfYear = DateTime(local.year, 1, 1);
        final lastOfYear = DateTime(local.year, 12, 31);
        return PeriodRange(
          timeframe: timeframe,
          start: _startOfDay(firstOfYear),
          end: _endOfDay(lastOfYear),
        );
    }
  }

  /// Whether [instant] is within this inclusive period.
  bool contains(DateTime instant) {
    final local = instant.isUtc ? instant.toLocal() : instant;
    return !local.isBefore(start) && !local.isAfter(end);
  }

  /// The equivalent period immediately before this one for the same timeframe.
  PeriodRange previous() => _shift(-1);

  /// The equivalent period immediately after this one for the same timeframe.
  PeriodRange next() => _shift(1);

  PeriodRange _shift(int direction) {
    switch (timeframe) {
      case Timeframe.daily:
        return PeriodRange.forTimeframe(
          timeframe,
          start.add(Duration(days: direction)),
        );
      case Timeframe.weekly:
        return PeriodRange.forTimeframe(
          timeframe,
          start.add(Duration(days: 7 * direction)),
        );
      case Timeframe.monthly:
        return PeriodRange.forTimeframe(
          timeframe,
          DateTime(start.year, start.month + direction, 1),
        );
      case Timeframe.yearly:
        return PeriodRange.forTimeframe(
          timeframe,
          DateTime(start.year + direction, 1, 1),
        );
    }
  }

  static DateTime _toLocalDate(DateTime instant) =>
      instant.isUtc ? instant.toLocal() : instant;

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);

  @override
  bool operator ==(Object other) =>
      other is PeriodRange &&
      other.timeframe == timeframe &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(timeframe, start, end);

  @override
  String toString() => 'PeriodRange($timeframe, $start..$end)';
}
