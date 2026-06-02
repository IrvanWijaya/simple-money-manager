/// The kind of money movement a transaction represents.
///
/// The app supports only income and expense; transfers are out of scope.
enum TransactionType {
  income,
  expense;

  bool get isIncome => this == TransactionType.income;

  bool get isExpense => this == TransactionType.expense;
}
