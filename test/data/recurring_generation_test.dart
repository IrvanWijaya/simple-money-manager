import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/recurring_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_end_condition.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_repeat_position.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_rule.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/domain/use_cases/generate_due_recurring_transactions.dart';
import 'package:simple_money_manager/src/domain/use_cases/get_recurring_rules.dart';
import 'package:simple_money_manager/src/domain/use_cases/save_recurring_rule.dart';

import 'helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late RecurringRepositoryImpl recurringRepo;
  late TransactionRepositoryImpl transactionRepo;
  late GenerateDueRecurringTransactions generate;
  late SaveRecurringRule saveRule;
  late GetRecurringRules getRules;

  setUp(() {
    db = createTestDatabase();
    recurringRepo = RecurringRepositoryImpl(db.recurringDao);
    transactionRepo = TransactionRepositoryImpl(db.transactionDao);
    generate = GenerateDueRecurringTransactions(recurringRepo, transactionRepo);
    saveRule = SaveRecurringRule(recurringRepo);
    getRules = GetRecurringRules(recurringRepo);
  });

  tearDown(() async {
    await db.close();
  });

  RecurringRule monthlyRule() => RecurringRule(
    id: 'rule-1',
    type: TransactionType.expense,
    amount: 50000,
    categoryId: 'expense_bills',
    description: 'Rent',
    memo: 'apartment',
    frequency: RecurringFrequency.monthly,
    interval: 1,
    repeatPosition: RecurringRepeatPosition.sameDay,
    endCondition: RecurringEndCondition.count,
    endCount: 3,
    startDate: DateTime(2026, 1, 10, 8, 0),
  );

  test('save then load round-trips a rule through the repository', () async {
    await saveRule(monthlyRule());
    final rules = await getRules();
    expect(rules.length, 1);
    final loaded = rules.single;
    expect(loaded.id, 'rule-1');
    expect(loaded.amount, 50000);
    expect(loaded.frequency, RecurringFrequency.monthly);
    expect(loaded.repeatPosition, RecurringRepeatPosition.sameDay);
    expect(loaded.endCondition, RecurringEndCondition.count);
    expect(loaded.endCount, 3);
    expect(loaded.startDate, DateTime(2026, 1, 10, 8, 0));
  });

  test(
    'VAL-RECRULE-008 generation is idempotent across repeated runs',
    () async {
      await saveRule(monthlyRule());
      final cutoff = DateTime(2026, 12, 31);

      final firstRun = await generate(asOf: cutoff);
      expect(firstRun.length, 3); // count=3 including initial occurrence

      final secondRun = await generate(asOf: cutoff);
      expect(secondRun, isEmpty); // nothing new

      final all = await transactionRepo.getAll();
      expect(all.length, 3);

      // Exactly one occurrence metadata row per occurrence key.
      final keys = await recurringRepo.getGeneratedOccurrenceKeys('rule-1');
      expect(keys.length, 3);
    },
  );

  test('VAL-RECRULE-011 count includes the initial occurrence', () async {
    await saveRule(monthlyRule());
    await generate(asOf: DateTime(2026, 12, 31));
    final all = await transactionRepo.getAll();
    final dates = all.map((t) => t.date).toSet();
    expect(dates, {
      DateTime(2026, 1, 10, 8, 0), // initial occurrence counts as #1
      DateTime(2026, 2, 10, 8, 0),
      DateTime(2026, 3, 10, 8, 0),
    });
  });

  test(
    'VAL-RECRULE-014 generated transactions preserve source details',
    () async {
      await saveRule(monthlyRule());
      final created = await generate(asOf: DateTime(2026, 12, 31));
      final tx = created.firstWhere(
        (t) => t.date == DateTime(2026, 2, 10, 8, 0),
      );

      expect(tx.type, TransactionType.expense);
      expect(tx.amount, 50000);
      expect(tx.categoryId, 'expense_bills');
      expect(tx.description, 'Rent');
      expect(tx.memo, 'apartment');
      expect(tx.recurringRuleId, 'rule-1');
      expect(tx.occurrenceKey, 'rule-1@2026-02-10T08:00:00.000');
      expect(tx.isRecurring, isTrue);

      // Persisted transaction preserves the same fields.
      final persisted = await transactionRepo.getById(tx.id);
      expect(persisted, isNotNull);
      expect(persisted!.amount, 50000);
      expect(persisted.recurringRuleId, 'rule-1');
    },
  );

  test('idempotent across a rule reload (sub-second startDate survives '
      'second-precision storage without duplicating occurrence 1)', () async {
    // Reproduces the recurring duplicate bug: a rule saved with a sub-second
    // startDate is generated once in-memory (full precision), then the SAME
    // rule is reloaded from the store (which keeps DateTime at whole-second
    // precision) and generated again. The occurrence key must match across
    // the round-trip so no duplicate transaction is created.
    final preciseRule = RecurringRule(
      id: 'rule-precise',
      type: TransactionType.expense,
      amount: 50000,
      categoryId: 'expense_bills',
      description: 'Rent',
      frequency: RecurringFrequency.monthly,
      repeatPosition: RecurringRepeatPosition.sameDay,
      endCondition: RecurringEndCondition.forever,
      startDate: DateTime(2026, 6, 2, 21, 9, 22, 561, 229),
    );
    await saveRule(preciseRule);

    // Immediate generation right after save, using the in-memory rule.
    final cutoff = DateTime(2026, 6, 15);
    final firstRun = await generate.generateForRule(preciseRule, asOf: cutoff);
    expect(firstRun, hasLength(1));

    // The rule reloaded from storage has a whole-second startDate.
    final reloaded = (await getRules()).single;
    expect(reloaded.startDate, DateTime(2026, 6, 2, 21, 9, 22));

    // Generating again over all rules (as the post-save refresh does) must
    // NOT create a second Rent occurrence for the same start date.
    final secondRun = await generate(asOf: cutoff);
    expect(secondRun, isEmpty);

    final all = await transactionRepo.getAll();
    expect(all.where((t) => t.recurringRuleId == 'rule-precise'), hasLength(1));
  });

  test('only occurrences up to the cutoff are generated', () async {
    final foreverRule = RecurringRule(
      id: 'rule-2',
      type: TransactionType.income,
      amount: 1000,
      categoryId: 'income_salary',
      frequency: RecurringFrequency.daily,
      startDate: DateTime(2026, 6, 1),
    );
    await saveRule(foreverRule);

    final created = await generate(asOf: DateTime(2026, 6, 3));
    expect(created.map((t) => t.date).toList(), [
      DateTime(2026, 6, 1),
      DateTime(2026, 6, 2),
      DateTime(2026, 6, 3),
    ]);

    // Advancing the cutoff later generates only the new, not-yet-due ones.
    final more = await generate(asOf: DateTime(2026, 6, 5));
    expect(more.map((t) => t.date).toList(), [
      DateTime(2026, 6, 4),
      DateTime(2026, 6, 5),
    ]);
  });
}
