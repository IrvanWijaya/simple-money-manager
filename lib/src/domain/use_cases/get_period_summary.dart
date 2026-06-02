import '../entities/period_range.dart';
import '../entities/period_summary.dart';
import '../repositories/transaction_repository.dart';

/// Computes the income/expense/total [PeriodSummary] for a [PeriodRange].
///
/// Only transactions within the inclusive period range contribute. The summary
/// is computed dynamically and never persisted.
class GetPeriodSummary {
  const GetPeriodSummary(this._repository);

  final TransactionRepository _repository;

  Future<PeriodSummary> call(PeriodRange range) async {
    final transactions = await _repository.getByDateRange(
      range.start,
      range.end,
    );
    return PeriodSummary.fromTransactions(transactions);
  }
}
