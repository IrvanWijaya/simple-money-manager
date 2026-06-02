import '../entities/recurring_rule.dart';
import '../repositories/recurring_repository.dart';

/// Persists a recurring rule (insert or replace by id).
class SaveRecurringRule {
  const SaveRecurringRule(this._repository);

  final RecurringRepository _repository;

  Future<void> call(RecurringRule rule) {
    return _repository.saveRule(rule);
  }
}
