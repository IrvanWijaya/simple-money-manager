import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/database_providers.dart';
import '../../core/di/use_case_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_date_group.dart';
import '../shared/period/period_controller.dart';

/// Ensures due recurring occurrences have been materialized as transactions.
///
/// Runs the idempotent [generateDueRecurringTransactionsProvider] generator
/// once (cached by Riverpod). Because generation keys each occurrence by
/// `ruleId@instant` and skips existing keys, awaiting this repeatedly — or
/// across app relaunches — never creates duplicate rows (VAL-TXNHOME-006).
final dueRecurringGenerationProvider = FutureProvider<void>((ref) async {
  await ref.watch(generateDueRecurringTransactionsProvider).call();
});

/// All categories indexed by id, for resolving a transaction's (or recurring
/// rule's) display name and icon. Awaits [dataInitializationProvider] so the
/// built-in seeds exist before reading, keeping the map reliably populated even
/// on surfaces mounted without the app root (for example widget tests). Loaded
/// once and reused across rows.
final categoriesByIdProvider = FutureProvider<Map<String, Category>>((
  ref,
) async {
  await ref.watch(dataInitializationProvider.future);
  final categories = await ref.watch(categoryRepositoryProvider).getAll();
  return {for (final category in categories) category.id: category};
});

/// Date-grouped transactions for the active shared period, newest day first.
///
/// Awaits [dueRecurringGenerationProvider] so any due recurring occurrence is
/// visible, then watches [activePeriodRangeProvider] and delegates grouping and
/// per-day totals to [getTransactionDateGroupsProvider]. Groups are ordered
/// newest-to-oldest and transactions within a group keep the repository's
/// date-descending order (VAL-TXNHOME-002, -003, -007).
final transactionDateGroupsProvider =
    FutureProvider<List<TransactionDateGroup>>((ref) async {
      await ref.watch(dueRecurringGenerationProvider.future);
      final range = ref.watch(activePeriodRangeProvider);
      return ref.watch(getTransactionDateGroupsProvider).call(range);
    });
