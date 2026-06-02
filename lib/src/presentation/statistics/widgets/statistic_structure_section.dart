import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/statistic_category_summary.dart';
import '../statistic_providers.dart';
import 'structure_chart.dart';

/// Expense/income structure section for Statistic home.
///
/// Renders the section title and the reusable [StructureChart], driven by the
/// computed [statHomeCategorySummaryProvider] and the active
/// [statChartModeProvider]. The chart and legend always use the same computed
/// category totals (VAL-STAT-010), the bar/donut modes show identical data
/// (VAL-STAT-011), and an empty period yields a stable zero state
/// (VAL-STAT-009, VAL-STAT-012).
class StatisticStructureSection extends ConsumerWidget {
  const StatisticStructureSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(statChartModeProvider);
    final type = ref.watch(statHomeStructureTypeProvider);
    final rows = ref
        .watch(statHomeCategorySummaryProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <StatisticCategorySummary>[],
        );
    final totalAmount = rows.fold<int>(0, (sum, row) => sum + row.amount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            type.isExpense ? 'Expense Structure' : 'Income Structure',
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          StructureChart(
            rows: rows,
            mode: mode,
            type: type,
            totalAmount: totalAmount,
          ),
        ],
      ),
    );
  }
}
