import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/period_label_formatter.dart';
import '../../domain/entities/statistic_category_summary.dart';
import '../../domain/entities/transaction_type.dart';
import '../shared/period/period_controller.dart';
import '../shared/period/timeframe_selector.dart';
import 'stat_chart_mode.dart';
import 'statistic_providers.dart';
import 'widgets/structure_category_row.dart';
import 'widgets/structure_chart.dart';

/// Statistic Structure detail screen.
///
/// Opened from the Statistic home `Show more` row. It reuses the shared
/// [periodControllerProvider], so it opens with the same active period/timeframe
/// context the user was viewing (VAL-STAT-005) and back returns to Statistic
/// home with that context preserved (VAL-STAT-014).
///
/// Shows the Structure header (back + calendar/filter actions), period
/// navigation, Income/Expense tabs that filter independently (VAL-STAT-007), a
/// computed donut chart, and a category breakdown list with percentage, amount,
/// and transaction count (VAL-STAT-006, VAL-STAT-008). The calendar action
/// opens the shared timeframe selector and updates the detail range
/// (VAL-STAT-016); the filter icon is present for visual parity only and does
/// not expose unsupported features (VAL-STAT-015).
class StructureDetailScreen extends ConsumerWidget {
  const StructureDetailScreen({super.key});

  Future<void> _pickTimeframe(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(periodControllerProvider.notifier);
    final current = ref.read(periodControllerProvider).timeframe;
    final selected = await TimeframeSelector.show(context, current);
    if (selected != null) {
      controller.selectTimeframe(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(periodControllerProvider);
    final type = ref.watch(structureDetailTypeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey('structure-back'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Structure'),
        actions: [
          IconButton(
            key: const ValueKey('structure-calendar'),
            tooltip: 'Timeframe',
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _pickTimeframe(context, ref),
          ),
          IconButton(
            key: const ValueKey('structure-filter'),
            tooltip: 'Filter',
            // Present for visual parity only; the mission does not include
            // additional filtering, so tapping is an intentional no-op and
            // never changes the computed data (VAL-STAT-015).
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous period',
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.onBackground,
                    onPressed: () =>
                        ref.read(periodControllerProvider.notifier).previous(),
                  ),
                  Expanded(
                    child: Text(
                      PeriodLabelFormatter.format(period.range),
                      key: const ValueKey('structure-period-label'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next period',
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.onBackground,
                    onPressed: () =>
                        ref.read(periodControllerProvider.notifier).next(),
                  ),
                ],
              ),
            ),
            _StructureTabs(
              selected: type,
              onSelected: (t) =>
                  ref.read(structureDetailTypeProvider.notifier).select(t),
            ),
            const SizedBox(height: 8),
            Expanded(child: _StructureBody(type: type)),
          ],
        ),
      ),
    );
  }
}

/// Income/Expense tab strip for Structure detail.
///
/// Selecting a tab switches which type's independently-computed statistics are
/// shown (VAL-STAT-007). The selected tab is underlined and colored.
class _StructureTabs extends StatelessWidget {
  const _StructureTabs({required this.selected, required this.onSelected});

  final TransactionType selected;
  final ValueChanged<TransactionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Tab(
            label: 'Income',
            valueKey: 'structure-tab-income',
            active: selected.isIncome,
            onTap: () => onSelected(TransactionType.income),
          ),
        ),
        Expanded(
          child: _Tab(
            label: 'Expense',
            valueKey: 'structure-tab-expense',
            active: selected.isExpense,
            onTap: () => onSelected(TransactionType.expense),
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.valueKey,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String valueKey;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          key: ValueKey(valueKey),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? AppColors.onBackground : Colors.white60,
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Chart + category breakdown body for the selected [type].
///
/// Reads the family-keyed [structureDetailCategorySummaryProvider] so each tab
/// resolves its own rows and both recompute on period/timeframe changes
/// (VAL-STAT-007, VAL-STAT-014, VAL-STAT-016). An empty period yields the chart
/// zero state and no category rows (VAL-STAT-009).
class _StructureBody extends ConsumerWidget {
  const _StructureBody({required this.type});

  final TransactionType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref
        .watch(structureDetailCategorySummaryProvider(type))
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <StatisticCategorySummary>[],
        );
    final totalAmount = rows.fold<int>(0, (sum, row) => sum + row.amount);

    return ListView(
      key: ValueKey('structure-list-${type.name}'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: StructureChart(
            rows: rows,
            mode: StatChartMode.donut,
            type: type,
            totalAmount: totalAmount,
            showLegend: false,
          ),
        ),
        const SizedBox(height: 8),
        for (final row in rows) StructureCategoryRow(row: row, type: type),
      ],
    );
  }
}
