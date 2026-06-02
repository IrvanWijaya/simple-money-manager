// Widget tests for the Statistic Structure detail screen.
//
// Covers VAL-STAT-006 (required header + tabs + period controls),
// VAL-STAT-007 (Income/Expense tabs filter independently), VAL-STAT-008
// (category amount/count/percentage with singular/plural text), VAL-STAT-009
// (empty zero state, no stale rows), VAL-STAT-014 (period navigation recomputes
// rows; back preserves context), VAL-STAT-015 (filter icon is non-expanding and
// does not change data), and VAL-STAT-016 (timeframe selector updates the
// detail range).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/category_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/shared/period/period_controller.dart';
import 'package:simple_money_manager/src/presentation/statistics/structure_detail_screen.dart';

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
    child: const MaterialApp(home: StructureDetailScreen()),
  );
}

Future<void> _seedCategories() async {
  await CategoryRepositoryImpl(_db.categoryDao).ensureSeeded();
}

Future<void> _addTx({
  required String id,
  required TransactionType type,
  required int amount,
  required DateTime date,
  required String categoryId,
}) async {
  await TransactionRepositoryImpl(_db.transactionDao).add(
    MoneyTransaction(
      id: id,
      type: type,
      amount: amount,
      date: date,
      categoryId: categoryId,
    ),
  );
}

Text _textWithKey(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key)));

void main() {
  setUp(() async {
    _db = createTestDatabase();
    await _seedCategories();
  });

  tearDown(() async {
    await _db.close();
  });

  // June 2026 data.
  // Expense: Gifts 1,000,000 (2 tx), Bills 600,000 (1 tx). Total 1,600,000.
  // Income: Salary 800,000 (1 tx). Total 800,000.
  Future<void> seedMixed() async {
    await _addTx(
      id: 'gifts-1',
      type: TransactionType.expense,
      amount: 600000,
      date: DateTime(2026, 6, 10, 10, 0),
      categoryId: 'expense_gifts',
    );
    await _addTx(
      id: 'gifts-2',
      type: TransactionType.expense,
      amount: 400000,
      date: DateTime(2026, 6, 11, 10, 0),
      categoryId: 'expense_gifts',
    );
    await _addTx(
      id: 'bills-1',
      type: TransactionType.expense,
      amount: 600000,
      date: DateTime(2026, 6, 12, 10, 0),
      categoryId: 'expense_bills',
    );
    await _addTx(
      id: 'salary-1',
      type: TransactionType.income,
      amount: 800000,
      date: DateTime(2026, 6, 13, 10, 0),
      categoryId: 'income_salary',
    );
    // Out-of-period income (May) must never appear in June.
    await _addTx(
      id: 'salary-may',
      type: TransactionType.income,
      amount: 999000,
      date: DateTime(2026, 5, 20, 10, 0),
      categoryId: 'income_salary',
    );
  }

  testWidgets('shows required header, period controls, and tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(find.text('Structure'), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-back')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-calendar')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-filter')), findsOneWidget);
    expect(_textWithKey(tester, 'structure-period-label').data, 'Jun 2026');
    expect(find.byKey(const ValueKey('structure-tab-income')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-tab-expense')), findsOneWidget);
  });

  testWidgets('Expense tab (default) shows only expense category statistics', (
    tester,
  ) async {
    await seedMixed();
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Expense rows present with computed amount, count, and percentage.
    expect(
      _textWithKey(tester, 'structure-row-amount-expense_gifts').data,
      '-Rp 1,000,000',
    );
    expect(
      _textWithKey(tester, 'structure-row-count-expense_gifts').data,
      '2 transactions',
    );
    // 1,000,000 / 1,600,000 = 62.5%
    expect(
      _textWithKey(tester, 'structure-row-percentage-expense_gifts').data,
      '62.5%',
    );
    expect(
      _textWithKey(tester, 'structure-row-amount-expense_bills').data,
      '-Rp 600,000',
    );
    expect(
      _textWithKey(tester, 'structure-row-count-expense_bills').data,
      '1 transaction',
    );

    // No income rows leak into the Expense tab.
    expect(
      find.byKey(const ValueKey('structure-row-income_salary')),
      findsNothing,
    );
  });

  testWidgets('Income tab shows only income category statistics', (
    tester,
  ) async {
    await seedMixed();
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('structure-tab-income')));
    await tester.pumpAndSettle();

    // Income salary row present; out-of-period May income excluded so the
    // in-period total is just 800,000 -> 100%.
    expect(
      _textWithKey(tester, 'structure-row-amount-income_salary').data,
      'Rp 800,000',
    );
    expect(
      _textWithKey(tester, 'structure-row-count-income_salary').data,
      '1 transaction',
    );
    expect(
      _textWithKey(tester, 'structure-row-percentage-income_salary').data,
      '100.0%',
    );

    // Expense rows are not shown on the Income tab.
    expect(
      find.byKey(const ValueKey('structure-row-expense_gifts')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('structure-row-expense_bills')),
      findsNothing,
    );
  });

  testWidgets('empty period shows zero chart state and no category rows', (
    tester,
  ) async {
    // No transactions seeded.
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('structure-chart-empty')), findsOneWidget);
    expect(_textWithKey(tester, 'structure-chart-total').data, 'Rp 0');
    expect(
      find.byKey(const ValueKey('structure-row-expense_gifts')),
      findsNothing,
    );
    expect(find.textContaining('NaN'), findsNothing);
    expect(find.textContaining('Infinity'), findsNothing);
  });

  testWidgets('period navigation recomputes rows and label', (tester) async {
    await seedMixed();
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'structure-period-label').data, 'Jun 2026');
    expect(
      find.byKey(const ValueKey('structure-row-expense_gifts')),
      findsOneWidget,
    );

    // Move to May: no expense, so expense rows disappear (recomputed).
    await tester.tap(find.byTooltip('Previous period'));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'structure-period-label').data, 'May 2026');
    expect(
      find.byKey(const ValueKey('structure-row-expense_gifts')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('structure-chart-empty')), findsOneWidget);
  });

  testWidgets('timeframe selector updates the detail range label', (
    tester,
  ) async {
    await seedMixed();
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'structure-period-label').data, 'Jun 2026');

    await tester.tap(find.byKey(const ValueKey('structure-calendar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('timeframe-option-yearly')));
    await tester.pumpAndSettle();

    // Yearly label for 2026; rows recompute for the wider range.
    expect(_textWithKey(tester, 'structure-period-label').data, '2026');
    expect(
      find.byKey(const ValueKey('structure-row-expense_gifts')),
      findsOneWidget,
    );
  });

  testWidgets('filter icon is a no-op and does not change computed data', (
    tester,
  ) async {
    await seedMixed();
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    final before = _textWithKey(
      tester,
      'structure-row-amount-expense_gifts',
    ).data;

    await tester.tap(find.byKey(const ValueKey('structure-filter')));
    await tester.pumpAndSettle();

    // No new route/dialog pushed and the data is unchanged.
    expect(find.byType(StructureDetailScreen), findsOneWidget);
    expect(
      _textWithKey(tester, 'structure-row-amount-expense_gifts').data,
      before,
    );
  });
}
