import 'package:drift/drift.dart';

import '../../domain/entities/recurring_rule.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../internal/dao/recurring_dao.dart';
import '../internal/database/app_database.dart';
import '../internal/mapper/recurring_mapper.dart';

/// Drift-backed [RecurringRepository]. Exposes only domain entities and keeps
/// generated-occurrence metadata idempotent via the underlying DAO.
class RecurringRepositoryImpl implements RecurringRepository {
  RecurringRepositoryImpl(this._dao);

  final RecurringDao _dao;

  @override
  Future<void> saveRule(RecurringRule rule) {
    return _dao.upsertRule(rule.toCompanion());
  }

  @override
  Future<void> deleteRule(String id) {
    return _dao.deleteRule(id);
  }

  @override
  Future<RecurringRule?> getRuleById(String id) async {
    final row = await _dao.getRuleById(id);
    return row?.toDomain();
  }

  @override
  Future<List<RecurringRule>> getAllRules() async {
    final rows = await _dao.getAllRules();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Set<String>> getGeneratedOccurrenceKeys(String ruleId) async {
    final rows = await _dao.getOccurrencesForRule(ruleId);
    return rows.map((r) => r.occurrenceKey).toSet();
  }

  @override
  Future<void> recordGeneratedOccurrence({
    required String ruleId,
    required String occurrenceKey,
    required String transactionId,
    required DateTime occurrenceDate,
  }) {
    return _dao.recordOccurrence(
      RecurringOccurrencesCompanion(
        ruleId: Value(ruleId),
        occurrenceKey: Value(occurrenceKey),
        transactionId: Value(transactionId),
        occurrenceDate: Value(occurrenceDate),
        generatedAt: Value(DateTime.now()),
      ),
    );
  }
}
