import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/transaction_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';

import 'helpers/test_database.dart';

MoneyTransaction _tx({
  required String id,
  required TransactionType type,
  required int amount,
  required DateTime date,
  String categoryId = 'expense_food',
  String? recurringRuleId,
  String? occurrenceKey,
}) {
  return MoneyTransaction(
    id: id,
    type: type,
    amount: amount,
    date: date,
    categoryId: categoryId,
    recurringRuleId: recurringRuleId,
    occurrenceKey: occurrenceKey,
  );
}

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl repository;

  setUp(() {
    db = createTestDatabase();
    repository = TransactionRepositoryImpl(db.transactionDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('add then getById round-trips through domain entity', () async {
    final tx = _tx(
      id: 't1',
      type: TransactionType.expense,
      amount: 15000,
      date: DateTime(2026, 6, 2, 10, 30),
    );
    await repository.add(tx);

    final loaded = await repository.getById('t1');
    expect(loaded, isNotNull);
    expect(loaded, isA<MoneyTransaction>());
    expect(loaded!.amount, 15000);
    expect(loaded.type, TransactionType.expense);
    expect(loaded.date, DateTime(2026, 6, 2, 10, 30));
  });

  test('update overwrites existing transaction', () async {
    final tx = _tx(
      id: 't1',
      type: TransactionType.income,
      amount: 100,
      date: DateTime(2026, 6, 2),
    );
    await repository.add(tx);
    await repository.update(tx.copyWith(amount: 250));

    final loaded = await repository.getById('t1');
    expect(loaded!.amount, 250);

    final all = await repository.getAll();
    expect(all.length, 1);
  });

  test('delete removes the transaction', () async {
    await repository.add(
      _tx(
        id: 't1',
        type: TransactionType.income,
        amount: 100,
        date: DateTime(2026, 6, 2),
      ),
    );
    await repository.delete('t1');
    expect(await repository.getById('t1'), isNull);
    expect(await repository.getAll(), isEmpty);
  });

  test('getAll orders by date descending then id', () async {
    await repository.add(
      _tx(
        id: 'b',
        type: TransactionType.expense,
        amount: 1,
        date: DateTime(2026, 6, 1),
      ),
    );
    await repository.add(
      _tx(
        id: 'a',
        type: TransactionType.expense,
        amount: 1,
        date: DateTime(2026, 6, 3),
      ),
    );
    await repository.add(
      _tx(
        id: 'c',
        type: TransactionType.expense,
        amount: 1,
        date: DateTime(2026, 6, 2),
      ),
    );

    final all = await repository.getAll();
    expect(all.map((t) => t.id).toList(), ['a', 'c', 'b']);
  });

  test('getByDateRange returns only in-range transactions inclusive', () async {
    final start = DateTime(2026, 6, 1);
    final end = DateTime(2026, 6, 30, 23, 59, 59, 999);

    await repository.add(
      _tx(
        id: 'before',
        type: TransactionType.expense,
        amount: 1,
        date: DateTime(2026, 5, 31, 23, 59),
      ),
    );
    await repository.add(
      _tx(id: 'inStart', type: TransactionType.income, amount: 1, date: start),
    );
    await repository.add(
      _tx(
        id: 'inEnd',
        type: TransactionType.expense,
        amount: 1,
        date: DateTime(2026, 6, 30, 12),
      ),
    );
    await repository.add(
      _tx(
        id: 'after',
        type: TransactionType.income,
        amount: 1,
        date: DateTime(2026, 7, 1),
      ),
    );

    final inRange = await repository.getByDateRange(start, end);
    expect(inRange.map((t) => t.id).toSet(), {'inStart', 'inEnd'});
  });

  test('preserves recurring metadata fields', () async {
    await repository.add(
      _tx(
        id: 'r1',
        type: TransactionType.expense,
        amount: 5000,
        date: DateTime(2026, 6, 2),
        recurringRuleId: 'rule-1',
        occurrenceKey: 'rule-1@2026-06-02T00:00:00.000',
      ),
    );

    final loaded = await repository.getById('r1');
    expect(loaded!.recurringRuleId, 'rule-1');
    expect(loaded.occurrenceKey, 'rule-1@2026-06-02T00:00:00.000');
    expect(loaded.isRecurring, isTrue);
  });

  test('watchAll emits updated lists on change', () async {
    final emissions = <int>[];
    final sub = repository.watchAll().listen((list) {
      emissions.add(list.length);
    });

    await repository.add(
      _tx(
        id: 't1',
        type: TransactionType.income,
        amount: 1,
        date: DateTime(2026, 6, 2),
      ),
    );
    await repository.add(
      _tx(
        id: 't2',
        type: TransactionType.expense,
        amount: 1,
        date: DateTime(2026, 6, 3),
      ),
    );
    // Allow the stream to flush emissions.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(emissions.last, 2);
  });
}
