import '../entities/recurring_rule.dart';
import '../repositories/recurring_repository.dart';

/// Returns all saved recurring rules in deterministic display order.
class GetRecurringRules {
  const GetRecurringRules(this._repository);

  final RecurringRepository _repository;

  Future<List<RecurringRule>> call() {
    return _repository.getAllRules();
  }
}
