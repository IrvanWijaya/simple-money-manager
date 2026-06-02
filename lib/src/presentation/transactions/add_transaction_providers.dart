import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/di/use_case_providers.dart';
import '../../domain/entities/wallet_display.dart';
import '../calendar/calendar_providers.dart';
import '../recurring/recurring_selection.dart';
import '../shared/period/period_providers.dart';
import '../statistics/statistic_providers.dart';
import '../wallet/wallet_providers.dart';
import 'add_transaction_controller.dart';
import 'add_transaction_draft.dart';
import 'transaction_providers.dart';

/// Generates stable unique transaction ids. Overridable in tests for
/// deterministic assertions.
final transactionIdGeneratorProvider = Provider<String Function()>((ref) {
  const uuid = Uuid();
  return uuid.v4;
});

/// Holds the Add Transaction form draft for a single open form instance.
///
/// `autoDispose` so each time the Add Transaction screen opens it starts from a
/// fresh Expense draft (VAL-ADD-001) and discards any abandoned draft when the
/// form closes without saving (VAL-ADD-010). The family argument seeds the
/// initial recurring configuration, so the Wallet `+ Add Recurring` entry point
/// can open the form already in recurring-creation mode (VAL-RECUI-008/009)
/// while the regular Add Transaction entry uses [RecurringSelection.none].
final addTransactionControllerProvider = StateNotifierProvider.autoDispose
    .family<AddTransactionController, AddTransactionDraft, RecurringSelection>((
      ref,
      initialRecurring,
    ) {
      return AddTransactionController(
        addTransaction: ref.watch(addTransactionProvider),
        saveRecurringRule: ref.watch(saveRecurringRuleProvider),
        generateDueRecurringTransactions: ref.watch(
          generateDueRecurringTransactionsProvider,
        ),
        idGenerator: ref.watch(transactionIdGeneratorProvider),
        initialRecurring: initialRecurring,
      );
    });

/// The single wallet's name and computed current balance, for the display-only
/// wallet row (`Cash · <balance>`). Recomputes when transactions change.
final addTransactionWalletDisplayProvider = FutureProvider<WalletDisplay>((
  ref,
) async {
  return ref.watch(getWalletDisplayProvider).call();
});

/// Invalidates every transaction-derived read after a successful save so the
/// balance, period summary, transaction list, calendar totals, wallet balance,
/// recurring-rule list, and Statistic surfaces recompute immediately without an
/// app restart (VAL-ADD-008, VAL-CROSS-001/002, VAL-RECUI-009).
///
/// The Statistic home opening/ending balance row, period overview, and Expense
/// Structure chart/legend are derived from their own statistic providers, so
/// they must be invalidated here too; otherwise the Structure card keeps stale
/// category totals after a save even though the Transaction overview updates.
void refreshTransactionDerivedData(WidgetRef ref) {
  ref.invalidate(currentBalanceProvider);
  ref.invalidate(activePeriodSummaryProvider);
  ref.invalidate(transactionDateGroupsProvider);
  ref.invalidate(calendarDayTotalsProvider);
  ref.invalidate(addTransactionWalletDisplayProvider);
  ref.invalidate(dueRecurringGenerationProvider);
  ref.invalidate(recurringRuleViewsProvider);
  ref.invalidate(statisticOverviewProvider);
  ref.invalidate(statHomeCategorySummaryProvider);
  ref.invalidate(structureDetailCategorySummaryProvider);
}
