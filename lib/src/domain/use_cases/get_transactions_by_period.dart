import '../entities/money_transaction.dart';
import '../entities/period_range.dart';
import '../repositories/transaction_repository.dart';

/// Returns the transactions whose date falls within [range], inclusive.
///
/// Filtering uses the repository date-range query, which honors the inclusive
/// `[start, end]` boundaries of the [PeriodRange]. Results are ordered by date
/// descending then id for deterministic rendering.
class GetTransactionsByPeriod {
  const GetTransactionsByPeriod(this._repository);

  final TransactionRepository _repository;

  Future<List<MoneyTransaction>> call(PeriodRange range) {
    return _repository.getByDateRange(range.start, range.end);
  }
}
