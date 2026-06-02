// Widget tests for the Category Selection screen.
//
// Covers VAL-CATSEL-001 (header: back, title, settings, Income/Expense tabs),
// VAL-CATSEL-002/003 (exact income/expense names), VAL-CATSEL-004 (selecting
// returns the category), VAL-CATSEL-005 (tabs do not mix types),
// VAL-CATSEL-006 (icon + name + radio selector per row), VAL-CATSEL-007
// (initial tab matches transaction type), VAL-CATSEL-008 (back returns
// nothing), VAL-CATSEL-009 (reopening shows the selected category), and
// VAL-CATSEL-010 (settings does not expose custom category creation).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/core/seed/category_seeds.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/domain/entities/category.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/categories/category_selection_screen.dart';

import '../../data/helpers/test_database.dart';

late AppDatabase _db;

Widget _host({
  required TransactionType initialType,
  String? selectedCategoryId,
  ValueChanged<Category?>? onResult,
}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(_db)],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              key: const ValueKey('open-categories'),
              onPressed: () async {
                final result = await Navigator.of(context).push<Category>(
                  MaterialPageRoute<Category>(
                    builder: (_) => CategorySelectionScreen(
                      initialType: initialType,
                      selectedCategoryId: selectedCategoryId,
                    ),
                  ),
                );
                onResult?.call(result);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('open-categories')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _db = createTestDatabase();
  });

  tearDown(() async {
    await _db.close();
  });

  testWidgets('shows header with back, title, settings, and tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_host(initialType: TransactionType.expense));
    await _open(tester);

    expect(
      find.byKey(const ValueKey('category-selection-back')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('category-selection-title')),
      findsOneWidget,
    );
    expect(find.text('Select Category'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('category-selection-settings')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('category-selection-tab-income')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('category-selection-tab-expense')),
      findsOneWidget,
    );
  });

  testWidgets('initial tab matches expense transaction type', (tester) async {
    await tester.pumpWidget(_host(initialType: TransactionType.expense));
    await _open(tester);

    // Expense-only category visible, income-only category not.
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });

  testWidgets('initial tab matches income transaction type', (tester) async {
    await tester.pumpWidget(_host(initialType: TransactionType.income));
    await _open(tester);

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Bills'), findsNothing);
  });

  testWidgets('income tab lists exactly the reference income categories', (
    tester,
  ) async {
    await tester.pumpWidget(_host(initialType: TransactionType.income));
    await _open(tester);

    final listFinder = find.byKey(
      const ValueKey('category-selection-list-income'),
    );
    for (final name in CategorySeeds.incomeNames) {
      await tester.scrollUntilVisible(
        find.text(name),
        80,
        scrollable: find.descendant(
          of: listFinder,
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text(name), findsOneWidget);
    }
    // No expense-only categories leak into the income tab.
    expect(find.text('Bills'), findsNothing);
    expect(find.text('Device'), findsNothing);
  });

  testWidgets('expense tab lists the reference expense categories', (
    tester,
  ) async {
    await tester.pumpWidget(_host(initialType: TransactionType.expense));
    await _open(tester);

    // The expense list is long; scroll to surface every name and assert each
    // expected name appears and no income-only name does.
    final listFinder = find.byKey(
      const ValueKey('category-selection-list-expense'),
    );
    for (final name in CategorySeeds.expenseNames) {
      await tester.scrollUntilVisible(
        find.text(name),
        80,
        scrollable: find.descendant(
          of: listFinder,
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Salary'), findsNothing);
    expect(find.text('Allowance'), findsNothing);
  });

  testWidgets('each row shows an icon, name, and radio selector', (
    tester,
  ) async {
    await tester.pumpWidget(_host(initialType: TransactionType.expense));
    await _open(tester);

    final billsRow = find.byKey(const ValueKey('category-row-expense_bills'));
    expect(billsRow, findsOneWidget);
    expect(
      find.descendant(of: billsRow, matching: find.byType(CircleAvatar)),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('category-radio-expense_bills')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: billsRow, matching: find.text('Bills')),
      findsOneWidget,
    );
  });

  testWidgets('selecting a category returns it to the caller', (tester) async {
    Category? returned;
    await tester.pumpWidget(
      _host(
        initialType: TransactionType.expense,
        onResult: (c) => returned = c,
      ),
    );
    await _open(tester);

    await tester.tap(
      find.byKey(const ValueKey('category-row-expense_education')),
    );
    await tester.pumpAndSettle();

    // Returned to caller.
    expect(find.byKey(const ValueKey('open-categories')), findsOneWidget);
    expect(returned, isNotNull);
    expect(returned!.id, 'expense_education');
    expect(returned!.type, TransactionType.expense);
  });

  testWidgets('back returns nothing so the form keeps its selection', (
    tester,
  ) async {
    Category? returned;
    var resultCalled = false;
    await tester.pumpWidget(
      _host(
        initialType: TransactionType.expense,
        selectedCategoryId: 'expense_food',
        onResult: (c) {
          resultCalled = true;
          returned = c;
        },
      ),
    );
    await _open(tester);

    await tester.tap(find.byKey(const ValueKey('category-selection-back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('open-categories')), findsOneWidget);
    expect(resultCalled, isTrue);
    expect(returned, isNull);
  });

  testWidgets('reopening shows the previously selected category radio on', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        initialType: TransactionType.expense,
        selectedCategoryId: 'expense_food',
      ),
    );
    await _open(tester);

    final radio = tester.widget<Icon>(
      find.byKey(const ValueKey('category-radio-expense_food')),
    );
    expect(radio.icon, Icons.radio_button_checked);

    // A different row is not selected.
    final other = tester.widget<Icon>(
      find.byKey(const ValueKey('category-radio-expense_bills')),
    );
    expect(other.icon, Icons.radio_button_unchecked);
  });

  testWidgets('settings does not expose custom category creation', (
    tester,
  ) async {
    await tester.pumpWidget(_host(initialType: TransactionType.expense));
    await _open(tester);

    await tester.tap(find.byKey(const ValueKey('category-selection-settings')));
    await tester.pumpAndSettle();

    // No add/create/edit affordance is surfaced.
    expect(find.text('Add Category'), findsNothing);
    expect(find.text('Create Category'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);

    // The fixed lists are unchanged after dismissing settings.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Bills'), findsOneWidget);
  });
}
