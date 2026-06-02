// Widget tests for the shared HomeHeader and PeriodOverview.
//
// Covers VAL-HDR-001 (header controls), VAL-HDR-002 (timeframe selector
// options), VAL-HDR-004 (period changes filter shared data), VAL-HDR-005
// (empty period zero state), and VAL-HDR-006 (current balance is all-time and
// stable across period changes).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/wallet_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/default_wallet.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/shared/period/home_header.dart';
import 'package:simple_money_manager/src/presentation/shared/period/period_controller.dart';
import 'package:simple_money_manager/src/presentation/shared/period/period_overview.dart';

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
    child: const MaterialApp(
      home: Scaffold(body: Column(children: [HomeHeader(), PeriodOverview()])),
    ),
  );
}

Future<void> _addTx({
  required AppDatabase db,
  required String id,
  required TransactionType type,
  required int amount,
  required DateTime date,
}) async {
  final repo = TransactionRepositoryImpl(db.transactionDao);
  await repo.add(
    MoneyTransaction(
      id: id,
      type: type,
      amount: amount,
      date: date,
      categoryId: 'food',
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

  testWidgets(
    'shows balance, period label, prev/next, timeframe and settings',
    (tester) async {
      await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
      await tester.pumpAndSettle();

      expect(find.text('Current Balance'), findsOneWidget);
      expect(find.byKey(const ValueKey('period-label')), findsOneWidget);
      expect(_textWithKey(tester, 'period-label').data, 'Jun 2026');
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    },
  );

  testWidgets('timeframe selector offers exactly Daily/Weekly/Monthly/Yearly', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);

    // Selecting Yearly updates the period label.
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(_textWithKey(tester, 'period-label').data, '2026');
  });

  testWidgets('overview reflects only active-period transactions', (
    tester,
  ) async {
    // In June: 100k income, 30k expense. In May: 999k expense (out of period).
    await _addTx(
      db: _db,
      id: 'jun-income',
      type: TransactionType.income,
      amount: 100000,
      date: DateTime(2026, 6, 10),
    );
    await _addTx(
      db: _db,
      id: 'jun-expense',
      type: TransactionType.expense,
      amount: 30000,
      date: DateTime(2026, 6, 12),
    );
    await _addTx(
      db: _db,
      id: 'may-expense',
      type: TransactionType.expense,
      amount: 999000,
      date: DateTime(2026, 5, 20),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'overview-income').data, 'Rp 100,000');
    expect(_textWithKey(tester, 'overview-expense').data, '-Rp 30,000');
    expect(_textWithKey(tester, 'overview-total').data, 'Rp 70,000');
  });

  testWidgets('navigating to an empty period shows a zero state', (
    tester,
  ) async {
    await _addTx(
      db: _db,
      id: 'jun-income',
      type: TransactionType.income,
      amount: 100000,
      date: DateTime(2026, 6, 10),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();
    expect(_textWithKey(tester, 'overview-income').data, 'Rp 100,000');

    // Move to next (empty) month.
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(_textWithKey(tester, 'period-label').data, 'Jul 2026');
    expect(_textWithKey(tester, 'overview-income').data, 'Rp 0');
    expect(_textWithKey(tester, 'overview-expense').data, 'Rp 0');
    expect(_textWithKey(tester, 'overview-total').data, 'Rp 0');
  });

  testWidgets('current balance stays all-time stable across period changes', (
    tester,
  ) async {
    final walletRepo = WalletRepositoryImpl(_db.walletDao);
    await walletRepo.saveWallet(const DefaultWallet(baseBalance: 1000000));
    await _addTx(
      db: _db,
      id: 'jun-expense',
      type: TransactionType.expense,
      amount: 200000,
      date: DateTime(2026, 6, 10),
    );

    await tester.pumpWidget(_wrap(DateTime(2026, 6, 15)));
    await tester.pumpAndSettle();

    // Balance = 1,000,000 base - 200,000 expense = 800,000 (all-time).
    expect(_textWithKey(tester, 'current-balance').data, 'Rp 800,000');

    // Move to an empty period; balance must not change.
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(_textWithKey(tester, 'period-label').data, 'Jul 2026');
    expect(_textWithKey(tester, 'current-balance').data, 'Rp 800,000');
    expect(_textWithKey(tester, 'overview-expense').data, 'Rp 0');
  });
}
