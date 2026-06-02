import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/use_cases/use_cases.dart';
import 'database_providers.dart';

/// Use-case providers for transaction CRUD, period summaries, date group
/// totals, and wallet balance/display. Each depends on repository providers
/// from `database_providers.dart`.

final addTransactionProvider = Provider<AddTransaction>((ref) {
  return AddTransaction(ref.watch(transactionRepositoryProvider));
});

final updateTransactionProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});

final getTransactionsByPeriodProvider = Provider<GetTransactionsByPeriod>((
  ref,
) {
  return GetTransactionsByPeriod(ref.watch(transactionRepositoryProvider));
});

final getPeriodSummaryProvider = Provider<GetPeriodSummary>((ref) {
  return GetPeriodSummary(ref.watch(transactionRepositoryProvider));
});

final getTransactionDateGroupsProvider = Provider<GetTransactionDateGroups>((
  ref,
) {
  return GetTransactionDateGroups(ref.watch(transactionRepositoryProvider));
});

final getCalendarDayTotalsProvider = Provider<GetCalendarDayTotals>((ref) {
  return GetCalendarDayTotals(ref.watch(transactionRepositoryProvider));
});

final getDefaultWalletBalanceProvider = Provider<GetDefaultWalletBalance>((
  ref,
) {
  return GetDefaultWalletBalance(
    ref.watch(walletRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
  );
});

final getStatisticOverviewProvider = Provider<GetStatisticOverview>((ref) {
  return GetStatisticOverview(
    ref.watch(walletRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
  );
});

final getStatisticCategorySummaryProvider =
    Provider<GetStatisticCategorySummary>((ref) {
      return GetStatisticCategorySummary(
        ref.watch(transactionRepositoryProvider),
        ref.watch(categoryRepositoryProvider),
      );
    });

final getWalletDisplayProvider = Provider<GetWalletDisplay>((ref) {
  return GetWalletDisplay(
    ref.watch(walletRepositoryProvider),
    ref.watch(transactionRepositoryProvider),
  );
});

final saveRecurringRuleProvider = Provider<SaveRecurringRule>((ref) {
  return SaveRecurringRule(ref.watch(recurringRepositoryProvider));
});

final getRecurringRulesProvider = Provider<GetRecurringRules>((ref) {
  return GetRecurringRules(ref.watch(recurringRepositoryProvider));
});

final getRecurringRuleViewsProvider = Provider<GetRecurringRuleViews>((ref) {
  return GetRecurringRuleViews(ref.watch(recurringRepositoryProvider));
});

final generateDueRecurringTransactionsProvider =
    Provider<GenerateDueRecurringTransactions>((ref) {
      return GenerateDueRecurringTransactions(
        ref.watch(recurringRepositoryProvider),
        ref.watch(transactionRepositoryProvider),
      );
    });
