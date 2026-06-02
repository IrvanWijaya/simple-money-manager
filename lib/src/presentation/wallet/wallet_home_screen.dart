import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/recurring_frequency.dart';
import '../../domain/use_cases/get_recurring_rule_views.dart';
import '../recurring/recurring_selection.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_providers.dart';
import 'widgets/recurring_rule_row.dart';
import 'wallet_providers.dart';

/// Wallet tab surface, scoped to recurring settings only.
///
/// Shows a recurring-focused header with a settings icon, a RECURRING section
/// with a Manage(count) action matching the number of active rules, saved
/// recurring entries (category/title, next occurrence, signed amount), and a
/// `+ Add Recurring` row that starts recurring creation. No Budget, Goal, Debt,
/// or multiple-wallet controls are exposed (VAL-RECUI-005, -006, -007, -008,
/// -012).
class WalletHomeScreen extends ConsumerWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(recurringRuleViewsProvider);
    final categories = ref
        .watch(categoriesByIdProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <String, Category>{},
        );

    final views = viewsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <RecurringRuleView>[],
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _WalletHeader(),
          _RecurringSectionHeader(count: views.length),
          const Divider(height: 1, color: AppColors.surface),
          Expanded(
            child: ListView(
              key: const ValueKey('wallet-recurring-list'),
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final view in views)
                  RecurringRuleRow(
                    rule: view.rule,
                    category: categories[view.rule.categoryId],
                    nextOccurrence: view.nextOccurrence,
                  ),
                const _AddRecurringRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wallet header: title plus a settings icon (recurring-focused, no period or
/// balance controls).
class _WalletHeader extends StatelessWidget {
  const _WalletHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Wallet',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.onBackground,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// `RECURRING` section title with a `Manage(count)` action.
class _RecurringSectionHeader extends StatelessWidget {
  const _RecurringSectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'RECURRING',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Text(
            'Manage($count)',
            key: const ValueKey('wallet-recurring-manage'),
            style: const TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// `+ Add Recurring` entry point that starts the recurring creation path.
///
/// Reuses the Add Transaction recurring-creation flow, opening it with a
/// recurring default (monthly) so the form starts in recurring-creation mode;
/// it never exposes multiple-wallet selection (VAL-RECUI-008, -009).
class _AddRecurringRow extends StatelessWidget {
  const _AddRecurringRow();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('wallet-add-recurring'),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => const AddTransactionScreen(
            initialRecurring: RecurringSelection(
              frequency: RecurringFrequency.monthly,
            ),
          ),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.add, size: 20, color: AppColors.primary),
            SizedBox(width: 12),
            Text(
              'Add Recurring',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
