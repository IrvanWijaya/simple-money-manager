import '../entities/money_transaction.dart';
import '../repositories/transaction_repository.dart';

/// Updates an existing [MoneyTransaction].
class UpdateTransaction {
  const UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(MoneyTransaction transaction) {
    return _repository.update(transaction);
  }
}
