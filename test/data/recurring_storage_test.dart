import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';

import 'helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('stores and reloads a recurring rule', () async {
    await db.recurringDao.upsertRule(
      RecurringRulesCompanion.insert(
        id: 'rule-1',
        type: 1,
        amount: 5000,
        categoryId: 'expense_bills',
        frequency: 3,
        endCondition: 0,
        startDate: DateTime(2026, 6, 1),
      ),
    );

    final rule = await db.recurringDao.getRuleById('rule-1');
    expect(rule, isNotNull);
    expect(rule!.amount, 5000);
    expect(rule.frequency, 3);

    final all = await db.recurringDao.getAllRules();
    expect(all.length, 1);
  });

  test('occurrence metadata is idempotent by ruleId + occurrenceKey', () async {
    const key = 'rule-1@2026-06-01T00:00:00.000';

    expect(await db.recurringDao.occurrenceExists('rule-1', key), isFalse);

    await db.recurringDao.recordOccurrence(
      RecurringOccurrencesCompanion.insert(
        ruleId: 'rule-1',
        occurrenceKey: key,
        transactionId: 'tx-1',
        occurrenceDate: DateTime(2026, 6, 1),
      ),
    );

    expect(await db.recurringDao.occurrenceExists('rule-1', key), isTrue);

    // Re-recording the same occurrence must not create a duplicate row or
    // throw, keeping generation idempotent.
    await db.recurringDao.recordOccurrence(
      RecurringOccurrencesCompanion.insert(
        ruleId: 'rule-1',
        occurrenceKey: key,
        transactionId: 'tx-1-dup',
        occurrenceDate: DateTime(2026, 6, 1),
      ),
    );

    final occurrences = await db.recurringDao.getOccurrencesForRule('rule-1');
    expect(occurrences.length, 1);
    // First write wins (insertOrIgnore), proving no duplicate overwrite.
    expect(occurrences.single.transactionId, 'tx-1');
  });
}
