import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/period_label_formatter.dart';
import 'period_controller.dart';
import 'period_providers.dart';
import 'timeframe_selector.dart';

/// Shared top header for the Transaction, Calendar, and Statistic surfaces.
///
/// Shows the all-time current balance, the active period label with
/// previous/next controls, the calendar/timeframe action, and a settings icon.
/// All period interactions delegate to [periodControllerProvider] so the three
/// surfaces stay synchronized. The displayed balance comes from
/// [currentBalanceProvider] and stays stable across period changes.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key, this.leadingActions = const []});

  /// Extra action widgets rendered before the timeframe/settings icons.
  ///
  /// The Statistic surface uses this to add its chart-type toggle while
  /// reusing the same shared balance/period header.
  final List<Widget> leadingActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(periodControllerProvider);
    final balance = ref.watch(currentBalanceProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    balance.when(
                      data: (value) => Text(
                        MoneyFormatter.format(value),
                        key: const ValueKey('current-balance'),
                        style: const TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 28,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (_, _) => Text(
                        MoneyFormatter.format(0),
                        style: const TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...leadingActions,
              IconButton(
                tooltip: 'Timeframe',
                icon: const Icon(Icons.calendar_today_outlined),
                color: AppColors.onBackground,
                onPressed: () => _openTimeframeSelector(context, ref),
              ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                color: AppColors.onBackground,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
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
                  key: const ValueKey('period-label'),
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
        ],
      ),
    );
  }

  Future<void> _openTimeframeSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final current = ref.read(periodControllerProvider).timeframe;
    final selected = await TimeframeSelector.show(context, current);
    if (selected != null) {
      ref.read(periodControllerProvider.notifier).selectTimeframe(selected);
    }
  }
}
