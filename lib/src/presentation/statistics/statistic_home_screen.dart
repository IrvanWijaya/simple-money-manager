import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../shared/period/home_header.dart';
import '../shared/period/period_overview.dart';
import 'stat_chart_mode.dart';
import 'statistic_providers.dart';
import 'structure_detail_screen.dart';
import 'widgets/show_more_row.dart';
import 'widgets/statistic_balance_row.dart';
import 'widgets/statistic_structure_section.dart';

/// Statistic tab surface.
///
/// Hosts the shared balance/period header (with a chart-type toggle action),
/// the opening/ending balance row, the computed period overview, a Show more
/// row that opens Structure detail, and the expense/income structure chart with
/// a computed legend. All values recompute when the active period changes and
/// the chart toggles only between donut and bar without changing any totals
/// (VAL-STAT-003, VAL-STAT-004, VAL-STAT-005, VAL-STAT-009..012).
class StatisticHomeScreen extends ConsumerWidget {
  const StatisticHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(statChartModeProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(
            leadingActions: [
              IconButton(
                key: const ValueKey('stat-chart-toggle'),
                tooltip: 'Chart type',
                icon: Icon(
                  mode == StatChartMode.donut
                      ? Icons.pie_chart_outline
                      : Icons.bar_chart,
                ),
                color: AppColors.onBackground,
                onPressed: () =>
                    ref.read(statChartModeProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const StatisticBalanceRow(),
          const SizedBox(height: 12),
          const PeriodOverview(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                ShowMoreRow(
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const StructureDetailScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const StatisticStructureSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
