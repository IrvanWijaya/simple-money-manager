import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/timeframe.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/domain/use_cases/get_calendar_day_totals.dart';

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
  late TransactionRepositoryImpl repo;

  setUp(() {
    db = createTestDatabase();
    repo = TransactionRepositoryImpl(db.transactionDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('totals are grouped per day and only for days with data', () async {
    final range = Timeframe.monthly.rangeFor(DateTime(2026, 6, 15));

    // Jun 10: income 100,000 + expense 30,000.
    await repo.add(
      _tx(
        id: 'a',
        type: TransactionType.income,
        amount: 100000,
        date: DateTime(2026, 6, 10, 9),
        categoryId: 'income_salary',
      ),
    );
    await repo.add(
      _tx(
        id: 'b',
        type: TransactionType.expense,
        amount: 30000,
        date: DateTime(2026, 6, 10, 20),
      ),
    );
    // Jun 12: expense 5,000 only.
    await repo.add(
      _tx(
        id: 'c',
        type: TransactionType.expense,
        amount: 5000,
        date: DateTime(2026, 6, 12, 12),
      ),
    );

    final totals = await GetCalendarDayTotals(repo)(range);

    expect(totals.keys.toSet(), {DateTime(2026, 6, 10), DateTime(2026, 6, 12)});
    expect(totals[DateTime(2026, 6, 10)]!.income, 100000);
    expect(totals[DateTime(2026, 6, 10)]!.expense, 30000);
    expect(totals[DateTime(2026, 6, 12)]!.income, 0);
    expect(totals[DateTime(2026, 6, 12)]!.expense, 5000);
    // A day without transactions has no entry (no stale totals).
    expect(totals.containsKey(DateTime(2026, 6, 11)), isFalse);
  });

  test('only transactions inside the active range contribute', () async {
    final range = Timeframe.monthly.rangeFor(DateTime(2026, 6, 15));

    await repo.add(
      _tx(
        id: 'in',
        type: TransactionType.expense,
        amount: 1000,
        date: DateTime(2026, 6, 5),
      ),
    );
    // Just before and after the June period must be excluded.
    await repo.add(
      _tx(
        id: 'before',
        type: TransactionType.expense,
        amount: 9999,
        date: DateTime(2026, 5, 31, 23, 59),
      ),
    );
    await repo.add(
      _tx(
        id: 'after',
        type: TransactionType.expense,
        amount: 8888,
        date: DateTime(2026, 7, 1, 0, 1),
      ),
    );

    final totals = await GetCalendarDayTotals(repo)(range);

    expect(totals.keys.toSet(), {DateTime(2026, 6, 5)});
    expect(totals[DateTime(2026, 6, 5)]!.expense, 1000);
  });

  test('empty period yields an empty map', () async {
    final range = Timeframe.monthly.rangeFor(DateTime(2026, 6, 15));
    final totals = await GetCalendarDayTotals(repo)(range);
    expect(totals, isEmpty);
  });
}
