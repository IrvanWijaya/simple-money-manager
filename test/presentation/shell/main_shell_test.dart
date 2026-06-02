// Widget tests for the main app shell navigation and center add flow.
//
// Covers VAL-SHELL-001..004 and VAL-SHELL-006 behavior at the widget level:
// default Transaction tab, required tabs + center add action, tab switching
// preserves the shell, and the center add opens Add Transaction from every tab
// and restores the originating tab on back.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/presentation/shell/main_shell.dart';
import 'package:simple_money_manager/src/presentation/shell/shell_tab.dart';
import 'package:simple_money_manager/src/presentation/transactions/add_transaction_screen.dart';
import 'package:simple_money_manager/src/presentation/transactions/transaction_home_screen.dart';
import 'package:simple_money_manager/src/presentation/calendar/calendar_home_screen.dart';
import 'package:simple_money_manager/src/presentation/statistics/statistic_home_screen.dart';
import 'package:simple_money_manager/src/presentation/wallet/wallet_home_screen.dart';
import 'package:simple_money_manager/src/core/theme/app_theme.dart';
import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';

import '../../data/helpers/test_database.dart';

Widget _wrap(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(theme: AppTheme.dark, home: const MainShell()),
  );
}

/// Finds the bottom-bar tab button (label) for a given tab.
Finder _tabButton(String label) => find.widgetWithText(InkWell, label);

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('MainShell', () {
    testWidgets('lands on Transaction tab by default', (tester) async {
      await tester.pumpWidget(_wrap(db));
      await tester.pumpAndSettle();

      // IndexedStack keeps all surfaces in the tree; assert the selected
      // surface is the Transaction screen via the controller-driven index.
      expect(find.byType(TransactionHomeScreen), findsOneWidget);
      // All four surfaces exist (IndexedStack), but Transaction is index 0.
      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.index, ShellTab.transaction.index);
    });

    testWidgets('shows all four tabs and a center add action', (tester) async {
      await tester.pumpWidget(_wrap(db));
      await tester.pumpAndSettle();

      expect(_tabButton('Transaction'), findsOneWidget);
      expect(_tabButton('Calendar'), findsOneWidget);
      expect(_tabButton('Statistic'), findsOneWidget);
      expect(_tabButton('Wallet'), findsOneWidget);

      // Center add is a FloatingActionButton with a plus icon, distinct from
      // the four tabs.
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // "Add" is not a selectable tab label in the bottom bar.
      expect(_tabButton('Add'), findsNothing);
    });

    testWidgets('switching tabs changes the visible surface', (tester) async {
      await tester.pumpWidget(_wrap(db));
      await tester.pumpAndSettle();

      IndexedStack stack() =>
          tester.widget<IndexedStack>(find.byType(IndexedStack));

      await tester.tap(_tabButton('Calendar'));
      await tester.pumpAndSettle();
      expect(stack().index, ShellTab.calendar.index);

      await tester.tap(_tabButton('Statistic'));
      await tester.pumpAndSettle();
      expect(stack().index, ShellTab.statistic.index);

      await tester.tap(_tabButton('Wallet'));
      await tester.pumpAndSettle();
      expect(stack().index, ShellTab.wallet.index);

      await tester.tap(_tabButton('Transaction'));
      await tester.pumpAndSettle();
      expect(stack().index, ShellTab.transaction.index);

      // Shell chrome (bottom bar + add button) is preserved throughout.
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(BottomAppBar), findsOneWidget);
    });

    testWidgets('center add opens Add Transaction with back + SAVE', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Back restores the shell.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(AddTransactionScreen), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('center add works from every tab and restores origin', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(db));
      await tester.pumpAndSettle();

      IndexedStack stack() =>
          tester.widget<IndexedStack>(find.byType(IndexedStack));

      for (final tab in ShellTab.values) {
        await tester.tap(_tabButton(tab.label));
        await tester.pumpAndSettle();
        expect(stack().index, tab.index);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(find.byType(AddTransactionScreen), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Originating tab is restored.
        expect(stack().index, tab.index);
      }
    });

    testWidgets('uses the dark surface color for the bottom bar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(db));
      await tester.pumpAndSettle();

      final bottomBar = tester.widget<BottomAppBar>(find.byType(BottomAppBar));
      expect(bottomBar.color, AppColors.surface);

      // All four surface widgets exist in the IndexedStack (inactive children
      // are kept offstage, so include offstage in the search).
      expect(
        find.byType(CalendarHomeScreen, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.byType(StatisticHomeScreen, skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.byType(WalletHomeScreen, skipOffstage: false),
        findsOneWidget,
      );
    });
  });
}
