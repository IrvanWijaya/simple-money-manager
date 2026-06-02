import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/domain/entities/entities.dart';

void main() {
  group('TransactionType', () {
    test('income/expense predicates', () {
      expect(TransactionType.income.isIncome, isTrue);
      expect(TransactionType.income.isExpense, isFalse);
      expect(TransactionType.expense.isExpense, isTrue);
    });
  });

  group('MoneyTransaction', () {
    test('signedAmount is positive for income, negative for expense', () {
      final income = MoneyTransaction(
        id: 'a',
        type: TransactionType.income,
        amount: 1000,
        date: DateTime(2026, 6, 1),
        categoryId: 'income_salary',
      );
      final expense = MoneyTransaction(
        id: 'b',
        type: TransactionType.expense,
        amount: 1000,
        date: DateTime(2026, 6, 1),
        categoryId: 'expense_food',
      );

      expect(income.signedAmount, 1000);
      expect(expense.signedAmount, -1000);
    });

    test('amount magnitude must be non-negative (release-safe)', () {
      expect(
        () => MoneyTransaction(
          id: 'a',
          type: TransactionType.income,
          amount: -1,
          date: DateTime(2026, 6, 1),
          categoryId: 'income_salary',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('isRecurring reflects recurringRuleId presence', () {
      final base = MoneyTransaction(
        id: 'a',
        type: TransactionType.expense,
        amount: 500,
        date: DateTime(2026, 6, 1),
        categoryId: 'expense_food',
      );
      expect(base.isRecurring, isFalse);
      expect(base.copyWith(recurringRuleId: 'r1').isRecurring, isTrue);
    });

    test('equality and copyWith', () {
      final a = MoneyTransaction(
        id: 'a',
        type: TransactionType.income,
        amount: 1000,
        date: DateTime(2026, 6, 1),
        categoryId: 'income_salary',
        description: 'pay',
      );
      expect(a, a.copyWith());
      expect(a.copyWith(amount: 2000).amount, 2000);
      expect(a == a.copyWith(amount: 2000), isFalse);
    });
  });

  group('DefaultWallet', () {
    test('balanceWith applies base balance plus signed total', () {
      const wallet = DefaultWallet(name: 'Cash', baseBalance: 1000000);
      expect(wallet.balanceWith(0), 1000000);
      expect(wallet.balanceWith(-323000), 677000);
      expect(wallet.balanceWith(50000), 1050000);
    });

    test('defaults to Cash with zero base balance', () {
      const wallet = DefaultWallet();
      expect(wallet.name, 'Cash');
      expect(wallet.baseBalance, 0);
    });
  });

  group('PeriodSummary', () {
    test('total is signed net of income and expense', () {
      const summary = PeriodSummary(income: 0, expense: 3323000);
      expect(summary.total, -3323000);
      expect(const PeriodSummary(income: 5000, expense: 2000).total, 3000);
    });

    test('isEmpty when both income and expense are zero', () {
      expect(const PeriodSummary().isEmpty, isTrue);
      expect(const PeriodSummary(income: 1).isEmpty, isFalse);
    });

    test('fromTransactions sums income and expense magnitudes', () {
      final summary = PeriodSummary.fromTransactions([
        MoneyTransaction(
          id: 'a',
          type: TransactionType.income,
          amount: 5000,
          date: DateTime(2026, 6, 1),
          categoryId: 'income_salary',
        ),
        MoneyTransaction(
          id: 'b',
          type: TransactionType.expense,
          amount: 2000,
          date: DateTime(2026, 6, 1),
          categoryId: 'expense_food',
        ),
        MoneyTransaction(
          id: 'c',
          type: TransactionType.expense,
          amount: 1000,
          date: DateTime(2026, 6, 1),
          categoryId: 'expense_food',
        ),
      ]);
      expect(summary.income, 5000);
      expect(summary.expense, 3000);
      expect(summary.total, 2000);
    });

    test('fromTransactions on empty list is zeroed', () {
      final summary = PeriodSummary.fromTransactions(const []);
      expect(summary.isEmpty, isTrue);
    });
  });

  group('TransactionDateGroup', () {
    test('signedTotal sums visible transactions with correct signs', () {
      final group = TransactionDateGroup(
        date: DateTime(2026, 6, 2),
        transactions: [
          MoneyTransaction(
            id: 'a',
            type: TransactionType.income,
            amount: 10000,
            date: DateTime(2026, 6, 2, 8),
            categoryId: 'income_salary',
          ),
          MoneyTransaction(
            id: 'b',
            type: TransactionType.expense,
            amount: 4000,
            date: DateTime(2026, 6, 2, 20),
            categoryId: 'expense_food',
          ),
        ],
      );
      expect(group.signedTotal, 6000);
    });
  });

  group('StatisticCategorySummary', () {
    test('holds category, amount, count, and percentage', () {
      const category = Category(
        id: 'expense_food',
        name: 'Food',
        type: TransactionType.expense,
      );
      const summary = StatisticCategorySummary(
        category: category,
        amount: 978000,
        transactionCount: 3,
        percentage: 29.4,
      );
      expect(summary.category.name, 'Food');
      expect(summary.amount, 978000);
      expect(summary.transactionCount, 3);
      expect(summary.percentage, 29.4);
    });
  });
}
