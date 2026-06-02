import '../entities/recurring_end_condition.dart';
import '../entities/recurring_frequency.dart';
import '../entities/recurring_repeat_position.dart';
import '../entities/recurring_rule.dart';

/// Pure scheduling engine that turns a [RecurringRule] into concrete occurrence
/// dates.
///
/// The engine is deterministic and has no I/O: given the same rule and the same
/// `until` bound it always returns the same ordered list of occurrence
/// date-times. The generation use case layers persistence and idempotency on
/// top of these dates.
///
/// ## Occurrence model
///
/// - Occurrence 1 (index 0) is always the rule's [RecurringRule.startDate]
///   exactly. This represents the initial saved transaction, so count and
///   end-date conditions treat the start date as the first occurrence.
/// - Occurrence `k >= 1` advances `interval` units of the [RecurringFrequency]
///   from the start period and is placed according to the
///   [RecurringRepeatPosition] (same day, start of period, or end of period).
/// - Time-of-day is copied from the start date onto every occurrence.
///
/// ## Calendar semantics
///
/// - Weekly periods run Sunday..Saturday, so `startOfPeriod` lands on Sunday and
///   `endOfPeriod` lands on Saturday.
/// - Monthly `sameDay` clamps to the last day of shorter months (e.g. the 31st
///   becomes the 28th/29th in February); `endOfPeriod` is the last day.
/// - Yearly `sameDay` starting on February 29 falls back to February 28 in
///   non-leap years and returns to February 29 in leap years.
class RecurringSchedule {
  const RecurringSchedule(this.rule);

  final RecurringRule rule;

  /// Hard cap on iterations to guarantee termination for `forever`/`endDate`
  /// rules even with a far-future [until]; large enough never to clip realistic
  /// schedules.
  static const int _safetyCap = 100000;

  /// All occurrence dates from the start up to and including [until], honoring
  /// the rule's end condition. Always ordered ascending.
  List<DateTime> occurrencesUntil(DateTime until) {
    final result = <DateTime>[];
    final count = rule.endCondition == RecurringEndCondition.count
        ? rule.endCount
        : null;
    final endDate = rule.endCondition == RecurringEndCondition.endDate
        ? rule.endDate
        : null;

    for (var k = 0; k < _safetyCap; k++) {
      if (count != null && k >= count) break;

      final occurrence = _occurrenceAt(k);
      if (occurrence.isAfter(until)) break;
      if (endDate != null && occurrence.isAfter(endDate)) break;

      result.add(occurrence);

      // `none` does not repeat: only the initial occurrence exists.
      if (!rule.frequency.repeats) break;
    }
    return result;
  }

  /// The first occurrence on or after [reference], honoring the rule's end
  /// condition, or `null` when the rule has no eligible occurrence at or after
  /// [reference] (for example a count/end-date rule that already ended).
  ///
  /// Used to display a rule's "next occurrence" without materializing every
  /// past date. Iterates ascending and stops as soon as the end condition is
  /// exceeded.
  DateTime? nextOccurrenceOnOrAfter(DateTime reference) {
    final count = rule.endCondition == RecurringEndCondition.count
        ? rule.endCount
        : null;
    final endDate = rule.endCondition == RecurringEndCondition.endDate
        ? rule.endDate
        : null;

    for (var k = 0; k < _safetyCap; k++) {
      if (count != null && k >= count) break;

      final occurrence = _occurrenceAt(k);
      if (endDate != null && occurrence.isAfter(endDate)) break;

      if (!occurrence.isBefore(reference)) return occurrence;

      // `none` does not repeat: only the initial occurrence exists.
      if (!rule.frequency.repeats) break;
    }
    return null;
  }

  /// Deterministic idempotency key for an occurrence [date].
  ///
  /// Combines the rule id with the ISO-8601 instant, truncated to whole-second
  /// precision, so re-running generation recognizes already-produced
  /// occurrences. Truncation matters because the local store persists
  /// `DateTime` values at second resolution: a rule generated in-memory (with
  /// sub-second `startDate` precision) and the same rule reloaded from storage
  /// must yield the SAME key, otherwise generation would create a duplicate
  /// occurrence after the rule round-trips through the database.
  String occurrenceKeyFor(DateTime date) =>
      '${rule.id}@${_toSecondPrecision(date).toIso8601String()}';

  /// Drops sub-second components so the key is stable across the database's
  /// whole-second `DateTime` storage. Occurrences whose start time already has
  /// no sub-second part are unaffected.
  static DateTime _toSecondPrecision(DateTime date) => DateTime(
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
  );

  DateTime _occurrenceAt(int k) {
    if (k == 0) return rule.startDate;
    switch (rule.frequency) {
      case RecurringFrequency.none:
        return rule.startDate;
      case RecurringFrequency.daily:
        return _dailyOccurrence(k);
      case RecurringFrequency.weekly:
        return _weeklyOccurrence(k);
      case RecurringFrequency.monthly:
        return _monthlyOccurrence(k);
      case RecurringFrequency.yearly:
        return _yearlyOccurrence(k);
    }
  }

  DateTime _dailyOccurrence(int k) {
    final start = rule.startDate;
    return _withStartTime(
      DateTime(start.year, start.month, start.day + rule.interval * k),
    );
  }

  DateTime _weeklyOccurrence(int k) {
    final start = rule.startDate;
    // DateTime.weekday is Mon=1..Sun=7; `% 7` gives the offset back to Sunday.
    final startOffset = start.weekday % 7;
    final sundayOfStart = DateTime(
      start.year,
      start.month,
      start.day - startOffset,
    );
    final periodSunday = DateTime(
      sundayOfStart.year,
      sundayOfStart.month,
      sundayOfStart.day + 7 * rule.interval * k,
    );
    switch (rule.effectiveRepeatPosition) {
      case RecurringRepeatPosition.startOfPeriod:
        return _withStartTime(periodSunday);
      case RecurringRepeatPosition.endOfPeriod:
        return _withStartTime(
          DateTime(periodSunday.year, periodSunday.month, periodSunday.day + 6),
        );
      case RecurringRepeatPosition.sameDay:
        return _withStartTime(
          DateTime(
            periodSunday.year,
            periodSunday.month,
            periodSunday.day + startOffset,
          ),
        );
    }
  }

  DateTime _monthlyOccurrence(int k) {
    final start = rule.startDate;
    final year = start.year;
    final month = start.month + rule.interval * k;
    final lastDay = _lastDayOfMonth(year, month);
    switch (rule.effectiveRepeatPosition) {
      case RecurringRepeatPosition.startOfPeriod:
        return _withStartTime(DateTime(year, month, 1));
      case RecurringRepeatPosition.endOfPeriod:
        return _withStartTime(DateTime(year, month, lastDay));
      case RecurringRepeatPosition.sameDay:
        final day = start.day < lastDay ? start.day : lastDay;
        return _withStartTime(DateTime(year, month, day));
    }
  }

  DateTime _yearlyOccurrence(int k) {
    final start = rule.startDate;
    final year = start.year + rule.interval * k;
    switch (rule.effectiveRepeatPosition) {
      case RecurringRepeatPosition.startOfPeriod:
        return _withStartTime(DateTime(year, 1, 1));
      case RecurringRepeatPosition.endOfPeriod:
        return _withStartTime(DateTime(year, 12, 31));
      case RecurringRepeatPosition.sameDay:
        final lastDay = _lastDayOfMonth(year, start.month);
        final day = start.day < lastDay ? start.day : lastDay;
        return _withStartTime(DateTime(year, start.month, day));
    }
  }

  /// Number of days in the given month, normalizing month overflow/underflow.
  static int _lastDayOfMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  DateTime _withStartTime(DateTime date) {
    final start = rule.startDate;
    return DateTime(
      date.year,
      date.month,
      date.day,
      start.hour,
      start.minute,
      start.second,
      start.millisecond,
      start.microsecond,
    );
  }
}
