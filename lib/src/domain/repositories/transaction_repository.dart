import '../entities/money_transaction.dart';

/// Persistence boundary for recorded money transactions.
///
/// Implementations expose domain [MoneyTransaction] entities only. Period
/// summaries, statistics, and date-group totals are computed by use cases from
/// the transactions returned here and are never persisted.
abstract interface class TransactionRepository {
  /// Inserts a new transaction (or replaces one with the same id).
  Future<void> add(MoneyTransaction transaction);

  /// Updates an existing transaction.
  Future<void> update(MoneyTransaction transaction);

  /// Deletes the transaction with [id].
  Future<void> delete(String id);

  /// The transaction with [id], or `null` when none exists.
  Future<MoneyTransaction?> getById(String id);

  /// All transactions ordered by date descending, then id for determinism.
  Future<List<MoneyTransaction>> getAll();

  /// Transactions whose [MoneyTransaction.date] falls within the inclusive
  /// range `[start, end]`, ordered by date descending then id.
  Future<List<MoneyTransaction>> getByDateRange(DateTime start, DateTime end);

  /// Emits the full transaction list whenever stored transactions change.
  Stream<List<MoneyTransaction>> watchAll();
}
