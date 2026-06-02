import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/period_summary.dart';
import 'period_providers.dart';

/// Income/Expense/Total overview for the active shared period.
///
/// Reads [activePeriodSummaryProvider] so it recomputes whenever the active
/// period changes and shows a zero state for empty periods. Income is shown as a
/// positive value, Expense as a negative magnitude, and Total as the signed net.
class PeriodOverview extends ConsumerWidget {
  const PeriodOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(activePeriodSummaryProvider);
    final summary = summaryAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const PeriodSummary(),
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
          _OverviewColumn(
            label: 'Income',
            value: summary.income,
            valueKey: 'overview-income',
            color: AppColors.income,
          ),
          _OverviewColumn(
            label: 'Expense',
            value: -summary.expense,
            valueKey: 'overview-expense',
            color: AppColors.expense,
          ),
          _OverviewColumn(
            label: 'Total',
            value: summary.total,
            valueKey: 'overview-total',
            color: AppColors.onBackground,
          ),
        ],
      ),
    );
  }
}

class _OverviewColumn extends StatelessWidget {
  const _OverviewColumn({
    required this.label,
    required this.value,
    required this.valueKey,
    required this.color,
  });

  final String label;
  final int value;
  final String valueKey;
  final Color color;

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
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
