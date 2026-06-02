import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/database_providers.dart';
import '../../core/di/use_case_providers.dart';
import '../../domain/entities/statistic_category_summary.dart';
import '../../domain/entities/statistic_overview.dart';
import '../../domain/entities/transaction_type.dart';
import '../shared/period/period_controller.dart';
import 'stat_chart_mode.dart';

/// The selected Statistic chart visualization (donut or bar).
///
/// The chart-type header action cycles strictly between the two supported
/// modes; switching never touches the computed data, period, or selected type
/// (VAL-STAT-003, VAL-STAT-004).
class StatChartModeController extends StateNotifier<StatChartMode> {
  StatChartModeController() : super(StatChartMode.donut);

  /// Cycles to the other supported mode.
  void toggle() => state = state.toggled;
}

final statChartModeProvider =
    StateNotifierProvider<StatChartModeController, StatChartMode>(
      (ref) => StatChartModeController(),
    );

/// The Statistic structure type the home chart visualizes. The reference home
/// statistic shows the Expense structure; Income/Expense filtering on the
/// detail screen is handled separately.
final statHomeStructureTypeProvider = Provider<TransactionType>(
  (ref) => TransactionType.expense,
);

/// Computed opening/ending balance and income/expense/total overview for the
/// active shared period. Recomputes whenever the period changes
/// (VAL-STAT-001, VAL-STAT-002).
final statisticOverviewProvider = FutureProvider<StatisticOverview>((
  ref,
) async {
  final range = ref.watch(activePeriodRangeProvider);
  return ref.watch(getStatisticOverviewProvider).call(range);
});

/// Computed per-category statistics for the active period and the home
/// structure type. Backs both the chart and the legend so they always render
/// the same data (VAL-STAT-010). Rows are already ordered by descending amount
/// with deterministic tie-breaks by the use case (VAL-STAT-013).
final statHomeCategorySummaryProvider =
    FutureProvider<List<StatisticCategorySummary>>((ref) async {
      await ref.watch(dataInitializationProvider.future);
      final range = ref.watch(activePeriodRangeProvider);
      final type = ref.watch(statHomeStructureTypeProvider);
      return ref.watch(getStatisticCategorySummaryProvider).call(range, type);
    });

/// The Income/Expense tab currently selected on the Structure detail screen.
///
/// Defaults to Expense to match the reference (the Expense tab is selected on
/// open). Switching tabs only changes which type's statistics are shown; the
/// Income and Expense breakdowns are computed independently (VAL-STAT-007).
class StructureDetailTypeController extends StateNotifier<TransactionType> {
  StructureDetailTypeController() : super(TransactionType.expense);

  void select(TransactionType type) => state = type;
}

final structureDetailTypeProvider =
    StateNotifierProvider<StructureDetailTypeController, TransactionType>(
      (ref) => StructureDetailTypeController(),
    );

/// Computed per-category statistics for the active period and the requested
/// Structure detail [TransactionType]. Family-keyed by type so the Income and
/// Expense tabs each resolve their own independent breakdown (VAL-STAT-007),
/// and both recompute whenever the shared active period changes
/// (VAL-STAT-014, VAL-STAT-016).
final structureDetailCategorySummaryProvider =
    FutureProvider.family<List<StatisticCategorySummary>, TransactionType>((
      ref,
      type,
    ) async {
      await ref.watch(dataInitializationProvider.future);
      final range = ref.watch(activePeriodRangeProvider);
      return ref.watch(getStatisticCategorySummaryProvider).call(range, type);
    });
