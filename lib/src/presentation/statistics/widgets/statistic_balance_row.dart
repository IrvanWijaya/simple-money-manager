import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/statistic_overview.dart';
import '../statistic_providers.dart';

/// Opening/ending balance row for the Statistic surface.
///
/// Reads [statisticOverviewProvider] so opening and ending balance recompute
/// whenever the active period changes (VAL-STAT-001, VAL-STAT-002). Shows a
/// stable zero-derived state for empty periods rather than stale values.
class StatisticBalanceRow extends ConsumerWidget {
  const StatisticBalanceRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref
        .watch(statisticOverviewProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () =>
              const StatisticOverview(openingBalance: 0, income: 0, expense: 0),
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _BalanceColumn(
            label: 'Opening Balance',
            value: overview.openingBalance,
            valueKey: 'stat-opening-balance',
          ),
          _BalanceColumn(
            label: 'Ending Balance',
            value: overview.endingBalance,
            valueKey: 'stat-ending-balance',
          ),
        ],
      ),
    );
  }
}

class _BalanceColumn extends StatelessWidget {
  const _BalanceColumn({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final int value;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.onBackground, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            MoneyFormatter.format(value),
            key: ValueKey(valueKey),
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
