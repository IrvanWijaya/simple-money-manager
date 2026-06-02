import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/category_repository_impl.dart';
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
  required String categoryId,
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
  late CategoryRepositoryImpl categoryRepo;

  setUp(() async {
    db = createTestDatabase();
    txRepo = TransactionRepositoryImpl(db.transactionDao);
    walletRepo = WalletRepositoryImpl(db.walletDao);
    categoryRepo = CategoryRepositoryImpl(db.categoryDao);
    await categoryRepo.ensureSeeded();
  });

  tearDown(() async {
    await db.close();
  });

  group('GetStatisticOverview', () {
    test('opening balance uses all signed transactions before period start; '
        'ending equals opening plus active-period total', () async {
      final add = AddTransaction(txRepo);
      await walletRepo.saveWallet(const DefaultWallet(baseBalance: 1000000));

      // Before period (May): +200,000 income.
      await add(
        _tx(
          id: 'before',
          type: TransactionType.income,
          amount: 200000,
          date: DateTime(2026, 5, 15),
          categoryId: 'income_salary',
        ),
      );
      // In period (June): +5,000,000 income, -3,323,000 expense.
      await add(
        _tx(
          id: 'inInc',
          type: TransactionType.income,
          amount: 5000000,
          date: DateTime(2026, 6, 10),
          categoryId: 'income_salary',
        ),
      );
      await add(
        _tx(
          id: 'inExp',
          type: TransactionType.expense,
          amount: 3323000,
          date: DateTime(2026, 6, 12),
          categoryId: 'expense_food',
        ),
      );
      // After period (July): must not affect opening/ending/overview.
      await add(
        _tx(
          id: 'after',
          type: TransactionType.expense,
          amount: 9999999,
          date: DateTime(2026, 7, 1),
          categoryId: 'expense_food',
        ),
      );

      final june = Timeframe.monthly.rangeFor(DateTime(2026, 6, 15));
      final overview = await GetStatisticOverview(walletRepo, txRepo)(june);

      // 1,000,000 base + 200,000 before-period income.
      expect(overview.openingBalance, 1200000);
      expect(overview.income, 5000000);
      expect(overview.expense, 3323000);
      expect(overview.total, 5000000 - 3323000);
      // opening + period total.
      expect(overview.endingBalance, 1200000 + (5000000 - 3323000));
    });

    test(
      'period navigation recomputes opening/ending for the new range',
      () async {
        final add = AddTransaction(txRepo);
        await walletRepo.saveWallet(const DefaultWallet(baseBalance: 1000000));

        await add(
          _tx(
            id: 'may',
            type: TransactionType.income,
            amount: 200000,
            date: DateTime(2026, 5, 15),
            categoryId: 'income_salary',
          ),
        );
        await add(
          _tx(
            id: 'jun',
            type: TransactionType.income,
            amount: 5000000,
            date: DateTime(2026, 6, 10),
            categoryId: 'income_salary',
          ),
        );

        final useCase = GetStatisticOverview(walletRepo, txRepo);

        final may = await useCase(
          Timeframe.monthly.rangeFor(DateTime(2026, 5, 1)),
        );
        // Nothing before May -> opening is base only.
        expect(may.openingBalance, 1000000);
        expect(may.income, 200000);
        expect(may.endingBalance, 1200000);

        final june = await useCase(
          Timeframe.monthly.rangeFor(DateTime(2026, 6, 1)),
        );
        // May income now sits before June -> opening grows.
        expect(june.openingBalance, 1200000);
        expect(june.income, 5000000);
        expect(june.endingBalance, 6200000);
      },
    );

    test(
      'empty period yields zero overview but preserves opening balance',
      () async {
        final add = AddTransaction(txRepo);
        await walletRepo.saveWallet(const DefaultWallet(baseBalance: 500000));
        await add(
          _tx(
            id: 'past',
            type: TransactionType.income,
            amount: 100000,
            date: DateTime(2026, 1, 1),
            categoryId: 'income_salary',
          ),
        );

        final overview = await GetStatisticOverview(walletRepo, txRepo)(
          Timeframe.monthly.rangeFor(DateTime(2026, 6, 1)),
        );
        expect(overview.income, 0);
        expect(overview.expense, 0);
        expect(overview.total, 0);
        expect(overview.openingBalance, 600000);
        expect(overview.endingBalance, 600000);
      },
    );
  });

  group('GetStatisticCategorySummary', () {
    Future<void> seedExpenses(AddTransaction add) async {
      // Food: 600,000 + 400,000 = 1,000,000 over 2 transactions.
      await add(
        _tx(
          id: 'food1',
          type: TransactionType.expense,
          amount: 600000,
          date: DateTime(2026, 6, 3),
          categoryId: 'expense_food',
        ),
      );
      await add(
        _tx(
          id: 'food2',
          type: TransactionType.expense,
          amount: 400000,
          date: DateTime(2026, 6, 9),
          categoryId: 'expense_food',
        ),
      );
      // Gifts: 1,000,000 (ties Food on amount).
      await add(
        _tx(
          id: 'gifts1',
          type: TransactionType.expense,
          amount: 1000000,
          date: DateTime(2026, 6, 5),
          categoryId: 'expense_gifts',
        ),
      );
      // Travel: 500,000.
      await add(
        _tx(
          id: 'travel1',
          type: TransactionType.expense,
          amount: 500000,
          date: DateTime(2026, 6, 7),
          categoryId: 'expense_travel',
        ),
      );
      // Income in period must be excluded from expense summary.
      await add(
        _tx(
          id: 'salary',
          type: TransactionType.income,
          amount: 7000000,
          date: DateTime(2026, 6, 1),
          categoryId: 'income_salary',
        ),
      );
      // Out-of-period expense must be excluded.
      await add(
        _tx(
          id: 'foodOut',
          type: TransactionType.expense,
          amount: 9999999,
          date: DateTime(2026, 7, 1),
          categoryId: 'expense_food',
        ),
      );
    }

    test(
      'computes amount, count, and percentage by category/type/period',
      () async {
        final add = AddTransaction(txRepo);
        await seedExpenses(add);

        final rows = await GetStatisticCategorySummary(txRepo, categoryRepo)(
          Timeframe.monthly.rangeFor(DateTime(2026, 6, 1)),
          TransactionType.expense,
        );

        final byId = {for (final r in rows) r.category.id: r};
        expect(
          byId.keys,
          containsAll(['expense_food', 'expense_gifts', 'expense_travel']),
        );

        // Type total = 1,000,000 + 1,000,000 + 500,000 = 2,500,000.
        expect(byId['expense_food']!.amount, 1000000);
        expect(byId['expense_food']!.transactionCount, 2);
        expect(byId['expense_food']!.percentage, closeTo(40.0, 1e-9));

        expect(byId['expense_gifts']!.amount, 1000000);
        expect(byId['expense_gifts']!.transactionCount, 1);
        expect(byId['expense_gifts']!.percentage, closeTo(40.0, 1e-9));

        expect(byId['expense_travel']!.amount, 500000);
        expect(byId['expense_travel']!.transactionCount, 1);
        expect(byId['expense_travel']!.percentage, closeTo(20.0, 1e-9));
      },
    );

    test(
      'rows sort by descending amount then stable seed order for ties',
      () async {
        final add = AddTransaction(txRepo);
        await seedExpenses(add);

        final rows = await GetStatisticCategorySummary(txRepo, categoryRepo)(
          Timeframe.monthly.rangeFor(DateTime(2026, 6, 1)),
          TransactionType.expense,
        );

        // Food (seedOrder 5) and Gifts (seedOrder 6) tie at 1,000,000;
        // Food sorts first. Travel (500,000) sorts last.
        expect(rows.map((r) => r.category.id).toList(), [
          'expense_food',
          'expense_gifts',
          'expense_travel',
        ]);
      },
    );

    test('only income categories appear for income type', () async {
      final add = AddTransaction(txRepo);
      await seedExpenses(add);

      final rows = await GetStatisticCategorySummary(txRepo, categoryRepo)(
        Timeframe.monthly.rangeFor(DateTime(2026, 6, 1)),
        TransactionType.income,
      );
      expect(rows.length, 1);
      expect(rows.single.category.id, 'income_salary');
      expect(rows.single.amount, 7000000);
      expect(rows.single.percentage, closeTo(100.0, 1e-9));
    });

    test('empty period/type yields no rows', () async {
      final rows = await GetStatisticCategorySummary(txRepo, categoryRepo)(
        Timeframe.monthly.rangeFor(DateTime(2026, 6, 1)),
        TransactionType.expense,
      );
      expect(rows, isEmpty);
    });
  });
}
