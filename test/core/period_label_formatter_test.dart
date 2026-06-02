import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/core/utils/period_label_formatter.dart';
import 'package:simple_money_manager/src/domain/entities/period_range.dart';
import 'package:simple_money_manager/src/domain/entities/timeframe.dart';

void main() {
  test('monthly label is "MMM yyyy" (e.g. Jun 2026)', () {
    final range = PeriodRange.forTimeframe(
      Timeframe.monthly,
      DateTime(2026, 6, 15),
    );
    expect(PeriodLabelFormatter.format(range), 'Jun 2026');
  });

  test('yearly label is the four-digit year', () {
    final range = PeriodRange.forTimeframe(
      Timeframe.yearly,
      DateTime(2026, 6, 15),
    );
    expect(PeriodLabelFormatter.format(range), '2026');
  });

  test('daily label is "dd MMM yyyy"', () {
    final range = PeriodRange.forTimeframe(
      Timeframe.daily,
      DateTime(2026, 6, 1),
    );
    expect(PeriodLabelFormatter.format(range), '01 Jun 2026');
  });

  test('weekly label within one month uses short start day', () {
    // Week of 2026-06-10 (Wed) is Sun 2026-06-07 .. Sat 2026-06-13.
    final range = PeriodRange.forTimeframe(
      Timeframe.weekly,
      DateTime(2026, 6, 10),
    );
    expect(PeriodLabelFormatter.format(range), '07 - 13 Jun 2026');
  });

  test('weekly label spanning two months in the same year shows months', () {
    // Week of 2026-06-01 (Mon) is Sun 2026-05-31 .. Sat 2026-06-06.
    final range = PeriodRange.forTimeframe(
      Timeframe.weekly,
      DateTime(2026, 6, 1),
    );
    expect(PeriodLabelFormatter.format(range), '31 May - 06 Jun 2026');
  });

  test('weekly label spanning two months shows both months', () {
    // Week containing 2026-07-01 is Sun 2026-06-28 .. Sat 2026-07-04.
    final range = PeriodRange.forTimeframe(
      Timeframe.weekly,
      DateTime(2026, 7, 1),
    );
    expect(PeriodLabelFormatter.format(range), '28 Jun - 04 Jul 2026');
  });
}
