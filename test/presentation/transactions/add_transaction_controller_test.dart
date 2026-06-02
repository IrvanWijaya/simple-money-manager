// Unit tests for AddTransactionController draft + save behavior.
//
// Covers VAL-ADD-001 (opens as expense), VAL-ADD-002 (tab switching),
// VAL-ADD-005 (invalid save creates nothing), VAL-ADD-011 (sign from type, not
// punctuation), VAL-ADD-013 (description/memo stored without affecting the
// computed amount/type), and VAL-ADD-014 (type/category compatibility).

import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/domain/entities/category.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_end_condition.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_repeat_position.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_rule.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/domain/repositories/recurring_repository.dart';
import 'package:simple_money_manager/src/domain/repositories/transaction_repository.dart';
import 'package:simple_money_manager/src/domain/use_cases/add_transaction.dart';
import 'package:simple_money_manager/src/domain/use_cases/generate_due_recurring_transactions.dart';
import 'package:simple_money_manager/src/domain/use_cases/save_recurring_rule.dart';
import 'package:simple_money_manager/src/presentation/recurring/recurring_selection.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_controller.dart';

class _FakeTransactionRepository implements TransactionRepository {
  final List<MoneyTransaction> added = <MoneyTransaction>[];

  @override
  Future<void> add(MoneyTransaction transaction) async {
    added.add(transaction);
  }

  @override
  Future<void> update(MoneyTransaction transaction) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<MoneyTransaction?> getById(String id) async => null;

  @override
  Future<List<MoneyTransaction>> getAll() async => added;

  @override
  Future<List<MoneyTransaction>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async => added;

  @override
  Stream<List<MoneyTransaction>> watchAll() => Stream.value(added);
}

class _FakeRecurringRepository implements RecurringRepository {
  final List<RecurringRule> saved = <RecurringRule>[];
  final Map<String, Set<String>> _keys = <String, Set<String>>{};

  @override
  Future<void> saveRule(RecurringRule rule) async {
    saved.add(rule);
  }

  @override
  Future<void> deleteRule(String id) async {}

  @override
  Future<RecurringRule?> getRuleById(String id) async {
    for (final rule in saved) {
      if (rule.id == id) return rule;
    }
    return null;
  }

  @override
  Future<List<RecurringRule>> getAllRules() async => saved;

  @override
  Future<Set<String>> getGeneratedOccurrenceKeys(String ruleId) async =>
      _keys[ruleId] ?? <String>{};

  @override
  Future<void> recordGeneratedOccurrence({
    required String ruleId,
    required String occurrenceKey,
    required String transactionId,
    required DateTime occurrenceDate,
  }) async {
    _keys.putIfAbsent(ruleId, () => <String>{}).add(occurrenceKey);
  }
}

const _expenseFood = Category(
  id: 'expense_food',
  name: 'Food',
  type: TransactionType.expense,
);
const _incomeSalary = Category(
  id: 'income_salary',
  name: 'Salary',
  type: TransactionType.income,
);

AddTransactionController _build(
  _FakeTransactionRepository repo, {
  DateTime? now,
  _FakeRecurringRepository? recurringRepo,
  RecurringSelection initialRecurring = RecurringSelection.none,
}) {
  var counter = 0;
  final recurring = recurringRepo ?? _FakeRecurringRepository();
  return AddTransactionController(
    addTransaction: AddTransaction(repo),
    saveRecurringRule: SaveRecurringRule(recurring),
    generateDueRecurringTransactions: GenerateDueRecurringTransactions(
      recurring,
      repo,
    ),
    idGenerator: () => 'tx-${counter++}',
    now: now,
    initialRecurring: initialRecurring,
  );
}

void main() {
  test('opens in expense state with zero amount and no category', () {
    final controller = _build(_FakeTransactionRepository());
    expect(controller.draft.type, TransactionType.expense);
    expect(controller.draft.amount, 0);
    expect(controller.draft.category, isNull);
    expect(controller.draft.isValid, isFalse);
  });

  test('switching to income then expense changes type', () {
    final controller = _build(_FakeTransactionRepository());
    controller.setType(TransactionType.income);
    expect(controller.draft.type, TransactionType.income);
    controller.setType(TransactionType.expense);
    expect(controller.draft.type, TransactionType.expense);
  });

  test('invalid drafts do not persist a transaction', () async {
    final repo = _FakeTransactionRepository();
    final controller = _build(repo);

    // Zero amount, no category.
    expect(await controller.save(), isFalse);

    // Amount but still no category.
    controller.setAmount(50000);
    expect(await controller.save(), isFalse);

    // Category but zero amount.
    final controller2 = _build(repo);
    controller2.setCategory(_expenseFood);
    expect(await controller2.save(), isFalse);

    expect(repo.added, isEmpty);
  });

  test(
    'valid expense save stores positive magnitude with negative signed amount',
    () async {
      final repo = _FakeTransactionRepository();
      final controller = _build(repo, now: DateTime(2026, 6, 1, 4, 6));
      controller.setAmount(545000);
      controller.setCategory(_expenseFood);
      controller.setDescription('Education');

      expect(await controller.save(), isTrue);

      expect(repo.added, hasLength(1));
      final tx = repo.added.single;
      expect(tx.type, TransactionType.expense);
      expect(tx.amount, 545000);
      expect(tx.signedAmount, -545000);
      expect(tx.categoryId, 'expense_food');
      expect(tx.description, 'Education');
      expect(tx.date, DateTime(2026, 6, 1, 4, 6));
    },
  );

  test('valid income save stores positive signed amount', () async {
    final repo = _FakeTransactionRepository();
    final controller = _build(repo);
    controller.setType(TransactionType.income);
    controller.setAmount(1000000);
    controller.setCategory(_incomeSalary);

    expect(await controller.save(), isTrue);
    final tx = repo.added.single;
    expect(tx.type, TransactionType.income);
    expect(tx.signedAmount, 1000000);
  });

  test('negative amount input is clamped to zero magnitude', () {
    final controller = _build(_FakeTransactionRepository());
    controller.setAmount(-999);
    expect(controller.draft.amount, 0);
  });

  test(
    'switching type clears an incompatible selected category (VAL-ADD-014)',
    () {
      final controller = _build(_FakeTransactionRepository());
      controller.setCategory(_expenseFood);
      expect(controller.draft.category, _expenseFood);

      controller.setType(TransactionType.income);
      expect(controller.draft.category, isNull);

      // An income category can be selected and is kept.
      controller.setCategory(_incomeSalary);
      expect(controller.draft.category, _incomeSalary);
    },
  );

  test('selecting a category whose type mismatches is ignored', () {
    final controller = _build(_FakeTransactionRepository());
    // Current type is expense; selecting an income category does nothing.
    controller.setCategory(_incomeSalary);
    expect(controller.draft.category, isNull);
  });

  test(
    'description and memo are stored and trimmed without affecting amount',
    () async {
      final repo = _FakeTransactionRepository();
      final controller = _build(repo);
      controller.setAmount(200000);
      controller.setCategory(_expenseFood);
      controller.setDescription('  cicilan tv  ');
      controller.setMemo('  monthly installment  ');

      expect(await controller.save(), isTrue);
      final tx = repo.added.single;
      expect(tx.description, 'cicilan tv');
      expect(tx.memo, 'monthly installment');
      // Memo does not change the stored amount/sign.
      expect(tx.amount, 200000);
      expect(tx.signedAmount, -200000);
    },
  );

  test(
    'a non-recurring save creates no recurring rule (VAL-RECUI-011)',
    () async {
      final repo = _FakeTransactionRepository();
      final recurringRepo = _FakeRecurringRepository();
      final controller = _build(repo, recurringRepo: recurringRepo);
      controller.setAmount(50000);
      controller.setCategory(_expenseFood);

      expect(await controller.save(), isTrue);
      expect(recurringRepo.saved, isEmpty);
      expect(repo.added, hasLength(1));
      expect(repo.added.single.recurringRuleId, isNull);
    },
  );

  test('selecting None after a recurrence clears it so no rule is saved '
      '(VAL-RECUI-011)', () async {
    final repo = _FakeTransactionRepository();
    final recurringRepo = _FakeRecurringRepository();
    final controller = _build(repo, recurringRepo: recurringRepo);
    controller.setAmount(50000);
    controller.setCategory(_expenseFood);
    controller.setRecurring(
      const RecurringSelection(frequency: RecurringFrequency.monthly),
    );
    expect(controller.draft.isRecurring, isTrue);

    controller.setRecurring(RecurringSelection.none);
    expect(controller.draft.isRecurring, isFalse);

    expect(await controller.save(), isTrue);
    expect(recurringRepo.saved, isEmpty);
    expect(repo.added, hasLength(1));
  });

  test('a recurring save persists a rule and generates its first occurrence '
      'instead of a one-off transaction (VAL-RECUI-009)', () async {
    final repo = _FakeTransactionRepository();
    final recurringRepo = _FakeRecurringRepository();
    final controller = _build(
      repo,
      now: DateTime(2026, 6, 1, 8, 0),
      recurringRepo: recurringRepo,
    );
    controller.setAmount(978000);
    controller.setCategory(_expenseFood);
    controller.setDescription('Asuransi');
    controller.setRecurring(
      const RecurringSelection(
        frequency: RecurringFrequency.monthly,
        repeatPosition: RecurringRepeatPosition.sameDay,
      ),
    );

    expect(await controller.save(), isTrue);

    expect(recurringRepo.saved, hasLength(1));
    final rule = recurringRepo.saved.single;
    expect(rule.frequency, RecurringFrequency.monthly);
    expect(rule.amount, 978000);
    expect(rule.type, TransactionType.expense);
    expect(rule.categoryId, 'expense_food');
    expect(rule.description, 'Asuransi');
    expect(rule.startDate, DateTime(2026, 6, 1, 8, 0));

    // The first occurrence is materialized via the generator (linked to the
    // rule), and there is no separate non-recurring transaction.
    expect(repo.added, hasLength(1));
    expect(repo.added.single.recurringRuleId, rule.id);
  });

  test(
    'end-condition count is carried onto the saved rule (VAL-RECUI-014)',
    () async {
      final repo = _FakeTransactionRepository();
      final recurringRepo = _FakeRecurringRepository();
      final controller = _build(repo, recurringRepo: recurringRepo);
      controller.setAmount(100000);
      controller.setCategory(_expenseFood);
      controller.setRecurring(
        const RecurringSelection(
          frequency: RecurringFrequency.daily,
          interval: 2,
          endCondition: RecurringEndCondition.count,
          endCount: 5,
        ),
      );

      expect(await controller.save(), isTrue);
      final rule = recurringRepo.saved.single;
      expect(rule.frequency, RecurringFrequency.daily);
      expect(rule.interval, 2);
      expect(rule.endCondition, RecurringEndCondition.count);
      expect(rule.endCount, 5);
      // Daily rules carry no repeat position.
      expect(rule.repeatPosition, isNull);
    },
  );

  test(
    'end-condition end-date is carried onto the saved rule (VAL-RECUI-014)',
    () async {
      final repo = _FakeTransactionRepository();
      final recurringRepo = _FakeRecurringRepository();
      final controller = _build(repo, recurringRepo: recurringRepo);
      controller.setAmount(100000);
      controller.setCategory(_expenseFood);
      controller.setRecurring(
        RecurringSelection(
          frequency: RecurringFrequency.weekly,
          repeatPosition: RecurringRepeatPosition.endOfPeriod,
          endCondition: RecurringEndCondition.endDate,
          endDate: DateTime(2026, 12, 31),
        ),
      );

      expect(await controller.save(), isTrue);
      final rule = recurringRepo.saved.single;
      expect(rule.endCondition, RecurringEndCondition.endDate);
      expect(rule.endDate, DateTime(2026, 12, 31));
      expect(rule.repeatPosition, RecurringRepeatPosition.endOfPeriod);
    },
  );

  test('an initial recurring selection opens the draft in recurring mode '
      '(VAL-RECUI-008)', () {
    final controller = _build(
      _FakeTransactionRepository(),
      initialRecurring: const RecurringSelection(
        frequency: RecurringFrequency.monthly,
      ),
    );
    expect(controller.draft.isRecurring, isTrue);
    expect(controller.draft.recurring.frequency, RecurringFrequency.monthly);
  });
}
