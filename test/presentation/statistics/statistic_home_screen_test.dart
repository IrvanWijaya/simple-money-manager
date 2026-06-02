// Widget tests for the Statistic home surface and chart toggle.
//
// Covers VAL-STAT-003 (chart toggles only donut/bar), VAL-STAT-004 (toggle
// preserves computed totals/context), VAL-STAT-005 (Show more opens Structure
// detail), VAL-STAT-009 (empty zero state), VAL-STAT-010 (home chart/legend use
// computed category totals), VAL-STAT-011 (bar represents same data as donut),
// and VAL-STAT-012 (zero chart state is stable with no invalid values).

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
import 'package:simple_money_manager/src/presentation/statistics/statistic_home_screen.dart';
import 'package:simple_money_manager/src/presentation/statistics/structure_detail_screen.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_providers.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_screen.dart';

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
    child: const MaterialApp(home: Scaffold(body: StatisticHomeScreen())),
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

  // Expense data: Gifts 1,000,000 (50%), Bills 600,000 (30%), Education
  // 400,000 (20%). Total expense = 2,000,000.
  Future<void> seedExpenseStructure() async {
    await _addTx(
      id: 'gifts-1',
      type: TransactionType.expense,
      amount: 1000000,
      date: DateTime(2026, 6, 10, 10, 0),
      categoryId: 'expense_gifts',
    );
    await _addTx(
      id: 'bills-1',
      type: TransactionType.expense,
      amount: 600000,
      date: DateTime(2026, 6, 11, 10, 0),
      categoryId: 'expense_bills',
    );
    await _addTx(
      id: 'edu-1',
      type: TransactionType.expense,
      amount: 400000,
      date: DateTime(2026, 6, 12, 10, 0),
      categoryId: 'expense_education',
    );
  }

  testWidgets('home legend uses computed category totals and percentages', (
    tester,
  ) async {
    await seedExpenseStructure();

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Legend rows reflect computed amounts and one-decimal percentages.
    expect(
      _textWithKey(tester, 'legend-amount-expense_gifts').data,
      '-Rp 1,000,000',
    );
    expect(
      _textWithKey(tester, 'legend-percentage-expense_gifts').data,
      '50.0%',
    );
    expect(
      _textWithKey(tester, 'legend-amount-expense_bills').data,
      '-Rp 600,000',
    );
    expect(
      _textWithKey(tester, 'legend-percentage-expense_bills').data,
      '30.0%',
    );
    expect(
      _textWithKey(tester, 'legend-amount-expense_education').data,
      '-Rp 400,000',
    );
    expect(
      _textWithKey(tester, 'legend-percentage-expense_education').data,
      '20.0%',
    );

    // Donut center shows the signed expense total.
    expect(_textWithKey(tester, 'structure-chart-total').data, '-Rp 2,000,000');
  });

  testWidgets('chart toggles only between donut and bar', (tester) async {
    await seedExpenseStructure();

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Starts as donut.
    expect(find.byKey(const ValueKey('structure-donut')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-bar')), findsNothing);

    // First tap -> bar.
    await tester.tap(find.byKey(const ValueKey('stat-chart-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('structure-bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-donut')), findsNothing);

    // Second tap -> donut (cycles only the two modes).
    await tester.tap(find.byKey(const ValueKey('stat-chart-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('structure-donut')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-bar')), findsNothing);
  });

  testWidgets('toggling chart preserves computed totals and legend data', (
    tester,
  ) async {
    await seedExpenseStructure();

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    String legendAmount(String id) =>
        _textWithKey(tester, 'legend-amount-$id').data!;
    String legendPct(String id) =>
        _textWithKey(tester, 'legend-percentage-$id').data!;

    final beforeGifts = legendAmount('expense_gifts');
    final beforeGiftsPct = legendPct('expense_gifts');
    final beforeOpening = _textWithKey(tester, 'stat-opening-balance').data;
    final beforeEnding = _textWithKey(tester, 'stat-ending-balance').data;
    final beforeOverviewExpense = _textWithKey(tester, 'overview-expense').data;
    final beforePeriod = _textWithKey(tester, 'period-label').data;

    // Toggle to bar mode.
    await tester.tap(find.byKey(const ValueKey('stat-chart-toggle')));
    await tester.pumpAndSettle();

    // Bar mode shows identical legend data (VAL-STAT-011).
    expect(legendAmount('expense_gifts'), beforeGifts);
    expect(legendPct('expense_gifts'), beforeGiftsPct);
    expect(legendAmount('expense_bills'), '-Rp 600,000');
    expect(legendPct('expense_bills'), '30.0%');

    // Totals/context unchanged (VAL-STAT-004).
    expect(_textWithKey(tester, 'stat-opening-balance').data, beforeOpening);
    expect(_textWithKey(tester, 'stat-ending-balance').data, beforeEnding);
    expect(
      _textWithKey(tester, 'overview-expense').data,
      beforeOverviewExpense,
    );
    expect(_textWithKey(tester, 'period-label').data, beforePeriod);
  });

  testWidgets('empty period shows a stable zero chart state in both modes', (
    tester,
  ) async {
    // No transactions seeded.
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Donut empty state with valid zero total, no slices/legend.
    expect(find.byKey(const ValueKey('structure-chart-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-legend')), findsNothing);
    expect(_textWithKey(tester, 'structure-chart-total').data, 'Rp 0');

    // Overview/balances are zeroed, not stale.
    expect(_textWithKey(tester, 'overview-expense').data, 'Rp 0');
    expect(_textWithKey(tester, 'stat-opening-balance').data, 'Rp 0');
    expect(_textWithKey(tester, 'stat-ending-balance').data, 'Rp 0');

    // Toggle to bar; empty state stays stable with no invalid values.
    await tester.tap(find.byKey(const ValueKey('stat-chart-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('structure-chart-empty')), findsOneWidget);
    expect(_textWithKey(tester, 'structure-chart-total').data, 'Rp 0');
    expect(find.textContaining('NaN'), findsNothing);
    expect(find.textContaining('Infinity'), findsNothing);
  });

  testWidgets('home structure chart/legend and balance refresh after a save', (
    tester,
  ) async {
    // Statistic home plus an Add button in the same ProviderScope so the
    // post-save invalidation reaches the statistic surface (regression for
    // the home Expense Structure card not refreshing while the overview did).
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
            body: const StatisticHomeScreen(),
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

    // Empty structure/balance state before any transaction.
    expect(find.byKey(const ValueKey('structure-chart-empty')), findsOneWidget);
    expect(_textWithKey(tester, 'stat-ending-balance').data, 'Rp 0');
    expect(_textWithKey(tester, 'overview-expense').data, 'Rp 0');

    // Add a Gifts expense within the active period.
    await tester.tap(find.byKey(const ValueKey('open-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('add-transaction-amount')),
      '1000000',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('add-transaction-category')));
    await tester.pumpAndSettle();
    final gifts = find.byKey(const ValueKey('category-row-expense_gifts'));
    await tester.ensureVisible(gifts);
    await tester.pumpAndSettle();
    await tester.tap(gifts);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-transaction-save')));
    await tester.pumpAndSettle();

    // Back on Statistic home: the structure card now shows the computed
    // Gifts data and the balance/overview reflect the new expense, without
    // any restart.
    expect(find.byKey(const ValueKey('structure-chart-empty')), findsNothing);
    expect(
      _textWithKey(tester, 'legend-amount-expense_gifts').data,
      '-Rp 1,000,000',
    );
    expect(
      _textWithKey(tester, 'legend-percentage-expense_gifts').data,
      '100.0%',
    );
    expect(_textWithKey(tester, 'structure-chart-total').data, '-Rp 1,000,000');
    expect(_textWithKey(tester, 'overview-expense').data, '-Rp 1,000,000');
    expect(_textWithKey(tester, 'stat-ending-balance').data, '-Rp 1,000,000');
  });

  testWidgets('Show more opens Structure detail with same period context', (
    tester,
  ) async {
    await seedExpenseStructure();

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'period-label').data, 'Jun 2026');

    await tester.tap(find.byKey(const ValueKey('stat-show-more')));
    await tester.pumpAndSettle();

    // Structure detail is shown with the same active period.
    expect(find.byType(StructureDetailScreen), findsOneWidget);
    expect(find.text('Structure'), findsOneWidget);
    expect(_textWithKey(tester, 'structure-period-label').data, 'Jun 2026');
    expect(find.byKey(const ValueKey('structure-tab-income')), findsOneWidget);
    expect(find.byKey(const ValueKey('structure-tab-expense')), findsOneWidget);
  });
}
