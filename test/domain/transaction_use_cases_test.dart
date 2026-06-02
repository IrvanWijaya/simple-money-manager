import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/data/repository/wallet_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/default_wallet.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/timeframe.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/domain/use_cases/use_cases.dart';

import '../data/helpers/test_database.dart';

MoneyTransaction _tx({
  required String id,
  required TransactionType type,
  required int amount,
  required DateTime date,
  String categoryId = 'expense_food',
}) {
  return MoneyTransaction(
    id: id,
    type: type,
    amount: amount,
    date: date,
    categoryId: categoryId,
  );
}

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl txRepo;
  late WalletRepositoryImpl walletRepo;

  setUp(() {
    db = createTestDatabase();
    txRepo = TransactionRepositoryImpl(db.transactionDao);
    walletRepo = WalletRepositoryImpl(db.walletDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('AddTransaction / UpdateTransaction / DeleteTransaction', () {
    test('add persists the exact integer magnitude and derives sign', () async {
      final add = AddTransaction(txRepo);
      await add(
        _tx(
          id: 't1',
          type: TransactionType.expense,
          amount: 545000,
          date: DateTime(2026, 6, 2, 9),
        ),
      );

      final stored = await txRepo.getById('t1');
      expect(stored!.amount, 545000);
      expect(stored.signedAmount, -545000);
    });

    test('update overwrites and delete removes', () async {
      final add = AddTransaction(txRepo);
      final update = UpdateTransaction(txRepo);
      final delete = DeleteTransaction(txRepo);

      final tx = _tx(
        id: 't1',
        type: TransactionType.income,
        amount: 1000,
        date: DateTime(2026, 6, 2),
      );
      await add(tx);
      await update(tx.copyWith(amount: 2500));
      expect((await txRepo.getById('t1'))!.amount, 2500);

      await delete('t1');
      expect(await txRepo.getById('t1'), isNull);
    });
  });

  group('GetTransactionsByPeriod', () {
    test('returns only transactions in the inclusive period range', () async {
      final add = AddTransaction(txRepo);
      // Selected period: June 2026 monthly.
      final range = Timeframe.monthly.rangeFor(DateTime(2026, 6, 15));

      await add(
        _tx(
          id: 'before',
          type: TransactionType.expense,
          amount: 1,
          date: DateTime(2026, 5, 31, 23, 59),
        ),
      );
      await add(
        _tx(
          id: 'start',
          type: TransactionType.income,
          amount: 1,
          date: DateTime(2026, 6, 1),
        ),
      );
      await add(
        _tx(
          id: 'end',
          type: TransactionType.expense,
          amount: 1,
          date: DateTime(2026, 6, 30, 23, 59, 59),
        ),
      );
      await add(
        _tx(
          id: 'after',
          type: TransactionType.income,
          amount: 1,
          date: DateTime(2026, 7, 1),
        ),
      );

      final useCase = GetTransactionsByPeriod(txRepo);
      final result = await useCase(range);
      expect(result.map((t) => t.id).toSet(), {'start', 'end'});
    });
  });

  group('GetPeriodSummary', () {
    test('income positive, expense magnitude, total is signed net', () async {
      final add = AddTransaction(txRepo);
      final range = Timeframe.monthly.rangeFor(DateTime(2026, 6, 1));

      await add(
        _tx(
          id: 'inc',
          type: TransactionType.income,
          amount: 5000000,
          date: DateTime(2026, 6, 10),
          categoryId: 'income_salary',
        ),
      );
      await add(
        _tx(
          id: 'exp',
          type: TransactionType.expense,
          amount: 3323000,
          date: DateTime(2026, 6, 12),
        ),
      );
      // Out-of-period transaction must not affect the summary.
      await add(
        _tx(
          id: 'out',
          type: TransactionType.expense,
          amount: 9999999,
          date: DateTime(2026, 7, 1),
        ),
      );

      final summary = await GetPeriodSummary(txRepo)(range);
      expect(summary.income, 5000000);
      expect(summary.expense, 3323000);
      expect(summary.total, 5000000 - 3323000);
    });

    test('empty period yields zeroed summary', () async {
      final range = Timeframe.monthly.rangeFor(DateTime(2026, 6, 1));
      final summary = await GetPeriodSummary(txRepo)(range);
      expect(summary.income, 0);
      expect(summary.expense, 0);
      expect(summary.total, 0);
      expect(summary.isEmpty, isTrue);
    });
  });

  group('GetTransactionDateGroups', () {
    test('groups by day with signed totals, days descending', () async {
      final add = AddTransaction(txRepo);
      final range = Timeframe.monthly.rangeFor(DateTime(2026, 6, 1));

      // June 2: income 10000 + expense 4000 -> total 6000.
      await add(
        _tx(
          id: 'a',
          type: TransactionType.income,
          amount: 10000,
          date: DateTime(2026, 6, 2, 8),
          categoryId: 'income_salary',
        ),
      );
      await add(
        _tx(
          id: 'b',
          type: TransactionType.expense,
          amount: 4000,
          date: DateTime(2026, 6, 2, 20),
        ),
      );
      // June 5: expense 2500 -> total -2500.
      await add(
        _tx(
          id: 'c',
          type: TransactionType.expense,
          amount: 2500,
          date: DateTime(2026, 6, 5, 12),
        ),
      );

      final groups = await GetTransactionDateGroups(txRepo)(range);
      expect(groups.length, 2);
      // Most recent day first.
      expect(groups.first.date, DateTime(2026, 6, 5));
      expect(groups.first.signedTotal, -2500);
      expect(groups.last.date, DateTime(2026, 6, 2));
      expect(groups.last.signedTotal, 6000);
      expect(groups.last.transactions.length, 2);
    });
  });

  group('GetDefaultWalletBalance', () {
    test('is all-time and not period-filtered', () async {
      final add = AddTransaction(txRepo);
      await walletRepo.saveWallet(const DefaultWallet(baseBalance: 1000000));

      await add(
        _tx(
          id: 'past',
          type: TransactionType.income,
          amount: 200000,
          date: DateTime(2025, 1, 1),
          categoryId: 'income_salary',
        ),
      );
      await add(
        _tx(
          id: 'now',
          type: TransactionType.expense,
          amount: 50000,
          date: DateTime(2026, 6, 2),
        ),
      );

      final balance = await GetDefaultWalletBalance(walletRepo, txRepo)();
      // 1,000,000 + 200,000 - 50,000.
      expect(balance, 1150000);
    });

    test('defaults to zero base balance when none saved', () async {
      final add = AddTransaction(txRepo);
      await add(
        _tx(
          id: 'x',
          type: TransactionType.income,
          amount: 7777,
          date: DateTime(2026, 6, 2),
          categoryId: 'income_salary',
        ),
      );
      final balance = await GetDefaultWalletBalance(walletRepo, txRepo)();
      expect(balance, 7777);
    });
  });

  group('GetWalletDisplay', () {
    test('combines wallet name with all-time balance', () async {
      final add = AddTransaction(txRepo);
      await walletRepo.saveWallet(
        const DefaultWallet(name: 'Cash', baseBalance: 500000),
      );
      await add(
        _tx(
          id: 'x',
          type: TransactionType.expense,
          amount: 100000,
          date: DateTime(2026, 6, 2),
        ),
      );

      final display = await GetWalletDisplay(walletRepo, txRepo)();
      expect(display.name, 'Cash');
      expect(display.balance, 400000);
    });
  });
}
