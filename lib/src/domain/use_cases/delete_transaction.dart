import '../repositories/transaction_repository.dart';

/// Deletes the transaction with the given id.
class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<void> call(String id) {
    return _repository.delete(id);
  }
}
