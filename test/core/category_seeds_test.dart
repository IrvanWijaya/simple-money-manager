import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/core/seed/category_seeds.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';

void main() {
  group('CategorySeeds names', () {
    test('income names match the reference exactly and in order', () {
      expect(CategorySeeds.incomeNames, <String>[
        'Allowance',
        'Award',
        'Bonus',
        'Dividend',
        'Investment',
        'Lottery',
        'Salary',
        'Tips',
        'Others',
        'Freelance',
      ]);
    });

    test('expense names match the reference exactly and in order', () {
      expect(CategorySeeds.expenseNames, <String>[
        'Bills',
        'Clothing',
        'Education',
        'Entertainment',
        'Fitness',
        'Food',
        'Gifts',
        'Health',
        'Furniture',
        'Pet',
        'Shopping',
        'Transportation',
        'Travel',
        'Others',
        'Movie',
        'Game',
        'Wishlist',
        'Self Care',
        'Dating',
        'Device',
      ]);
    });
  });

  group('CategorySeeds.all', () {
    test('builds income then expense in canonical order', () {
      final all = CategorySeeds.all();
      expect(all.length, 30);
      expect(all.first.name, 'Allowance');
      expect(all.first.type, TransactionType.income);
      expect(all.last.name, 'Device');
      expect(all.last.type, TransactionType.expense);
    });

    test('income and expense categories carry the correct type', () {
      expect(
        CategorySeeds.income().every((c) => c.type == TransactionType.income),
        isTrue,
      );
      expect(
        CategorySeeds.expense().every((c) => c.type == TransactionType.expense),
        isTrue,
      );
    });

    test('seedOrder is sequential within each type', () {
      final income = CategorySeeds.income();
      for (var i = 0; i < income.length; i++) {
        expect(income[i].seedOrder, i);
      }
    });

    test('ids are unique across all seeds (no income/expense collision)', () {
      final ids = CategorySeeds.all().map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
      // The shared "Others" name yields distinct ids per type.
      expect(
        CategorySeeds.idFor(TransactionType.income, 'Others'),
        'income_others',
      );
      expect(
        CategorySeeds.idFor(TransactionType.expense, 'Others'),
        'expense_others',
      );
    });

    test('multi-word names slugify deterministically', () {
      expect(
        CategorySeeds.idFor(TransactionType.expense, 'Self Care'),
        'expense_self_care',
      );
    });

    test('repeated seed builds are identical (idempotent, no duplication)', () {
      expect(CategorySeeds.all(), CategorySeeds.all());
    });
  });
}
