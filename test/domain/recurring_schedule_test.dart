import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_end_condition.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_repeat_position.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_rule.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/domain/services/recurring_schedule.dart';

RecurringRule _rule({
  RecurringFrequency frequency = RecurringFrequency.daily,
  int interval = 1,
  RecurringRepeatPosition? repeatPosition,
  RecurringEndCondition endCondition = RecurringEndCondition.forever,
  int? endCount,
  DateTime? endDate,
  required DateTime startDate,
}) {
  return RecurringRule(
    id: 'rule-1',
    type: TransactionType.expense,
    amount: 1000,
    categoryId: 'expense_bills',
    frequency: frequency,
    interval: interval,
    repeatPosition: repeatPosition,
    endCondition: endCondition,
    endCount: endCount,
    endDate: endDate,
    startDate: startDate,
  );
}

List<DateTime> _dates(RecurringRule rule, DateTime until) =>
    RecurringSchedule(rule).occurrencesUntil(until);

void main() {
  group('VAL-RECRULE-001 daily interval', () {
    test(
      'interval 2 generates every other day and excludes intervening days',
      () {
        final rule = _rule(
          frequency: RecurringFrequency.daily,
          interval: 2,
          startDate: DateTime(2026, 6, 1),
        );
        final dates = _dates(rule, DateTime(2026, 6, 9));
        expect(dates, [
          DateTime(2026, 6, 1),
          DateTime(2026, 6, 3),
          DateTime(2026, 6, 5),
          DateTime(2026, 6, 7),
          DateTime(2026, 6, 9),
        ]);
      },
    );

    test('preserves time-of-day on each occurrence', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 1, 9, 30),
      );
      final dates = _dates(rule, DateTime(2026, 6, 3, 23, 59));
      expect(dates, [
        DateTime(2026, 6, 1, 9, 30),
        DateTime(2026, 6, 2, 9, 30),
        DateTime(2026, 6, 3, 9, 30),
      ]);
    });
  });

  group('VAL-RECRULE-002 / 012 weekly', () {
    // 2026-06-03 is a Wednesday.
    final wednesday = DateTime(2026, 6, 3);

    test('interval 2 sameDay generates every other week on same weekday', () {
      final rule = _rule(
        frequency: RecurringFrequency.weekly,
        interval: 2,
        repeatPosition: RecurringRepeatPosition.sameDay,
        startDate: wednesday,
      );
      final dates = _dates(rule, DateTime(2026, 7, 2));
      expect(dates, [
        DateTime(2026, 6, 3),
        DateTime(2026, 6, 17),
        DateTime(2026, 7, 1),
      ]);
      // every occurrence is a Wednesday
      expect(dates.every((d) => d.weekday == DateTime.wednesday), isTrue);
    });

    test('startOfPeriod lands on Sunday', () {
      final rule = _rule(
        frequency: RecurringFrequency.weekly,
        repeatPosition: RecurringRepeatPosition.startOfPeriod,
        startDate: wednesday,
      );
      final dates = _dates(rule, DateTime(2026, 6, 25));
      // First occurrence keeps the start date itself (occurrence 1).
      expect(dates.first, wednesday);
      // Subsequent occurrences fall on Sunday.
      for (final d in dates.skip(1)) {
        expect(d.weekday, DateTime.sunday);
      }
      expect(dates[1], DateTime(2026, 6, 7));
      expect(dates[2], DateTime(2026, 6, 14));
    });

    test('endOfPeriod lands on Saturday', () {
      final rule = _rule(
        frequency: RecurringFrequency.weekly,
        repeatPosition: RecurringRepeatPosition.endOfPeriod,
        startDate: wednesday,
      );
      final dates = _dates(rule, DateTime(2026, 6, 25));
      expect(dates.first, wednesday);
      for (final d in dates.skip(1)) {
        expect(d.weekday, DateTime.saturday);
      }
      expect(dates[1], DateTime(2026, 6, 13));
      expect(dates[2], DateTime(2026, 6, 20));
    });
  });

  group('VAL-RECRULE-003 monthly', () {
    test('interval 2 sameDay on the 15th', () {
      final rule = _rule(
        frequency: RecurringFrequency.monthly,
        interval: 2,
        repeatPosition: RecurringRepeatPosition.sameDay,
        startDate: DateTime(2026, 1, 15),
      );
      final dates = _dates(rule, DateTime(2026, 7, 31));
      expect(dates, [
        DateTime(2026, 1, 15),
        DateTime(2026, 3, 15),
        DateTime(2026, 5, 15),
        DateTime(2026, 7, 15),
      ]);
    });

    test('sameDay on the 31st clamps to shorter months', () {
      final rule = _rule(
        frequency: RecurringFrequency.monthly,
        repeatPosition: RecurringRepeatPosition.sameDay,
        startDate: DateTime(2026, 1, 31),
      );
      final dates = _dates(rule, DateTime(2026, 4, 30));
      expect(dates, [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28), // clamped (2026 is not a leap year)
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 30), // clamped
      ]);
    });

    test('startOfPeriod is the 1st and endOfPeriod is the last day', () {
      final start = _rule(
        frequency: RecurringFrequency.monthly,
        repeatPosition: RecurringRepeatPosition.startOfPeriod,
        startDate: DateTime(2026, 1, 10),
      );
      expect(_dates(start, DateTime(2026, 3, 31)), [
        DateTime(2026, 1, 10),
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
      ]);

      final end = _rule(
        frequency: RecurringFrequency.monthly,
        repeatPosition: RecurringRepeatPosition.endOfPeriod,
        startDate: DateTime(2026, 1, 10),
      );
      expect(_dates(end, DateTime(2026, 3, 31)), [
        DateTime(2026, 1, 10),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
      ]);
    });
  });

  group('VAL-RECRULE-004 yearly', () {
    test('interval 2 sameDay', () {
      final rule = _rule(
        frequency: RecurringFrequency.yearly,
        interval: 2,
        repeatPosition: RecurringRepeatPosition.sameDay,
        startDate: DateTime(2020, 6, 15),
      );
      final dates = _dates(rule, DateTime(2026, 12, 31));
      expect(dates, [
        DateTime(2020, 6, 15),
        DateTime(2022, 6, 15),
        DateTime(2024, 6, 15),
        DateTime(2026, 6, 15),
      ]);
    });

    test('startOfPeriod is Jan 1 and endOfPeriod is Dec 31', () {
      final start = _rule(
        frequency: RecurringFrequency.yearly,
        repeatPosition: RecurringRepeatPosition.startOfPeriod,
        startDate: DateTime(2024, 6, 15),
      );
      expect(_dates(start, DateTime(2026, 12, 31)), [
        DateTime(2024, 6, 15),
        DateTime(2025, 1, 1),
        DateTime(2026, 1, 1),
      ]);

      final end = _rule(
        frequency: RecurringFrequency.yearly,
        repeatPosition: RecurringRepeatPosition.endOfPeriod,
        startDate: DateTime(2024, 6, 15),
      );
      expect(_dates(end, DateTime(2026, 12, 31)), [
        DateTime(2024, 6, 15),
        DateTime(2025, 12, 31),
        DateTime(2026, 12, 31),
      ]);
    });
  });

  group('VAL-RECRULE-013 leap-day fallback', () {
    test('Feb 29 yearly sameDay falls back to Feb 28 in non-leap years', () {
      final rule = _rule(
        frequency: RecurringFrequency.yearly,
        repeatPosition: RecurringRepeatPosition.sameDay,
        startDate: DateTime(2024, 2, 29),
      );
      final dates = _dates(rule, DateTime(2028, 12, 31));
      expect(dates, [
        DateTime(2024, 2, 29), // leap
        DateTime(2025, 2, 28), // fallback
        DateTime(2026, 2, 28), // fallback
        DateTime(2027, 2, 28), // fallback
        DateTime(2028, 2, 29), // leap again
      ]);
    });
  });

  group('VAL-RECRULE-005 forever', () {
    test('produces at least five occurrences past start', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 1),
      );
      final dates = _dates(rule, DateTime(2026, 6, 30));
      expect(dates.length, greaterThanOrEqualTo(5));
    });
  });

  group('VAL-RECRULE-006 / 011 count', () {
    test('count 3 yields exactly three occurrences including the start', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        endCondition: RecurringEndCondition.count,
        endCount: 3,
        startDate: DateTime(2026, 6, 1),
      );
      // Even with a far-future bound, only 3 are produced.
      final dates = _dates(rule, DateTime(2027, 1, 1));
      expect(dates, [
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 3),
      ]);
    });

    test('count 1 yields only the initial occurrence', () {
      final rule = _rule(
        frequency: RecurringFrequency.monthly,
        endCondition: RecurringEndCondition.count,
        endCount: 1,
        startDate: DateTime(2026, 6, 1),
      );
      expect(_dates(rule, DateTime(2030, 1, 1)), [DateTime(2026, 6, 1)]);
    });
  });

  group('VAL-RECRULE-007 end date', () {
    test('stops on or before the inclusive end date', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        interval: 1,
        endCondition: RecurringEndCondition.endDate,
        endDate: DateTime(2026, 6, 4),
        startDate: DateTime(2026, 6, 1),
      );
      final dates = _dates(rule, DateTime(2026, 6, 30));
      expect(dates, [
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 2),
        DateTime(2026, 6, 3),
        DateTime(2026, 6, 4),
      ]);
      expect(dates.last.isAfter(DateTime(2026, 6, 4)), isFalse);
    });
  });

  group('cutoff (not-yet-due)', () {
    test('occurrences after the cutoff are excluded', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 1),
      );
      // Cutoff before later occurrences -> they are not returned.
      final dates = _dates(rule, DateTime(2026, 6, 2));
      expect(dates, [DateTime(2026, 6, 1), DateTime(2026, 6, 2)]);
    });

    test('none frequency yields only the start occurrence', () {
      final rule = _rule(
        frequency: RecurringFrequency.none,
        startDate: DateTime(2026, 6, 1),
      );
      expect(_dates(rule, DateTime(2027, 1, 1)), [DateTime(2026, 6, 1)]);
    });
  });

  group('nextOccurrenceOnOrAfter', () {
    test('returns the start date when reference is before it', () {
      final rule = _rule(
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 6, 1, 8, 0),
      );
      expect(
        RecurringSchedule(rule).nextOccurrenceOnOrAfter(DateTime(2026, 5, 20)),
        DateTime(2026, 6, 1, 8, 0),
      );
    });

    test('returns the next future occurrence past the reference', () {
      final rule = _rule(
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 6, 1, 8, 0),
      );
      expect(
        RecurringSchedule(rule).nextOccurrenceOnOrAfter(DateTime(2026, 6, 15)),
        DateTime(2026, 7, 1, 8, 0),
      );
    });

    test('includes an occurrence exactly on the reference instant', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 1, 8, 0),
      );
      expect(
        RecurringSchedule(
          rule,
        ).nextOccurrenceOnOrAfter(DateTime(2026, 6, 3, 8, 0)),
        DateTime(2026, 6, 3, 8, 0),
      );
    });

    test('returns null when a count rule has already ended', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 1, 8, 0),
        endCondition: RecurringEndCondition.count,
        endCount: 3,
      );
      expect(
        RecurringSchedule(rule).nextOccurrenceOnOrAfter(DateTime(2026, 6, 15)),
        isNull,
      );
    });

    test('returns null when an end-date rule has already ended', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 1, 8, 0),
        endCondition: RecurringEndCondition.endDate,
        endDate: DateTime(2026, 6, 5),
      );
      expect(
        RecurringSchedule(rule).nextOccurrenceOnOrAfter(DateTime(2026, 6, 15)),
        isNull,
      );
    });
  });
}
