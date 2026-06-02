import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/use_case_providers.dart';
import '../../domain/entities/period_summary.dart';
import '../shared/period/period_controller.dart';
import '../transactions/transaction_providers.dart';

/// Per-day income/expense totals for the active shared period.
///
/// Awaits [dueRecurringGenerationProvider] so due recurring occurrences are
/// included in daily totals, then watches [activePeriodRangeProvider] and
/// delegates to [getCalendarDayTotalsProvider]. The result maps each calendar
/// day (local midnight) with data to its computed [PeriodSummary]; days without
/// transactions are absent so cells never show stale totals (VAL-CAL-005,
/// VAL-CAL-006).
final calendarDayTotalsProvider = FutureProvider<Map<DateTime, PeriodSummary>>((
  ref,
) async {
  await ref.watch(dueRecurringGenerationProvider.future);
  final range = ref.watch(activePeriodRangeProvider);
  return ref.watch(getCalendarDayTotalsProvider).call(range);
});

/// The month (local, day 1, midnight) the calendar grid is anchored on.
///
/// Derived from the active period's start so the grid follows period
/// navigation and every timeframe: monthly shows that month, weekly shows the
/// month containing the week start, daily shows the month of the selected day,
/// and yearly shows the year's first month. Combined with
/// [calendarDayTotalsProvider] (which filters to the active range), the grid
/// only shows totals for days inside the active period (VAL-CAL-006,
/// VAL-CAL-007).
final calendarGridMonthProvider = Provider<DateTime>((ref) {
  final start = ref.watch(activePeriodRangeProvider).start;
  return DateTime(start.year, start.month, 1);
});

/// The current calendar day (local midnight), used to highlight "today".
///
/// Exposed as a provider so widget tests can override it deterministically; in
/// the app it resolves to the real wall-clock day.
final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
