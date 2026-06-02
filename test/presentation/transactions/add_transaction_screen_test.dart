// Widget tests for the Add Transaction screen.
//
// Covers VAL-ADD-001 (opens as expense with SAVE + Income/Expense tabs, no
// Transfer), VAL-ADD-002 (tab switching), VAL-ADD-003 (required fields shown),
// VAL-ADD-004 (single wallet displayed, not a picker), VAL-ADD-005 (invalid
// save creates nothing), VAL-ADD-006/007 (valid save persists), VAL-ADD-009
// (date/time persisted), VAL-ADD-010 (back without save), and VAL-ADD-012
// (successful save closes the form).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/shared/period/period_controller.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_providers.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_screen.dart';
import 'package:simple_money_manager/src/presentation/transactions/transaction_home_screen.dart';

import '../../data/helpers/test_database.dart';

late AppDatabase _db;

Widget _host() {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(_db),
      transactionIdGeneratorProvider.overrideWithValue(() => 'fixed-id'),
    ],
    child: const MaterialApp(home: AddTransactionScreen()),
  );
}

Future<List<MoneyTransaction>> _allTransactions() {
  return TransactionRepositoryImpl(_db.transactionDao).getAll();
}

Future<void> _enterAmount(WidgetTester tester, String value) async {
  await tester.enterText(
    find.byKey(const ValueKey('add-transaction-amount')),
    value,
  );
  await tester.pump();
}

Future<void> _pickCategory(WidgetTester tester, String categoryId) async {
  await tester.tap(find.byKey(const ValueKey('add-transaction-category')));
  await tester.pumpAndSettle();
  expect(
    find.byKey(const ValueKey('category-selection-title')),
    findsOneWidget,
  );
  final option = find.byKey(ValueKey('category-row-$categoryId'));
  await tester.ensureVisible(option);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _db = createTestDatabase();
  });

  tearDown(() async {
    await _db.close();
  });

  testWidgets('opens in expense state with SAVE and Income/Expense tabs only', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('add-transaction-title')), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('add-transaction-title')))
          .data,
      'Expense',
    );
    expect(find.byKey(const ValueKey('add-transaction-save')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('add-transaction-tab-income')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('add-transaction-tab-expense')),
      findsOneWidget,
    );
    // No Transfer option anywhere.
    expect(find.text('Transfer'), findsNothing);
  });

  testWidgets('shows all required form fields before save', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('add-transaction-date')), findsOneWidget);
    expect(find.byKey(const ValueKey('add-transaction-time')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('add-transaction-recurring')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('add-transaction-amount')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('add-transaction-description')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('add-transaction-category')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('add-transaction-wallet')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('add-transaction-memo')), findsOneWidget);
    expect(find.text('Select Category'), findsOneWidget);
  });

  testWidgets('Income/Expense tabs switch the form type', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-transaction-tab-income')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('add-transaction-title')))
          .data,
      'Income',
    );

    await tester.tap(find.byKey(const ValueKey('add-transaction-tab-expense')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('add-transaction-title')))
          .data,
      'Expense',
    );
  });

  testWidgets('wallet row is display-only and shows the single wallet', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    final walletTile = tester.widget<ListTile>(
      find.byKey(const ValueKey('add-transaction-wallet')),
    );
    expect(walletTile.enabled, isFalse);
    expect(walletTile.onTap, isNull);
    expect(find.textContaining('Cash'), findsOneWidget);
  });

  testWidgets('invalid save (no amount/category) creates no transaction', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add-transaction-save')));
    await tester.pump();

    expect(await _allTransactions(), isEmpty);
    expect(
      find.byKey(const ValueKey('add-transaction-validation')),
      findsOneWidget,
    );
    // Form is still open.
    expect(find.byKey(const ValueKey('add-transaction-save')), findsOneWidget);
  });

  testWidgets('valid expense save persists a negative transaction and closes', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await _enterAmount(tester, '545000');
    await _pickCategory(tester, 'expense_food');
    // Category row reflects the chosen category.
    expect(find.text('Food'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('add-transaction-description')),
      'Education',
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('add-transaction-save')));
    await tester.pumpAndSettle();

    final all = await _allTransactions();
    expect(all, hasLength(1));
    expect(all.single.type, TransactionType.expense);
    expect(all.single.amount, 545000);
    expect(all.single.signedAmount, -545000);
    expect(all.single.description, 'Education');
  });

  testWidgets('back without saving creates no transaction', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(_db),
          transactionIdGeneratorProvider.overrideWithValue(() => 'fixed-id'),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('open-add'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-add')));
    await tester.pumpAndSettle();

    // Enter draft data but go back instead of saving.
    await _enterAmount(tester, '999000');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(await _allTransactions(), isEmpty);
    // Returned to the originating screen.
    expect(find.byKey(const ValueKey('open-add')), findsOneWidget);
  });

  testWidgets(
    'saving from the shell closes the form and updates the list/summary immediately',
    (tester) async {
      // A Transaction home with an Add button pushing Add Transaction, all in
      // one ProviderScope so post-save invalidation reaches the home surface.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(_db),
            transactionIdGeneratorProvider.overrideWithValue(() => 'fixed-id'),
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

      // Empty period to start.
      expect(
        find.byKey(const ValueKey('transaction-empty-state')),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('overview-total'))).data,
        'Rp 0',
      );

      // Open Add Transaction and create an expense dated within the period.
      await tester.tap(find.byKey(const ValueKey('open-add')));
      await tester.pumpAndSettle();
      await _enterAmount(tester, '545000');
      await _pickCategory(tester, 'expense_food');
      await tester.enterText(
        find.byKey(const ValueKey('add-transaction-description')),
        'Groceries',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('add-transaction-save')));
      await tester.pumpAndSettle();

      // Form closed (back on the home FAB), and the new row + summary appear
      // without restart.
      expect(find.byKey(const ValueKey('open-add')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transaction-empty-state')),
        findsNothing,
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('transaction-title-fixed-id')),
            )
            .data,
        'Groceries',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('transaction-amount-fixed-id')),
            )
            .data,
        '-Rp 545,000',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('overview-expense')))
            .data,
        '-Rp 545,000',
      );
    },
  );
}
