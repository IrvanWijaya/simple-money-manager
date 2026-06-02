import '../entities/money_transaction.dart';
import '../entities/recurring_rule.dart';
import '../repositories/recurring_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/recurring_schedule.dart';

/// Generates the transactions that are due for every recurring rule up to a
/// cutoff instant, idempotently.
///
/// For each rule, the [RecurringSchedule] engine computes occurrence dates from
/// the start date through [asOf] (honoring interval, repeat position, and end
/// condition). The initial occurrence (the start date) counts as occurrence 1,
/// so a count of `N` produces exactly `N` transactions.
///
/// Idempotency: each occurrence has a stable key (`ruleId@instant`). An
/// occurrence already recorded in the repository is skipped, and the generated
/// transaction id is the occurrence key itself, so re-running generation never
/// creates duplicate transactions.
///
/// Field preservation: each generated transaction copies the rule's type,
/// amount, category, description, and memo, links back via
/// [MoneyTransaction.recurringRuleId] and [MoneyTransaction.occurrenceKey], and
/// uses the computed occurrence date/time.
class GenerateDueRecurringTransactions {
  const GenerateDueRecurringTransactions(
    this._recurringRepository,
    this._transactionRepository,
  );

  final RecurringRepository _recurringRepository;
  final TransactionRepository _transactionRepository;

  /// Generates due transactions for all rules and returns the transactions
  /// created during this run (excludes occurrences already present).
  Future<List<MoneyTransaction>> call({DateTime? asOf}) async {
    final cutoff = asOf ?? DateTime.now();
    final rules = await _recurringRepository.getAllRules();
    final created = <MoneyTransaction>[];
    for (final rule in rules) {
      created.addAll(await _generateForRule(rule, cutoff));
    }
    return created;
  }

  /// Generates due transactions for a single [rule]. Useful right after saving
  /// a rule so its due occurrences appear immediately.
  Future<List<MoneyTransaction>> generateForRule(
    RecurringRule rule, {
    DateTime? asOf,
  }) {
    return _generateForRule(rule, asOf ?? DateTime.now());
  }

  Future<List<MoneyTransaction>> _generateForRule(
    RecurringRule rule,
    DateTime cutoff,
  ) async {
    final schedule = RecurringSchedule(rule);
    final occurrences = schedule.occurrencesUntil(cutoff);
    final existingKeys = await _recurringRepository.getGeneratedOccurrenceKeys(
      rule.id,
    );

    final created = <MoneyTransaction>[];
    for (final date in occurrences) {
      final key = schedule.occurrenceKeyFor(date);
      if (existingKeys.contains(key)) continue;

      final transaction = MoneyTransaction(
        id: key,
        type: rule.type,
        amount: rule.amount,
        date: date,
        categoryId: rule.categoryId,
        description: rule.description,
        memo: rule.memo,
        recurringRuleId: rule.id,
        occurrenceKey: key,
        createdAt: cutoff,
        updatedAt: cutoff,
      );

      await _transactionRepository.add(transaction);
      await _recurringRepository.recordGeneratedOccurrence(
        ruleId: rule.id,
        occurrenceKey: key,
        transactionId: transaction.id,
        occurrenceDate: date,
      );
      // Guard against duplicate occurrence dates within a single run.
      existingKeys.add(key);
      created.add(transaction);
    }
    return created;
  }
}
