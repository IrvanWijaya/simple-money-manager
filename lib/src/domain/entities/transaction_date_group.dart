import 'money_transaction.dart';

/// A set of transactions sharing the same calendar day, with a computed total.
///
/// Used by the transaction home list to render date headers. This is a derived
/// value object and is never persisted. [date] is the day key (time normalized
/// to midnight) and [signedTotal] is the sum of every transaction's signed
/// amount (income positive, expense negative).
class TransactionDateGroup {
  const TransactionDateGroup({required this.date, required this.transactions});

  /// The calendar day (local, midnight) shared by [transactions].
  final DateTime date;

  /// Transactions for [date], ordered as supplied by the use case.
  final List<MoneyTransaction> transactions;

  /// Sum of signed amounts for the visible transactions in this group.
  int get signedTotal => transactions.fold(0, (sum, t) => sum + t.signedAmount);

  @override
  bool operator ==(Object other) =>
      other is TransactionDateGroup &&
      other.date == date &&
      _listEquals(other.transactions, transactions);

  @override
  int get hashCode => Object.hash(date, Object.hashAll(transactions));

  @override
  String toString() =>
      'TransactionDateGroup($date, ${transactions.length} txns, '
      'total: $signedTotal)';

  static bool _listEquals(List<MoneyTransaction> a, List<MoneyTransaction> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
