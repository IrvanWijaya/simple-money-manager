// Widget tests for the Transaction home list.
//
// Covers VAL-TXNHOME-001 (computed overview), VAL-TXNHOME-002 (date grouping),
// VAL-TXNHOME-003 (computed date group total), VAL-TXNHOME-004/005 (row details
// without wallet selection), VAL-TXNHOME-006 (due recurring appears once), and
// VAL-TXNHOME-007 (deterministic newest-first ordering).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/category_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/recurring_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_rule.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/shared/period/period_controller.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_providers.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_screen.dart';
import 'package:simple_money_manager/src/presentation/transactions/transaction_home_screen.dart';

import '../../data/helpers/test_database.dart';

late AppDatabase _db;

Widget _wrap(DateTime now) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(_db),
      periodControllerProvider.overrideWith(
        (ref) => PeriodController(now: now),
      ),
    ],
    child: const MaterialApp(home: Scaffold(body: TransactionHomeScreen())),
  );
}

Future<void> _addTx({
  required String id,
  required TransactionType type,
  required int amount,
  required DateTime date,
  String description = '',
  String categoryId = 'expense_food',
}) async {
  final repo = TransactionRepositoryImpl(_db.transactionDao);
  await repo.add(
    MoneyTransaction(
      id: id,
      type: type,
      amount: amount,
      date: date,
      categoryId: categoryId,
      description: description,
    ),
  );
}

Text _textWithKey(WidgetTester tester, String key) {
  return tester.widget<Text>(find.byKey(ValueKey(key)));
}

void main() {
  setUp(() {
    _db = createTestDatabase();
  });

  tearDown(() async {
    await _db.close();
  });

  testWidgets('overview is computed for the active period', (tester) async {
    await _addTx(
      id: 'income-1',
      type: TransactionType.income,
      amount: 100000,
      date: DateTime(2026, 6, 10, 9, 0),
    );
    await _addTx(
      id: 'expense-1',
      type: TransactionType.expense,
      amount: 30000,
      date: DateTime(2026, 6, 12, 10, 0),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'overview-income').data, 'Rp 100,000');
    expect(_textWithKey(tester, 'overview-expense').data, '-Rp 30,000');
    expect(_textWithKey(tester, 'overview-total').data, 'Rp 70,000');
  });

  testWidgets('transactions group by date with computed group totals', (
    tester,
  ) async {
    // Two dates in June.
    await _addTx(
      id: 'jun10-exp',
      type: TransactionType.expense,
      amount: 545000,
      date: DateTime(2026, 6, 10, 1, 56),
    );
    await _addTx(
      id: 'jun12-exp',
      type: TransactionType.expense,
      amount: 200000,
      date: DateTime(2026, 6, 12, 1, 53),
    );
    await _addTx(
      id: 'jun12-inc',
      type: TransactionType.income,
      amount: 500000,
      date: DateTime(2026, 6, 12, 2, 0),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Two date group headers exist.
    expect(find.byKey(const ValueKey('date-group-2026-06-12')), findsOneWidget);
    expect(find.byKey(const ValueKey('date-group-2026-06-10')), findsOneWidget);

    // Jun 12 total = 500,000 income - 200,000 expense = 300,000.
    expect(
      _textWithKey(tester, 'date-group-total-2026-06-12').data,
      'Rp 300,000',
    );
    // Jun 10 total = -545,000.
    expect(
      _textWithKey(tester, 'date-group-total-2026-06-10').data,
      '-Rp 545,000',
    );
  });

  testWidgets('date groups are ordered newest first', (tester) async {
    await _addTx(
      id: 'jun10',
      type: TransactionType.expense,
      amount: 1000,
      date: DateTime(2026, 6, 10, 1, 0),
    );
    await _addTx(
      id: 'jun20',
      type: TransactionType.expense,
      amount: 2000,
      date: DateTime(2026, 6, 20, 1, 0),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    final newer = tester.getTopLeft(
      find.byKey(const ValueKey('date-group-2026-06-20')),
    );
    final older = tester.getTopLeft(
      find.byKey(const ValueKey('date-group-2026-06-10')),
    );
    expect(newer.dy, lessThan(older.dy));
  });

  testWidgets('rows within a day are ordered newest time first', (
    tester,
  ) async {
    await _addTx(
      id: 'early',
      type: TransactionType.expense,
      amount: 1000,
      date: DateTime(2026, 6, 12, 1, 0),
      description: 'early',
    );
    await _addTx(
      id: 'late',
      type: TransactionType.expense,
      amount: 2000,
      date: DateTime(2026, 6, 12, 23, 0),
      description: 'late',
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    final lateTop = tester.getTopLeft(
      find.byKey(const ValueKey('transaction-title-late')),
    );
    final earlyTop = tester.getTopLeft(
      find.byKey(const ValueKey('transaction-title-early')),
    );
    expect(lateTop.dy, lessThan(earlyTop.dy));
  });

  testWidgets('row shows description, signed amount, and time; no wallet', (
    tester,
  ) async {
    await _addTx(
      id: 'edu',
      type: TransactionType.expense,
      amount: 545000,
      date: DateTime(2026, 6, 12, 1, 56),
      description: 'Education',
      categoryId: 'expense_education',
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'transaction-title-edu').data, 'Education');
    expect(_textWithKey(tester, 'transaction-amount-edu').data, '-Rp 545,000');
    expect(_textWithKey(tester, 'transaction-time-edu').data, '01:56');

    // No wallet-selection affordance anywhere in the list.
    expect(find.textContaining('Cash'), findsNothing);
    expect(find.textContaining('Wallet'), findsNothing);
  });

  testWidgets('empty period shows a readable empty state', (tester) async {
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('transaction-empty-state')),
      findsOneWidget,
    );
    expect(find.text('No transactions in this period'), findsOneWidget);
  });

  testWidgets(
    'due recurring occurrence appears once and is not duplicated on revisit',
    (tester) async {
      // A monthly rule whose first occurrence is on Jun 1 2026. The generator
      // materializes occurrences due up to the real wall clock, so the start
      // is kept in the past to make generation deterministic; the June
      // occurrence falls within the viewed June period. Generation is
      // idempotent, so revisiting the period does not duplicate the row.
      final recurringRepo = RecurringRepositoryImpl(_db.recurringDao);
      await recurringRepo.saveRule(
        RecurringRule(
          id: 'rule-rent',
          type: TransactionType.expense,
          amount: 1200000,
          categoryId: 'expense_bills',
          frequency: RecurringFrequency.monthly,
          startDate: DateTime(2026, 6, 1, 8, 0),
          description: 'Rent',
        ),
      );

      await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
      await tester.pumpAndSettle();

      // The generated occurrence row appears once in June.
      expect(find.text('Rent'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey(
            'transaction-amount-rule-rent@2026-06-01T08:00:00.000',
          ),
        ),
        findsOneWidget,
      );

      // Navigate to next period and back; the occurrence must not duplicate.
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
    },
  );

  testWidgets(
    'list never flashes a transient empty frame while reloading after a save',
    (tester) async {
      // Seed the categories so the Add Transaction flow can pick one, and an
      // existing in-period transaction so the list starts populated.
      await CategoryRepositoryImpl(_db.categoryDao).ensureSeeded();
      await _addTx(
        id: 'existing',
        type: TransactionType.expense,
        amount: 50000,
        date: DateTime(2026, 6, 10, 9, 0),
        description: 'Existing',
        categoryId: 'expense_food',
      );

      // Transaction home plus an Add button in the same ProviderScope so the
      // post-save invalidation (refreshTransactionDerivedData) reaches the
      // still-mounted list. This reproduces the real flow where the list
      // reloads underneath the Add screen after SAVE.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(_db),
            transactionIdGeneratorProvider.overrideWithValue(() => 'new-tx'),
            periodControllerProvider.overrideWith(
              (ref) => PeriodController(now: DateTime(2026, 6, 15)),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const TransactionHomeScreen(),
              floatingActionButton: Builder(
                builder: (context) => FloatingActionButton(
                  key: const ValueKey('open-add'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The list starts populated with the existing transaction.
      expect(find.byKey(const ValueKey('transaction-list')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transaction-empty-state')),
        findsNothing,
      );

      // Open Add, enter an amount, pick a category, and save.
      await tester.tap(find.byKey(const ValueKey('open-add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('add-transaction-amount')),
        '20000',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('add-transaction-category')));
      await tester.pumpAndSettle();
      final food = find.byKey(const ValueKey('category-row-expense_food'));
      await tester.ensureVisible(food);
      await tester.pumpAndSettle();
      await tester.tap(food);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-transaction-save')));

      // Drive frames one at a time through the post-save pop + provider reload.
      // The list must keep its prior content the whole time: the empty state
      // must never appear and the existing row must stay on screen, even while
      // transactionDateGroupsProvider is recomputing. This guards the transient
      // blank-frame regression (skipLoadingOnReload on the list).
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          find.byKey(const ValueKey('transaction-empty-state')),
          findsNothing,
          reason: 'empty state must not flash during post-save reload',
        );
        expect(
          find.byKey(const ValueKey('transaction-list')),
          findsOneWidget,
          reason: 'list must stay mounted (no spinner swap) during reload',
        );
        expect(
          find.byKey(const ValueKey('transaction-title-existing')),
          findsOneWidget,
          reason: 'prior content must be preserved during reload',
        );
      }

      await tester.pumpAndSettle();

      // After the reload settles the newly saved transaction is present and the
      // list still shows the prior content (no data loss, no blank flicker).
      expect(
        find.byKey(const ValueKey('transaction-empty-state')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('transaction-title-existing')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('transaction-title-new-tx')),
        findsOneWidget,
      );
    },
  );
}
