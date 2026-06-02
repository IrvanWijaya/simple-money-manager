import '../entities/money_transaction.dart';
import '../entities/period_range.dart';
import '../entities/transaction_date_group.dart';
import '../repositories/transaction_repository.dart';

/// Groups the transactions in [range] by calendar day, with a computed total
/// per group.
///
/// Groups are ordered by day descending (most recent first); transactions
/// within each group preserve the repository ordering (date descending then
/// id). Each group's [TransactionDateGroup.signedTotal] is the sum of the
/// visible transactions' signed amounts.
class GetTransactionDateGroups {
  const GetTransactionDateGroups(this._repository);

  final TransactionRepository _repository;

  Future<List<TransactionDateGroup>> call(PeriodRange range) async {
    final transactions = await _repository.getByDateRange(
      range.start,
      range.end,
    );

    final groups = <DateTime, List<MoneyTransaction>>{};
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groups.putIfAbsent(day, () => <MoneyTransaction>[]).add(transaction);
    }

    final orderedDays = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return [
      for (final day in orderedDays)
        TransactionDateGroup(date: day, transactions: groups[day]!),
    ];
  }
}
