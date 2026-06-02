import 'period_summary.dart';

/// Computed balance-and-summary overview for the Statistic surface.
///
/// Derived value object, never persisted. [openingBalance] is the wallet
/// balance at the instant before the period starts (base balance plus the
/// signed total of every transaction before the period). [endingBalance] is the
/// [openingBalance] plus the period's signed [total]. [income], [expense], and
/// [total] mirror the period's [PeriodSummary].
class StatisticOverview {
  const StatisticOverview({
    required this.openingBalance,
    required this.income,
    required this.expense,
  });

  /// Wallet balance immediately before the period starts, in whole Rupiah.
  final int openingBalance;

  /// Non-negative sum of income amounts in the period, in whole Rupiah.
  final int income;

  /// Non-negative sum of expense magnitudes in the period, in whole Rupiah.
  final int expense;

  /// Signed net total for the period: income minus expense.
  int get total => income - expense;

  /// Wallet balance at the end of the period: opening plus period total.
  int get endingBalance => openingBalance + total;

  /// The period income/expense summary backing this overview.
  PeriodSummary get summary => PeriodSummary(income: income, expense: expense);

  bool get isEmpty => income == 0 && expense == 0;

  @override
  bool operator ==(Object other) =>
      other is StatisticOverview &&
      other.openingBalance == openingBalance &&
      other.income == income &&
      other.expense == expense;

  @override
  int get hashCode => Object.hash(openingBalance, income, expense);

  @override
  String toString() =>
      'StatisticOverview(opening: $openingBalance, income: $income, '
      'expense: $expense, ending: $endingBalance)';
}
