// Regression test for the transient empty Transaction-list frame after save.
//
// When a transaction is saved, refreshTransactionDerivedData invalidates
// transactionDateGroupsProvider. Because the Transaction home stays mounted
// (under the pushed Add screen), the provider transitions through AsyncLoading
// while it recomputes. Without skipLoadingOnReload the list swaps to a spinner
// (and, once resolved with the new data, can momentarily mismatch), flashing a
// transient blank frame instead of preserving the previously rendered list.
//
// This test drives that exact reload window with a controllable, delayed future
// so the loading phase spans real frames, and asserts the prior content is
// preserved (no spinner / empty state) throughout the reload.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/domain/entities/category.dart';
import 'package:simple_money_manager/src/domain/entities/money_transaction.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_date_group.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/transactions/transaction_providers.dart';
import 'package:simple_money_manager/src/presentation/transactions/widgets/transaction_list.dart';

/// Drives reloads of the overridden groups provider. Bumping it forces the
/// FutureProvider to recompute, modelling the post-save invalidation.
final _reloadTickProvider = StateProvider<int>((ref) => 0);

List<TransactionDateGroup> _groups(int count) {
  return [
    TransactionDateGroup(
      date: DateTime(2026, 6, 10),
      transactions: [
        for (var i = 0; i < count; i++)
          MoneyTransaction(
            id: 'tx-$i',
            type: TransactionType.expense,
            amount: 1000 * (i + 1),
            date: DateTime(2026, 6, 10, 9, i),
            categoryId: 'expense_food',
            description: 'Item $i',
          ),
      ],
    ),
  ];
}

void main() {
  testWidgets(
    'preserves prior list content during a delayed reload (no blank flicker)',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Categories resolve immediately so row rendering is not the source
            // of any loading state.
            categoriesByIdProvider.overrideWith(
              (ref) async => <String, Category>{
                'expense_food': const Category(
                  id: 'expense_food',
                  name: 'Food',
                  type: TransactionType.expense,
                ),
              },
            ),
            // The groups provider recomputes whenever the tick changes. The
            // first load resolves immediately; subsequent reloads take a real
            // delay so the AsyncLoading window spans multiple frames.
            transactionDateGroupsProvider.overrideWith((ref) async {
              final tick = ref.watch(_reloadTickProvider);
              if (tick == 0) {
                return _groups(1);
              }
              await Future<void>.delayed(const Duration(milliseconds: 100));
              return _groups(2);
            }),
          ],
          child: const MaterialApp(home: Scaffold(body: TransactionList())),
        ),
      );
      await tester.pumpAndSettle();

      // Initial load: the list is shown with the first transaction.
      expect(find.byKey(const ValueKey('transaction-list')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transaction-empty-state')),
        findsNothing,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Item 0'), findsOneWidget);

      // Trigger a reload (models refreshTransactionDerivedData after save).
      final element = tester.element(find.byType(TransactionList));
      final container = ProviderScope.containerOf(element);
      container.read(_reloadTickProvider.notifier).state = 1;

      // Pump through the entire reload window one frame at a time. With
      // skipLoadingOnReload the list must keep its prior content the whole
      // time: no spinner, no empty state, and the existing row stays visible.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          find.byType(CircularProgressIndicator),
          findsNothing,
          reason: 'reload must not swap the list for a loading spinner',
        );
        expect(
          find.byKey(const ValueKey('transaction-empty-state')),
          findsNothing,
          reason: 'reload must not flash the empty state',
        );
        expect(
          find.byKey(const ValueKey('transaction-list')),
          findsOneWidget,
          reason: 'the previously rendered list must stay mounted',
        );
        expect(
          find.text('Item 0'),
          findsOneWidget,
          reason: 'prior content must be preserved during reload',
        );
      }

      // After the reload settles, the new data is shown without ever blanking.
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transaction-empty-state')),
        findsNothing,
      );
    },
  );
}
