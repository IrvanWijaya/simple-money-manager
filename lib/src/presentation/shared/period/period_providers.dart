import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/use_case_providers.dart';
import '../../../domain/entities/period_summary.dart';
import 'period_controller.dart';

/// The all-time current default-wallet balance.
///
/// Computed from the base balance plus every signed transaction, independent of
/// the active period. It only changes when transactions are added or removed,
/// so it stays stable while the user changes timeframe or navigates periods
/// (VAL-HDR-006).
final currentBalanceProvider = FutureProvider<int>((ref) async {
  return ref.watch(getDefaultWalletBalanceProvider).call();
});

/// The income/expense/total summary for the active shared period.
///
/// Recomputes whenever the active period changes, so the Transaction, Calendar,
/// and Statistic overviews stay in sync (VAL-HDR-004, VAL-HDR-005). Returns
/// zeros for an empty period because no transactions contribute.
final activePeriodSummaryProvider = FutureProvider<PeriodSummary>((ref) async {
  final range = ref.watch(activePeriodRangeProvider);
  return ref.watch(getPeriodSummaryProvider).call(range);
});
