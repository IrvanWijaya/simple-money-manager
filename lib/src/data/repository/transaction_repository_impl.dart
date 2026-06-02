import '../../domain/entities/money_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../internal/dao/transaction_dao.dart';
import '../internal/mapper/transaction_mapper.dart';

/// Drift-backed [TransactionRepository]. Exposes only domain entities.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dao);

  final TransactionDao _dao;

  @override
  Future<void> add(MoneyTransaction transaction) {
    return _dao.upsert(transaction.toCompanion());
  }

  @override
  Future<void> update(MoneyTransaction transaction) {
    return _dao.upsert(transaction.toCompanion());
  }

  @override
  Future<void> delete(String id) {
    return _dao.deleteById(id);
  }

  @override
  Future<MoneyTransaction?> getById(String id) async {
    final row = await _dao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<List<MoneyTransaction>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<MoneyTransaction>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _dao.getByDateRange(start, end);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<MoneyTransaction>> watchAll() {
    return _dao.watchAll().map(
      (rows) => rows.map((r) => r.toDomain()).toList(),
    );
  }
}
