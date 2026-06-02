import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/period_range.dart';
import '../../../domain/entities/timeframe.dart';
import 'period_state.dart';

/// Drives the single source of truth for the active timeframe and period.
///
/// Transaction, Calendar, and Statistic surfaces all watch this controller, so
/// changing the timeframe or moving previous/next keeps every surface filtered
/// to the same period. Anchoring on `DateTime.now()` makes the initial period
/// the one containing the current instant for the default Monthly timeframe.
class PeriodController extends StateNotifier<PeriodState> {
  PeriodController({
    Timeframe initialTimeframe = Timeframe.monthly,
    DateTime? now,
  }) : super(
         PeriodState(
           timeframe: initialTimeframe,
           range: PeriodRange.forTimeframe(
             initialTimeframe,
             now ?? DateTime.now(),
           ),
         ),
       );

  /// Switches the active [timeframe], re-anchoring the selected period on the
  /// current period's start so the new range stays close to what the user was
  /// viewing (for example Monthly `Jun 2026` -> Yearly `2026`).
  void selectTimeframe(Timeframe timeframe) {
    if (timeframe == state.timeframe) return;
    state = PeriodState(
      timeframe: timeframe,
      range: PeriodRange.forTimeframe(timeframe, state.range.start),
    );
  }

  /// Moves to the previous period of the active timeframe.
  void previous() {
    state = PeriodState(
      timeframe: state.timeframe,
      range: state.range.previous(),
    );
  }

  /// Moves to the next period of the active timeframe.
  void next() {
    state = PeriodState(timeframe: state.timeframe, range: state.range.next());
  }
}

/// Shared period state for all home surfaces.
final periodControllerProvider =
    StateNotifierProvider<PeriodController, PeriodState>(
      (ref) => PeriodController(),
    );

/// Convenience selector for just the active [PeriodRange].
final activePeriodRangeProvider = Provider<PeriodRange>(
  (ref) => ref.watch(periodControllerProvider).range,
);
