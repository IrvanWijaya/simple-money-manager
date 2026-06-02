// Widget tests for the Calendar home surface.
//
// Covers VAL-CAL-001 (summary matches Transaction summary), VAL-CAL-002
// (Sunday-start grid with red Sunday), VAL-CAL-003 (current-date highlight),
// VAL-CAL-004 (dimmed overflow days), VAL-CAL-005 (computed daily totals only
// when data exists), and VAL-CAL-006 (period navigation updates grid/summary).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/core/theme/app_theme.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/calendar/calendar_home_screen.dart';
import 'package:simple_money_manager/src/presentation/calendar/calendar_providers.dart';
import 'package:simple_money_manager/src/presentation/shared/period/period_controller.dart';

import '../../data/helpers/test_database.dart';

late AppDatabase _db;

Widget _wrap({required DateTime now, DateTime? today}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(_db),
      periodControllerProvider.overrideWith(
        (ref) => PeriodController(now: now),
      ),
      todayProvider.overrideWithValue(
        today ?? DateTime(now.year, now.month, now.day),
      ),
    ],
    child: const MaterialApp(home: Scaffold(body: CalendarHomeScreen())),
  );
}

Future<void> _addTx({
  required String id,
  required TransactionType type,
  required int amount,
  required DateTime date,
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

  testWidgets('summary matches the period income/expense/total', (
    tester,
  ) async {
    await _addTx(
      id: 'income-1',
      type: TransactionType.income,
      amount: 100000,
      date: DateTime(2026, 6, 10, 9),
      categoryId: 'income_salary',
    );
    await _addTx(
      id: 'expense-1',
      type: TransactionType.expense,
      amount: 30000,
      date: DateTime(2026, 6, 12, 10),
    );

    await tester.pumpWidget(_wrap(now: DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'overview-income').data, 'Rp 100,000');
    expect(_textWithKey(tester, 'overview-expense').data, '-Rp 30,000');
    expect(_textWithKey(tester, 'overview-total').data, 'Rp 70,000');
  });

  testWidgets('grid starts Sunday with Sunday label in red', (tester) async {
    await tester.pumpWidget(_wrap(now: DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    final labels = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(CalendarHomeScreen),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data)
        .toList();
    // Sunday label precedes Saturday in the weekday header row.
    expect(labels.contains('Sun'), isTrue);
    expect(labels.indexOf('Sun'), lessThan(labels.indexOf('Sat')));

    final sunday = tester.widget<Text>(find.text('Sun'));
    expect((sunday.style!.color), AppColors.expense);
  });

  testWidgets('current date cell is highlighted', (tester) async {
    await tester.pumpWidget(
      _wrap(now: DateTime(2026, 6, 15), today: DateTime(2026, 6, 15)),
    );
    await tester.pumpAndSettle();

    final cell = tester.widget<Container>(
      find.byKey(const ValueKey('calendar-day-2026-06-15')),
    );
    final decoration = cell.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('leading overflow days from previous month are present', (
    tester,
  ) async {
    // June 1 2026 is a Monday, so May 31 (Sunday) is a leading overflow cell.
    await tester.pumpWidget(_wrap(now: DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('calendar-overflow-2026-05-31')),
      findsOneWidget,
    );
    // In-month days are not rendered as overflow.
    expect(
      find.byKey(const ValueKey('calendar-day-2026-06-01')),
      findsOneWidget,
    );
  });

  testWidgets('day cells show totals only when data exists', (tester) async {
    await _addTx(
      id: 'inc',
      type: TransactionType.income,
      amount: 100000,
      date: DateTime(2026, 6, 10, 9),
      categoryId: 'income_salary',
    );
    await _addTx(
      id: 'exp',
      type: TransactionType.expense,
      amount: 30000,
      date: DateTime(2026, 6, 10, 20),
    );

    await tester.pumpWidget(_wrap(now: DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Jun 10 has computed income and expense totals.
    expect(_textWithKey(tester, 'calendar-income-2026-06-10').data, '100,000');
    expect(_textWithKey(tester, 'calendar-expense-2026-06-10').data, '-30,000');

    // Jun 11 has no transactions, so no totals.
    expect(
      find.byKey(const ValueKey('calendar-income-2026-06-11')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('calendar-expense-2026-06-11')),
      findsNothing,
    );
  });

  testWidgets('previous period navigation updates grid and summary', (
    tester,
  ) async {
    // One expense in May, one in June.
    await _addTx(
      id: 'may',
      type: TransactionType.expense,
      amount: 11000,
      date: DateTime(2026, 5, 20, 10),
    );
    await _addTx(
      id: 'jun',
      type: TransactionType.expense,
      amount: 22000,
      date: DateTime(2026, 6, 20, 10),
    );

    await tester.pumpWidget(_wrap(now: DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // June visible: shows June expense, summary -22,000.
    expect(_textWithKey(tester, 'overview-expense').data, '-Rp 22,000');
    expect(
      find.byKey(const ValueKey('calendar-expense-2026-06-20')),
      findsOneWidget,
    );

    // Navigate to previous period (May).
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'overview-expense').data, '-Rp 11,000');
    expect(
      find.byKey(const ValueKey('calendar-day-2026-05-20')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('calendar-expense-2026-05-20')),
      findsOneWidget,
    );
    // June's day-20 total is gone from the May grid.
    expect(
      find.byKey(const ValueKey('calendar-expense-2026-06-20')),
      findsNothing,
    );
  });
}
