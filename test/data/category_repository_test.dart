import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/core/seed/category_seeds.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/category_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';

import 'helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl repository;

  setUp(() {
    db = createTestDatabase();
    repository = CategoryRepositoryImpl(db.categoryDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl.ensureSeeded', () {
    test('seeds the full canonical category set exactly once', () async {
      await repository.ensureSeeded();

      final all = await repository.getAll();
      expect(all.length, CategorySeeds.all().length);

      final income = await repository.getByType(TransactionType.income);
      final expense = await repository.getByType(TransactionType.expense);
      expect(income.map((c) => c.name).toList(), CategorySeeds.incomeNames);
      expect(expense.map((c) => c.name).toList(), CategorySeeds.expenseNames);
    });

    test('repeated initialization does not duplicate categories or labels '
        '(VAL-PERSIST-007)', () async {
      await repository.ensureSeeded();
      await repository.ensureSeeded();
      await repository.ensureSeeded();

      final all = await repository.getAll();
      expect(all.length, CategorySeeds.all().length);

      // No duplicate ids.
      final ids = all.map((c) => c.id).toSet();
      expect(ids.length, all.length);

      // Exact unique name set per type (income/expense Others stay distinct).
      final incomeNames = (await repository.getByType(
        TransactionType.income,
      )).map((c) => c.name).toList();
      final expenseNames = (await repository.getByType(
        TransactionType.expense,
      )).map((c) => c.name).toList();
      expect(incomeNames, CategorySeeds.incomeNames);
      expect(expenseNames, CategorySeeds.expenseNames);
    });

    test('income and expense "Others" categories never collide', () async {
      await repository.ensureSeeded();

      final incomeOthers = await repository.getById(
        CategorySeeds.idFor(TransactionType.income, 'Others'),
      );
      final expenseOthers = await repository.getById(
        CategorySeeds.idFor(TransactionType.expense, 'Others'),
      );

      expect(incomeOthers, isNotNull);
      expect(expenseOthers, isNotNull);
      expect(incomeOthers!.id, isNot(expenseOthers!.id));
      expect(incomeOthers.type, TransactionType.income);
      expect(expenseOthers.type, TransactionType.expense);
    });

    test('exposes domain entities, not Drift rows', () async {
      await repository.ensureSeeded();
      final category = await repository.getById(
        CategorySeeds.idFor(TransactionType.expense, 'Food'),
      );
      expect(category, isNotNull);
      expect(category!.name, 'Food');
      expect(category.type, TransactionType.expense);
    });
  });
}
