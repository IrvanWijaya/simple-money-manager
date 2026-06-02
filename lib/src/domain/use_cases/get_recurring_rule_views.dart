import '../entities/recurring_rule.dart';
import '../repositories/recurring_repository.dart';
import '../services/recurring_schedule.dart';

/// A recurring rule paired with its upcoming occurrence date for display.
///
/// [nextOccurrence] is the first occurrence on or after the reference instant,
/// or `null` when the rule has already ended (count/end-date exhausted).
class RecurringRuleView {
  const RecurringRuleView({required this.rule, required this.nextOccurrence});

  final RecurringRule rule;
  final DateTime? nextOccurrence;
}

/// Returns all saved recurring rules with their next occurrence computed,
/// in the repository's deterministic display order.
///
/// The next occurrence is derived purely from the [RecurringSchedule] engine
/// relative to the provided reference (defaults to now), so the Wallet surface
/// can show each rule's upcoming date without materializing transactions.
class GetRecurringRuleViews {
  const GetRecurringRuleViews(this._repository);

  final RecurringRepository _repository;

  Future<List<RecurringRuleView>> call({DateTime? asOf}) async {
    final reference = asOf ?? DateTime.now();
    final rules = await _repository.getAllRules();
    return rules
        .map(
          (rule) => RecurringRuleView(
            rule: rule,
            nextOccurrence: RecurringSchedule(
              rule,
            ).nextOccurrenceOnOrAfter(reference),
          ),
        )
        .toList();
  }
}
