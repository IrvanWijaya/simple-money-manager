// Widget tests for the Wallet recurring-settings surface.
//
// Covers VAL-RECUI-005 (recurring-only with RECURRING/Manage/+Add Recurring),
// VAL-RECUI-006 (entry shows category/title, next occurrence, signed amount),
// VAL-RECUI-007 (Manage count matches active rule count), VAL-RECUI-008
// (+ Add Recurring starts creation without wallet selection), and VAL-RECUI-012
// (empty state shows Manage(0), no stale entries, + Add Recurring).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/recurring_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_end_condition.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_rule.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_screen.dart';
import 'package:simple_money_manager/src/presentation/wallet/wallet_home_screen.dart';
import 'package:simple_money_manager/src/presentation/wallet/wallet_providers.dart';

import '../../data/helpers/test_database.dart';

late AppDatabase _db;

Widget _wrap(DateTime now) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(_db),
      recurringReferenceProvider.overrideWithValue(now),
    ],
    child: const MaterialApp(home: Scaffold(body: WalletHomeScreen())),
  );
}

Future<void> _saveRule(RecurringRule rule) async {
  await RecurringRepositoryImpl(_db.recurringDao).saveRule(rule);
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

  testWidgets('empty state shows RECURRING, Manage(0), and + Add Recurring', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(find.text('RECURRING'), findsOneWidget);
    expect(_textWithKey(tester, 'wallet-recurring-manage').data, 'Manage(0)');
    expect(find.byKey(const ValueKey('wallet-add-recurring')), findsOneWidget);
    expect(find.text('Add Recurring'), findsOneWidget);

    // No recurring entry rows when empty.
    expect(find.byKey(const ValueKey('recurring-title-rule-1')), findsNothing);
  });

  testWidgets(
    'saved recurring entry shows title, next occurrence, and signed amount',
    (tester) async {
      await _saveRule(
        RecurringRule(
          id: 'rule-insurance',
          type: TransactionType.expense,
          amount: 978000,
          categoryId: 'expense_bills',
          frequency: RecurringFrequency.monthly,
          startDate: DateTime(2026, 6, 1, 8, 0),
          description: 'Asuransi',
        ),
      );

      await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
      await tester.pumpAndSettle();

      expect(
        _textWithKey(tester, 'recurring-title-rule-insurance').data,
        'Asuransi',
      );
      // Next monthly occurrence on/after Jun 15 is Jul 1 2026 (a Wednesday).
      expect(
        _textWithKey(tester, 'recurring-next-rule-insurance').data,
        'Wednesday 01 Jul 2026',
      );
      expect(
        _textWithKey(tester, 'recurring-amount-rule-insurance').data,
        '-Rp 978,000',
      );
    },
  );

  testWidgets('income recurring entry shows a positive amount', (tester) async {
    await _saveRule(
      RecurringRule(
        id: 'rule-salary',
        type: TransactionType.income,
        amount: 5000000,
        categoryId: 'income_salary',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 6, 1, 8, 0),
        description: 'Salary',
      ),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(
      _textWithKey(tester, 'recurring-amount-rule-salary').data,
      'Rp 5,000,000',
    );
  });

  testWidgets('Manage count matches the number of active recurring rules', (
    tester,
  ) async {
    await _saveRule(
      RecurringRule(
        id: 'rule-1',
        type: TransactionType.expense,
        amount: 100000,
        categoryId: 'expense_bills',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 6, 1, 8, 0),
      ),
    );
    await _saveRule(
      RecurringRule(
        id: 'rule-2',
        type: TransactionType.income,
        amount: 200000,
        categoryId: 'income_salary',
        frequency: RecurringFrequency.weekly,
        startDate: DateTime(2026, 6, 2, 8, 0),
      ),
    );
    await _saveRule(
      RecurringRule(
        id: 'rule-3',
        type: TransactionType.expense,
        amount: 300000,
        categoryId: 'expense_food',
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 3, 8, 0),
      ),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'wallet-recurring-manage').data, 'Manage(3)');
  });

  testWidgets('ended count rule shows no upcoming occurrence', (tester) async {
    // A count-3 daily rule starting Jun 1; occurrences are Jun 1/2/3, all
    // before the Jun 15 reference, so there is no upcoming occurrence.
    await _saveRule(
      RecurringRule(
        id: 'rule-ended',
        type: TransactionType.expense,
        amount: 100000,
        categoryId: 'expense_food',
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 6, 1, 8, 0),
        endCondition: RecurringEndCondition.count,
        endCount: 3,
      ),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(
      _textWithKey(tester, 'recurring-next-rule-ended').data,
      'No upcoming occurrence',
    );
  });

  testWidgets('+ Add Recurring opens the recurring creation path', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('wallet-add-recurring')));
    await tester.pumpAndSettle();

    // Creation path opens already in recurring mode; the single wallet is shown
    // display-only (no picker).
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('add-transaction-recurring-label')),
          )
          .data,
      'Monthly',
    );
    final walletTile = tester.widget<ListTile>(
      find.byKey(const ValueKey('add-transaction-wallet')),
    );
    expect(walletTile.enabled, isFalse);
    expect(walletTile.onTap, isNull);
  });

  testWidgets(
    'Wallet + Add Recurring can save a rule, returning to a higher Manage count '
    '(VAL-RECUI-009)',
    (tester) async {
      await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
      await tester.pumpAndSettle();

      // Empty to start.
      expect(_textWithKey(tester, 'wallet-recurring-manage').data, 'Manage(0)');

      // Open the recurring creation path.
      await tester.tap(find.byKey(const ValueKey('wallet-add-recurring')));
      await tester.pumpAndSettle();

      // Fill required transaction details (already monthly recurring).
      await tester.enterText(
        find.byKey(const ValueKey('add-transaction-amount')),
        '978000',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('add-transaction-category')));
      await tester.pumpAndSettle();
      final option = find.byKey(const ValueKey('category-row-expense_bills'));
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();

      // Save the recurring rule and return to Wallet.
      await tester.tap(find.byKey(const ValueKey('add-transaction-save')));
      await tester.pumpAndSettle();

      // Back on Wallet with the count incremented and the entry present.
      expect(find.byType(AddTransactionScreen), findsNothing);
      expect(_textWithKey(tester, 'wallet-recurring-manage').data, 'Manage(1)');
      expect(
        find.byKey(const ValueKey('wallet-recurring-list')),
        findsOneWidget,
      );
      // The saved rule renders a recurring entry row (title from category).
      expect(find.text('Bills'), findsOneWidget);
    },
  );
}
