import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/category_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/recurring_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/wallet_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/default_wallet.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/period_range.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_end_condition.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_repeat_position.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_rule.dart';
import 'package:simple_money_manager/src/domain/entities/timeframe.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/domain/use_cases/generate_due_recurring_transactions.dart';
import 'package:simple_money_manager/src/domain/use_cases/get_default_wallet_balance.dart';
import 'package:simple_money_manager/src/domain/use_cases/get_period_summary.dart';
import 'package:simple_money_manager/src/domain/use_cases/get_recurring_rule_views.dart';
import 'package:simple_money_manager/src/domain/use_cases/get_statistic_overview.dart';
import 'package:simple_money_manager/src/domain/use_cases/get_wallet_display.dart';

import 'helpers/test_database.dart';

/// Restart / force-stop-relaunch persistence guards (VAL-PERSIST-001..005, 008).
///
/// These exercise the same Drift-backed source tables the app uses, but against
/// a real on-disk SQLite file. Closing the [AppDatabase] and reopening a fresh
/// instance against the same file models an app force-stop and relaunch: there
/// is no shared in-memory state, so any data the second instance sees came back
/// from disk. Summaries/balances are recomputed by the domain use cases after
/// the "relaunch", proving nothing derived is persisted.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('smm_restart_test');
    dbFile = File('${tempDir.path}/restart.sqlite');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // A monthly rule due before/within the test reference window.
  RecurringRule monthlyRent() => RecurringRule(
    id: 'rule-rent',
    type: TransactionType.expense,
    amount: 50000,
    categoryId: 'expense_bills',
    description: 'Rent',
    memo: 'apartment',
    frequency: RecurringFrequency.monthly,
    interval: 1,
    repeatPosition: RecurringRepeatPosition.sameDay,
    endCondition: RecurringEndCondition.forever,
    startDate: DateTime(2026, 1, 10, 8, 0),
  );

  MoneyTransaction tx({
    required String id,
    required TransactionType type,
    required int amount,
    required DateTime date,
    String categoryId = 'expense_food',
    String description = '',
    String memo = '',
  }) {
    return MoneyTransaction(
      id: id,
      type: type,
      amount: amount,
      date: date,
      categoryId: categoryId,
      description: description,
      memo: memo,
    );
  }

  test('VAL-PERSIST-001: transactions survive a force-stop/relaunch with all '
      'fields intact', () async {
    // --- First launch: create an income and an expense, then "force-stop".
    final db1 = openFileDatabase(dbFile);
    final repo1 = TransactionRepositoryImpl(db1.transactionDao);
    await repo1.add(
      tx(
        id: 't-income',
        type: TransactionType.income,
        amount: 200000,
        date: DateTime(2026, 6, 10, 9, 30),
        categoryId: 'income_salary',
        description: 'June salary',
        memo: 'monthly pay',
      ),
    );
    await repo1.add(
      tx(
        id: 't-expense',
        type: TransactionType.expense,
        amount: 35000,
        date: DateTime(2026, 6, 12, 19, 5),
        categoryId: 'expense_food',
        description: 'Dinner',
      ),
    );
    await db1.close();

    // --- Relaunch: a brand new instance reads the same file from disk.
    final db2 = openFileDatabase(dbFile);
    final repo2 = TransactionRepositoryImpl(db2.transactionDao);
    addTearDown(db2.close);

    final all = await repo2.getAll();
    expect(all.map((t) => t.id).toSet(), {'t-income', 't-expense'});

    final income = await repo2.getById('t-income');
    expect(income, isNotNull);
    expect(income!.type, TransactionType.income);
    expect(income.amount, 200000);
    expect(income.date, DateTime(2026, 6, 10, 9, 30));
    expect(income.categoryId, 'income_salary');
    expect(income.description, 'June salary');
    expect(income.memo, 'monthly pay');

    final expense = await repo2.getById('t-expense');
    expect(expense!.type, TransactionType.expense);
    expect(expense.amount, 35000);
    expect(expense.date, DateTime(2026, 6, 12, 19, 5));
    expect(expense.description, 'Dinner');
  });

  test('VAL-PERSIST-002: recurring rules and generated occurrences survive '
      'relaunch with next occurrence intact', () async {
    final db1 = openFileDatabase(dbFile);
    final recurring1 = RecurringRepositoryImpl(db1.recurringDao);
    final txRepo1 = TransactionRepositoryImpl(db1.transactionDao);
    final generate1 = GenerateDueRecurringTransactions(recurring1, txRepo1);

    await recurring1.saveRule(monthlyRent());
    // Materialize due occurrences up to a cutoff so idempotency metadata is
    // written too.
    final firstRun = await generate1(asOf: DateTime(2026, 6, 30));
    expect(firstRun, isNotEmpty);
    final keysBefore = await recurring1.getGeneratedOccurrenceKeys('rule-rent');
    await db1.close();

    // --- Relaunch.
    final db2 = openFileDatabase(dbFile);
    final recurring2 = RecurringRepositoryImpl(db2.recurringDao);
    final txRepo2 = TransactionRepositoryImpl(db2.transactionDao);
    final views2 = GetRecurringRuleViews(recurring2);
    final generate2 = GenerateDueRecurringTransactions(recurring2, txRepo2);
    addTearDown(db2.close);

    // Rule reloaded with identical fields.
    final rule = await recurring2.getRuleById('rule-rent');
    expect(rule, isNotNull);
    expect(rule!.amount, 50000);
    expect(rule.frequency, RecurringFrequency.monthly);
    expect(rule.startDate, DateTime(2026, 1, 10, 8, 0));

    // Next occurrence is recomputed deterministically from the schedule.
    final view = (await views2(asOf: DateTime(2026, 6, 15))).single;
    expect(view.nextOccurrence, DateTime(2026, 7, 10, 8, 0));

    // Idempotency metadata survived: re-running generation up to the same
    // cutoff produces no new transactions after restart.
    final keysAfter = await recurring2.getGeneratedOccurrenceKeys('rule-rent');
    expect(keysAfter, keysBefore);
    final secondRun = await generate2(asOf: DateTime(2026, 6, 30));
    expect(secondRun, isEmpty);
  });

  test(
    'VAL-PERSIST-003 & 008: balances, period summary, and statistic overview '
    'recompute to the same values after relaunch',
    () async {
      // Seed wallet base balance + a pre-period and in-period transaction.
      final db1 = openFileDatabase(dbFile);
      final wallet1 = WalletRepositoryImpl(db1.walletDao);
      final txRepo1 = TransactionRepositoryImpl(db1.transactionDao);
      await wallet1.saveWallet(const DefaultWallet(baseBalance: 100000));
      await txRepo1.add(
        tx(
          id: 't-pre',
          type: TransactionType.income,
          amount: 500000,
          date: DateTime(2026, 5, 20),
          categoryId: 'income_salary',
        ),
      );
      await txRepo1.add(
        tx(
          id: 't-in-expense',
          type: TransactionType.expense,
          amount: 75000,
          date: DateTime(2026, 6, 5),
        ),
      );
      await txRepo1.add(
        tx(
          id: 't-in-income',
          type: TransactionType.income,
          amount: 25000,
          date: DateTime(2026, 6, 7),
          categoryId: 'income_allowance',
        ),
      );

      final range = PeriodRange.forTimeframe(
        Timeframe.monthly,
        DateTime(2026, 6, 15),
      );

      // Compute the "before restart" values.
      final balanceBefore = await GetDefaultWalletBalance(
        wallet1,
        txRepo1,
      ).call();
      final summaryBefore = await GetPeriodSummary(txRepo1).call(range);
      final overviewBefore = await GetStatisticOverview(
        wallet1,
        txRepo1,
      ).call(range);
      final displayBefore = await GetWalletDisplay(wallet1, txRepo1).call();

      // Sanity: base 100000 + 500000 - 75000 + 25000 = 550000.
      expect(balanceBefore, 550000);
      expect(summaryBefore.income, 25000);
      expect(summaryBefore.expense, 75000);
      expect(summaryBefore.total, -50000);
      // Opening = base 100000 + pre-period 500000 = 600000.
      expect(overviewBefore.openingBalance, 600000);
      expect(overviewBefore.endingBalance, 550000);
      expect(displayBefore.name, 'Cash');
      expect(displayBefore.balance, 550000);

      await db1.close();

      // --- Relaunch: recompute everything from disk; values must match.
      final db2 = openFileDatabase(dbFile);
      final wallet2 = WalletRepositoryImpl(db2.walletDao);
      final txRepo2 = TransactionRepositoryImpl(db2.transactionDao);
      addTearDown(db2.close);

      final balanceAfter = await GetDefaultWalletBalance(
        wallet2,
        txRepo2,
      ).call();
      final summaryAfter = await GetPeriodSummary(txRepo2).call(range);
      final overviewAfter = await GetStatisticOverview(
        wallet2,
        txRepo2,
      ).call(range);
      final displayAfter = await GetWalletDisplay(wallet2, txRepo2).call();

      expect(balanceAfter, balanceBefore);
      expect(summaryAfter.income, summaryBefore.income);
      expect(summaryAfter.expense, summaryBefore.expense);
      expect(summaryAfter.total, summaryBefore.total);
      expect(overviewAfter.openingBalance, overviewBefore.openingBalance);
      expect(overviewAfter.endingBalance, overviewBefore.endingBalance);
      // VAL-PERSIST-008: wallet display recomputes the same all-time balance.
      expect(displayAfter.name, 'Cash');
      expect(displayAfter.balance, balanceBefore);
    },
  );

  test('VAL-PERSIST-004: category selection, creation, and computation work '
      'against local storage only (no network dependency)', () async {
    // Categories are seeded into local storage; a transaction can be created
    // against a seeded category and summarized — all without any remote
    // source. The repositories used here have no HTTP/remote collaborators.
    final db = openFileDatabase(dbFile);
    final categoryRepo = CategoryRepositoryImpl(db.categoryDao);
    final txRepo = TransactionRepositoryImpl(db.transactionDao);
    addTearDown(db.close);

    await categoryRepo.ensureSeeded();
    final expenseCats = await categoryRepo.getByType(TransactionType.expense);
    expect(expenseCats, isNotEmpty);
    final food = expenseCats.firstWhere((c) => c.name == 'Food');

    await txRepo.add(
      tx(
        id: 't-local',
        type: TransactionType.expense,
        amount: 12000,
        date: DateTime(2026, 6, 9),
        categoryId: food.id,
      ),
    );

    final range = PeriodRange.forTimeframe(
      Timeframe.monthly,
      DateTime(2026, 6, 9),
    );
    final summary = await GetPeriodSummary(txRepo).call(range);
    expect(summary.expense, 12000);
  });

  test('VAL-PERSIST-005: persisted source tables contain no auth/credential/'
      'backup/sync columns', () async {
    // The schema is purely local source data. Guard that no table or column
    // names hint at remote/auth/backup/sync concerns sneaking into storage.
    final db = openFileDatabase(dbFile);
    addTearDown(db.close);

    final tableNames = db.allTables.map((t) => t.actualTableName).toList();
    expect(tableNames, contains('transactions'));
    expect(tableNames, contains('categories'));
    expect(tableNames, contains('recurring_rules'));
    expect(tableNames, contains('wallet_settings'));

    final forbidden = RegExp(
      r'(auth|token|credential|password|account|backup|sync|cloud|remote|'
      r'oauth|session)',
      caseSensitive: false,
    );
    for (final table in db.allTables) {
      expect(
        forbidden.hasMatch(table.actualTableName),
        isFalse,
        reason: 'unexpected table ${table.actualTableName}',
      );
      for (final column in table.$columns) {
        expect(
          forbidden.hasMatch(column.name),
          isFalse,
          reason: 'unexpected column ${table.actualTableName}.${column.name}',
        );
      }
    }
  });
}
