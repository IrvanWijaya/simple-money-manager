// Unit tests for the shared PeriodController that synchronizes timeframe and
// active period across the Transaction, Calendar, and Statistic surfaces.
//
// Covers VAL-HDR-002 (timeframe modes), VAL-HDR-003 (previous/next follows the
// selected timeframe).

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/domain/entities/timeframe.dart';
import 'package:simple_money_manager/src/presentation/shared/period/period_controller.dart';

void main() {
  group('PeriodController', () {
    test('defaults to monthly period containing the anchor instant', () {
      final controller = PeriodController(now: DateTime(2026, 6, 15, 10));
      final state = controller.state;

      expect(state.timeframe, Timeframe.monthly);
      expect(state.range.start, DateTime(2026, 6, 1));
      expect(state.range.end, DateTime(2026, 6, 30, 23, 59, 59, 999, 999));
    });

    test('selectTimeframe re-anchors range to new timeframe', () {
      final controller = PeriodController(now: DateTime(2026, 6, 15));

      controller.selectTimeframe(Timeframe.yearly);
      expect(controller.state.timeframe, Timeframe.yearly);
      expect(controller.state.range.start, DateTime(2026, 1, 1));
      expect(
        controller.state.range.end,
        DateTime(2026, 12, 31, 23, 59, 59, 999, 999),
      );
    });

    test('previous/next moves by one day in daily mode', () {
      final controller = PeriodController(now: DateTime(2026, 6, 15));
      controller.selectTimeframe(Timeframe.daily);
      // From Monthly June, switching to Daily re-anchors on the month start.
      expect(controller.state.range.start, DateTime(2026, 6, 1));

      controller.next();
      expect(controller.state.range.start, DateTime(2026, 6, 2));
      controller.previous();
      controller.previous();
      expect(controller.state.range.start, DateTime(2026, 5, 31));
    });

    test('previous/next moves by one week in weekly mode', () {
      // From Monthly June, switching to Weekly anchors on June 1 (a Monday),
      // whose Sunday-start week begins 2026-05-31.
      final controller = PeriodController(now: DateTime(2026, 6, 15));
      controller.selectTimeframe(Timeframe.weekly);
      expect(controller.state.range.start, DateTime(2026, 5, 31));

      controller.next();
      expect(controller.state.range.start, DateTime(2026, 6, 7));
      controller.previous();
      expect(controller.state.range.start, DateTime(2026, 5, 31));
    });

    test('previous/next moves by one month in monthly mode', () {
      final controller = PeriodController(now: DateTime(2026, 6, 15));

      controller.next();
      expect(controller.state.range.start, DateTime(2026, 7, 1));
      controller.previous();
      controller.previous();
      expect(controller.state.range.start, DateTime(2026, 5, 1));
    });

    test('previous/next moves by one year in yearly mode', () {
      final controller = PeriodController(now: DateTime(2026, 6, 15));
      controller.selectTimeframe(Timeframe.yearly);

      controller.next();
      expect(controller.state.range.start, DateTime(2027, 1, 1));
      controller.previous();
      controller.previous();
      expect(controller.state.range.start, DateTime(2025, 1, 1));
    });

    test('selecting the same timeframe is a no-op', () {
      final controller = PeriodController(now: DateTime(2026, 6, 15));
      final before = controller.state;
      controller.selectTimeframe(Timeframe.monthly);
      expect(controller.state, before);
    });
  });
}
