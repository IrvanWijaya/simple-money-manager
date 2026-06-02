import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/domain/entities/period_range.dart';
import 'package:simple_money_manager/src/domain/entities/timeframe.dart';

void main() {
  group('PeriodRange.daily', () {
    test('start and end are inclusive midnight..end-of-day', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.daily,
        DateTime(2026, 6, 1, 13, 45),
      );

      expect(range.start, DateTime(2026, 6, 1, 0, 0, 0, 0));
      expect(range.end, DateTime(2026, 6, 1, 23, 59, 59, 999, 999));
    });

    test('includes start and end boundary instants, excludes just outside', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.daily,
        DateTime(2026, 6, 1),
      );

      expect(range.contains(DateTime(2026, 6, 1, 0, 0, 0, 0)), isTrue);
      expect(range.contains(DateTime(2026, 6, 1, 23, 59, 59, 999)), isTrue);
      expect(range.contains(DateTime(2026, 5, 31, 23, 59, 59, 999)), isFalse);
      expect(range.contains(DateTime(2026, 6, 2, 0, 0, 0, 0)), isFalse);
    });

    test('previous/next move by one day', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.daily,
        DateTime(2026, 6, 1),
      );
      expect(range.previous().start, DateTime(2026, 5, 31));
      expect(range.next().start, DateTime(2026, 6, 2));
    });
  });

  group('PeriodRange.weekly (Sunday..Saturday)', () {
    test('a Monday resolves to the prior Sunday through Saturday', () {
      // 2026-06-01 is a Monday.
      final range = PeriodRange.forTimeframe(
        Timeframe.weekly,
        DateTime(2026, 6, 1),
      );

      expect(range.start, DateTime(2026, 5, 31)); // Sunday
      expect(range.start.weekday, DateTime.sunday);
      expect(range.end, DateTime(2026, 6, 6, 23, 59, 59, 999, 999)); // Saturday
      expect(DateTime(2026, 6, 6).weekday, DateTime.saturday);
    });

    test('a Sunday is the start of its own week', () {
      // 2026-05-31 is a Sunday.
      final range = PeriodRange.forTimeframe(
        Timeframe.weekly,
        DateTime(2026, 5, 31),
      );
      expect(range.start, DateTime(2026, 5, 31));
      expect(range.start.weekday, DateTime.sunday);
    });

    test('a Saturday stays within the same Sunday..Saturday week', () {
      // 2026-06-06 is a Saturday.
      final range = PeriodRange.forTimeframe(
        Timeframe.weekly,
        DateTime(2026, 6, 6),
      );
      expect(range.start, DateTime(2026, 5, 31));
      expect(range.end.weekday, DateTime.saturday);
    });

    test('boundary inclusivity across the week', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.weekly,
        DateTime(2026, 6, 3),
      );
      expect(range.contains(DateTime(2026, 5, 31, 0, 0, 0, 0)), isTrue);
      expect(range.contains(DateTime(2026, 6, 6, 23, 59, 59, 999)), isTrue);
      expect(range.contains(DateTime(2026, 5, 30, 23, 59, 59, 999)), isFalse);
      expect(range.contains(DateTime(2026, 6, 7, 0, 0, 0, 0)), isFalse);
    });

    test('previous/next move by exactly seven days', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.weekly,
        DateTime(2026, 6, 1),
      );
      expect(range.previous().start, DateTime(2026, 5, 24));
      expect(range.next().start, DateTime(2026, 6, 7));
      expect(range.next().start.weekday, DateTime.sunday);
    });
  });

  group('PeriodRange.monthly', () {
    test('spans first to last day inclusive, handling month length', () {
      final june = PeriodRange.forTimeframe(
        Timeframe.monthly,
        DateTime(2026, 6, 15),
      );
      expect(june.start, DateTime(2026, 6, 1));
      expect(june.end, DateTime(2026, 6, 30, 23, 59, 59, 999, 999));

      final feb = PeriodRange.forTimeframe(
        Timeframe.monthly,
        DateTime(2024, 2, 10),
      );
      expect(feb.end, DateTime(2024, 2, 29, 23, 59, 59, 999, 999)); // leap year
    });

    test('boundary inclusivity', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.monthly,
        DateTime(2026, 6, 15),
      );
      expect(range.contains(DateTime(2026, 6, 1)), isTrue);
      expect(range.contains(DateTime(2026, 6, 30, 23, 59, 59, 999)), isTrue);
      expect(range.contains(DateTime(2026, 5, 31, 23, 59, 59, 999)), isFalse);
      expect(range.contains(DateTime(2026, 7, 1)), isFalse);
    });

    test('previous/next move by one month and wrap years', () {
      final jan = PeriodRange.forTimeframe(
        Timeframe.monthly,
        DateTime(2026, 1, 10),
      );
      expect(jan.previous().start, DateTime(2025, 12, 1));
      final dec = PeriodRange.forTimeframe(
        Timeframe.monthly,
        DateTime(2026, 12, 10),
      );
      expect(dec.next().start, DateTime(2027, 1, 1));
    });
  });

  group('PeriodRange.yearly', () {
    test('spans Jan 1 to Dec 31 inclusive', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.yearly,
        DateTime(2026, 6, 15),
      );
      expect(range.start, DateTime(2026, 1, 1));
      expect(range.end, DateTime(2026, 12, 31, 23, 59, 59, 999, 999));
    });

    test('boundary inclusivity', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.yearly,
        DateTime(2026, 6, 15),
      );
      expect(range.contains(DateTime(2026, 1, 1)), isTrue);
      expect(range.contains(DateTime(2026, 12, 31, 23, 59, 59, 999)), isTrue);
      expect(range.contains(DateTime(2025, 12, 31, 23, 59, 59, 999)), isFalse);
      expect(range.contains(DateTime(2027, 1, 1)), isFalse);
    });

    test('previous/next move by one year', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.yearly,
        DateTime(2026, 6, 1),
      );
      expect(range.previous().start, DateTime(2025, 1, 1));
      expect(range.next().start, DateTime(2027, 1, 1));
    });
  });

  group('final-microsecond inclusion across timeframes', () {
    test('daily includes 23:59:59.999999 and excludes next day 00:00', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.daily,
        DateTime(2026, 6, 1),
      );
      expect(range.end, DateTime(2026, 6, 1, 23, 59, 59, 999, 999));
      expect(
        range.contains(DateTime(2026, 6, 1, 23, 59, 59, 999, 999)),
        isTrue,
      );
      expect(range.contains(DateTime(2026, 6, 2, 0, 0, 0, 0, 0)), isFalse);
    });

    test('weekly includes 23:59:59.999999 and excludes next week 00:00', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.weekly,
        DateTime(2026, 6, 1),
      );
      expect(range.end, DateTime(2026, 6, 6, 23, 59, 59, 999, 999));
      expect(
        range.contains(DateTime(2026, 6, 6, 23, 59, 59, 999, 999)),
        isTrue,
      );
      expect(range.contains(DateTime(2026, 6, 7, 0, 0, 0, 0, 0)), isFalse);
    });

    test('monthly includes 23:59:59.999999 and excludes next month 00:00', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.monthly,
        DateTime(2026, 6, 15),
      );
      expect(range.end, DateTime(2026, 6, 30, 23, 59, 59, 999, 999));
      expect(
        range.contains(DateTime(2026, 6, 30, 23, 59, 59, 999, 999)),
        isTrue,
      );
      expect(range.contains(DateTime(2026, 7, 1, 0, 0, 0, 0, 0)), isFalse);
    });

    test('yearly includes 23:59:59.999999 and excludes next year 00:00', () {
      final range = PeriodRange.forTimeframe(
        Timeframe.yearly,
        DateTime(2026, 6, 15),
      );
      expect(range.end, DateTime(2026, 12, 31, 23, 59, 59, 999, 999));
      expect(
        range.contains(DateTime(2026, 12, 31, 23, 59, 59, 999, 999)),
        isTrue,
      );
      expect(range.contains(DateTime(2027, 1, 1, 0, 0, 0, 0, 0)), isFalse);
    });
  });

  test('Timeframe.rangeFor delegates to PeriodRange.forTimeframe', () {
    final instant = DateTime(2026, 6, 1, 9);
    expect(
      Timeframe.monthly.rangeFor(instant),
      PeriodRange.forTimeframe(Timeframe.monthly, instant),
    );
  });

  test('contains normalizes UTC instants to local time', () {
    final range = PeriodRange.forTimeframe(
      Timeframe.daily,
      DateTime(2026, 6, 1),
    );
    final localNoon = DateTime(2026, 6, 1, 12);
    expect(range.contains(localNoon.toUtc()), isTrue);
  });
}
