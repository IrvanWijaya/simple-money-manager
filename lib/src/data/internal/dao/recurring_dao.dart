import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

part 'recurring_dao.g.dart';

/// Data access for the [RecurringRules] and [RecurringOccurrences] tables.
///
/// This feature establishes the storage and idempotency primitives. The
/// recurring-engine feature builds rule mapping and due-generation on top of
/// these methods.
@DriftAccessor(tables: [RecurringRules, RecurringOccurrences])
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {
  RecurringDao(super.db);

  Future<void> upsertRule(RecurringRulesCompanion row) {
    return into(recurringRules).insertOnConflictUpdate(row);
  }

  Future<void> deleteRule(String id) {
    return (delete(recurringRules)..where((t) => t.id.equals(id))).go();
  }

  Future<RecurringRuleRow?> getRuleById(String id) {
    return (select(
      recurringRules,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<RecurringRuleRow>> getAllRules() {
    return (select(recurringRules)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt),
          (t) => OrderingTerm(expression: t.id),
        ]))
        .get();
  }

  /// Whether an occurrence has already been generated for [ruleId] +
  /// [occurrenceKey]. Used to keep generation idempotent.
  Future<bool> occurrenceExists(String ruleId, String occurrenceKey) async {
    final row =
        await (select(recurringOccurrences)..where(
              (t) =>
                  t.ruleId.equals(ruleId) &
                  t.occurrenceKey.equals(occurrenceKey),
            ))
            .getSingleOrNull();
    return row != null;
  }

  /// Records a generated occurrence. Ignores duplicates so concurrent or
  /// repeated generation cannot create duplicate metadata rows.
  Future<void> recordOccurrence(RecurringOccurrencesCompanion row) {
    return into(
      recurringOccurrences,
    ).insert(row, mode: InsertMode.insertOrIgnore);
  }

  Future<List<RecurringOccurrenceRow>> getOccurrencesForRule(String ruleId) {
    return (select(recurringOccurrences)
          ..where((t) => t.ruleId.equals(ruleId))
          ..orderBy([(t) => OrderingTerm(expression: t.occurrenceDate)]))
        .get();
  }
}
