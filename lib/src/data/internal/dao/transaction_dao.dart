import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

part 'transaction_dao.g.dart';

/// Data access for the [Transactions] table.
@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<void> upsert(TransactionsCompanion row) {
    return into(transactions).insertOnConflictUpdate(row);
  }

  Future<void> deleteById(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<TransactionRow?> getById(String id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<TransactionRow>> getAll() {
    return _ordered(select(transactions)).get();
  }

  Future<List<TransactionRow>> getByDateRange(DateTime start, DateTime end) {
    return _ordered(
      select(transactions)..where((t) => t.date.isBetweenValues(start, end)),
    ).get();
  }

  Stream<List<TransactionRow>> watchAll() {
    return _ordered(select(transactions)).watch();
  }

  /// Deterministic ordering: most recent first, id as a stable tie-breaker.
  SimpleSelectStatement<$TransactionsTable, TransactionRow> _ordered(
    SimpleSelectStatement<$TransactionsTable, TransactionRow> query,
  ) {
    return query..orderBy([
      (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.id),
    ]);
  }
}
