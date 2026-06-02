import '../entities/money_transaction.dart';
import '../repositories/transaction_repository.dart';

/// Persists a new [MoneyTransaction].
///
/// The transaction's non-negative amount invariant is enforced by the
/// [MoneyTransaction] constructor, so this use case simply delegates to the
/// repository. The sign shown to the user is derived from the transaction
/// [type], never from user-entered punctuation.
class AddTransaction {
  const AddTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(MoneyTransaction transaction) {
    return _repository.add(transaction);
  }
}
