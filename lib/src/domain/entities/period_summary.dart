import 'money_transaction.dart';

/// Computed income/expense totals for a period.
///
/// This is a derived value object, never persisted. [income] is a non-negative
/// total of income amounts, [expense] is a non-negative total of expense
/// magnitudes, and [total] is the signed net (`income - expense`).
class PeriodSummary {
  const PeriodSummary({this.income = 0, this.expense = 0});

  /// Sums the given [transactions] into income and expense totals.
  ///
  /// Income amounts add to [income] and expense magnitudes add to [expense].
  /// Both stay non-negative because [MoneyTransaction.amount] is a magnitude;
  /// the sign is read from [MoneyTransaction.type], never from the amount.
  factory PeriodSummary.fromTransactions(
    Iterable<MoneyTransaction> transactions,
  ) {
    var income = 0;
    var expense = 0;
    for (final transaction in transactions) {
      if (transaction.type.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
    return PeriodSummary(income: income, expense: expense);
  }

  /// Non-negative sum of income amounts in whole Rupiah.
  final int income;

  /// Non-negative sum of expense magnitudes in whole Rupiah.
  final int expense;

  /// Signed net total: income minus expense.
  int get total => income - expense;

  bool get isEmpty => income == 0 && expense == 0;

  PeriodSummary copyWith({int? income, int? expense}) => PeriodSummary(
    income: income ?? this.income,
    expense: expense ?? this.expense,
  );

  @override
  bool operator ==(Object other) =>
      other is PeriodSummary &&
      other.income == income &&
      other.expense == expense;

  @override
  int get hashCode => Object.hash(income, expense);

  @override
  String toString() =>
      'PeriodSummary(income: $income, expense: $expense, total: $total)';
}
