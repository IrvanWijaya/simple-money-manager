import 'package:intl/intl.dart';

import '../../domain/entities/period_range.dart';
import '../../domain/entities/timeframe.dart';

/// Formats a [PeriodRange] into a human-readable header label per timeframe.
///
/// Examples:
/// - daily:   `01 Jun 2026`
/// - weekly:  `01 - 07 Jun 2026` (or `29 Jun - 05 Jul 2026` across months)
/// - monthly: `Jun 2026`
/// - yearly:  `2026`
class PeriodLabelFormatter {
  PeriodLabelFormatter._();

  static final DateFormat _day = DateFormat('dd MMM yyyy');
  static final DateFormat _dayShort = DateFormat('dd');
  static final DateFormat _monthDay = DateFormat('dd MMM');
  static final DateFormat _month = DateFormat('MMM yyyy');
  static final DateFormat _year = DateFormat('yyyy');

  static String format(PeriodRange range) {
    switch (range.timeframe) {
      case Timeframe.daily:
        return _day.format(range.start);
      case Timeframe.weekly:
        return _formatWeek(range);
      case Timeframe.monthly:
        return _month.format(range.start);
      case Timeframe.yearly:
        return _year.format(range.start);
    }
  }

  static String _formatWeek(PeriodRange range) {
    final start = range.start;
    final end = range.end;
    if (start.year == end.year && start.month == end.month) {
      return '${_dayShort.format(start)} - ${_day.format(end)}';
    }
    if (start.year == end.year) {
      return '${_monthDay.format(start)} - ${_day.format(end)}';
    }
    return '${_day.format(start)} - ${_day.format(end)}';
  }
}
