import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction_date_group.dart';
import '../transaction_providers.dart';
import 'transaction_date_group_header.dart';
import 'transaction_row.dart';

/// Date-grouped transaction list for the active period.
///
/// Watches [transactionDateGroupsProvider] (which already triggers idempotent
/// due-recurring generation) and renders groups newest-day-first with a
/// computed per-day total header, then the day's transactions in
/// date-descending order. Shows a readable empty state when the active period
/// has no transactions (VAL-TXNHOME-002, -003, -007).
class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(transactionDateGroupsProvider);
    final categories = ref
        .watch(categoriesByIdProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <String, Category>{},
        );

    return groupsAsync.when(
      // Keep showing the already-rendered list while the provider reloads after
      // a save (refreshTransactionDerivedData invalidates this provider). The
      // Transaction home stays mounted under the pushed Add screen, so without
      // this the list would briefly swap to a spinner/empty state and flash a
      // transient blank frame before the new data resolves. Preserving prior
      // content during reload removes that flicker (the list still repopulates
      // with the new transaction once the recompute completes).
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _EmptyTransactions(),
      data: (groups) {
        if (groups.isEmpty) {
          return const _EmptyTransactions();
        }
        return ListView.builder(
          key: const ValueKey('transaction-list'),
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return _DateGroupSection(group: group, categories: categories);
          },
        );
      },
    );
  }
}

class _DateGroupSection extends StatelessWidget {
  const _DateGroupSection({required this.group, required this.categories});

  final TransactionDateGroup group;
  final Map<String, Category> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TransactionDateGroupHeader(group: group),
        const Divider(height: 1, color: AppColors.surface),
        for (final transaction in group.transactions)
          TransactionRow(
            transaction: transaction,
            category: categories[transaction.categoryId],
          ),
      ],
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('transaction-empty-state'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.onBackground,
          ),
          SizedBox(height: 12),
          Text(
            'No transactions in this period',
            style: TextStyle(color: AppColors.onBackground, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
