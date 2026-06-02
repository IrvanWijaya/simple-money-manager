import '../entities/recurring_rule.dart';

/// Persistence boundary for recurring rules and their generated-occurrence
/// idempotency metadata.
///
/// Implementations expose only domain [RecurringRule] entities. The set of
/// already-generated occurrence keys is exposed so the generation use case can
/// avoid producing duplicate transactions; the metadata itself is recorded via
/// [recordGeneratedOccurrence].
abstract interface class RecurringRepository {
  /// Inserts a new rule (or replaces one with the same id).
  Future<void> saveRule(RecurringRule rule);

  /// Deletes the rule with [id] (occurrence metadata is left intact so prior
  /// generated transactions remain accounted for).
  Future<void> deleteRule(String id);

  /// The rule with [id], or `null` when none exists.
  Future<RecurringRule?> getRuleById(String id);

  /// All rules ordered by creation time then id for deterministic display.
  Future<List<RecurringRule>> getAllRules();

  /// The occurrence keys already generated for [ruleId]. Used to keep
  /// generation idempotent.
  Future<Set<String>> getGeneratedOccurrenceKeys(String ruleId);

  /// Records that [occurrenceKey] for [ruleId] produced [transactionId] on
  /// [occurrenceDate]. Idempotent: recording the same key twice does not create
  /// a duplicate.
  Future<void> recordGeneratedOccurrence({
    required String ruleId,
    required String occurrenceKey,
    required String transactionId,
    required DateTime occurrenceDate,
  });
}
