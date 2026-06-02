import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/money_transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/use_cases/add_transaction.dart';
import '../../domain/use_cases/generate_due_recurring_transactions.dart';
import '../../domain/use_cases/save_recurring_rule.dart';
import '../recurring/recurring_selection.dart';
import 'add_transaction_draft.dart';

/// Drives the Add Transaction form draft and the save action.
///
/// Opens in [TransactionType.expense] with a zero amount, no category, and the
/// current date/time, so the form is immediately a valid Expense entry surface
/// (VAL-ADD-001). Switching type clears any category whose type no longer
/// matches, preventing incompatible category/type combinations (VAL-ADD-014).
/// [save] derives the stored sign from [AddTransactionDraft.type] via
/// [MoneyTransaction.signedAmount] and never from user punctuation.
class AddTransactionController extends StateNotifier<AddTransactionDraft> {
  AddTransactionController({
    required this.addTransaction,
    required this.saveRecurringRule,
    required this.generateDueRecurringTransactions,
    required this.idGenerator,
    DateTime? now,
    RecurringSelection initialRecurring = RecurringSelection.none,
  }) : super(
         AddTransactionDraft(
           type: TransactionType.expense,
           amount: 0,
           date: now ?? DateTime.now(),
           recurring: initialRecurring,
         ),
       );

  /// Use case that persists a new transaction.
  final AddTransaction addTransaction;

  /// Use case that persists a recurring rule.
  final SaveRecurringRule saveRecurringRule;

  /// Use case that materializes due recurring occurrences so a freshly saved
  /// rule's due transactions appear immediately.
  final GenerateDueRecurringTransactions generateDueRecurringTransactions;

  /// Generates the id for a newly saved transaction. Injected so tests can use
  /// deterministic ids.
  final String Function() idGenerator;

  /// Current draft. Convenience accessor for tests and callers that only need
  /// to read the latest draft snapshot.
  AddTransactionDraft get draft => state;

  /// Selects the transaction [type]. Clears the selected category when its type
  /// no longer matches so an income transaction can never keep an expense
  /// category (and vice versa) (VAL-ADD-014).
  void setType(TransactionType type) {
    if (type == state.type) return;
    final category = state.category;
    final keepCategory = category != null && category.type == type;
    state = state.copyWith(
      type: type,
      category: keepCategory ? category : null,
      clearCategory: !keepCategory,
    );
  }

  /// Sets the non-negative amount magnitude.
  void setAmount(int amount) {
    state = state.copyWith(amount: amount < 0 ? 0 : amount);
  }

  /// Sets the transaction date/time.
  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  /// Sets the optional description.
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Sets the optional memo.
  void setMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  /// Selects a category. A category whose type does not match the current
  /// transaction type is ignored to preserve type compatibility (VAL-ADD-014).
  void setCategory(Category category) {
    if (category.type != state.type) return;
    state = state.copyWith(category: category);
  }

  /// Applies the recurring configuration chosen in the Recurring bottom sheet.
  ///
  /// A non-recurring selection (None) clears any prior recurrence so saving the
  /// transaction creates no recurring rule (VAL-RECUI-011).
  void setRecurring(RecurringSelection selection) {
    state = state.copyWith(recurring: selection);
  }

  /// Persists the draft as a new transaction when valid.
  ///
  /// Returns `true` when a transaction was created, `false` when the draft is
  /// invalid (zero amount or no category), in which case nothing is persisted
  /// (VAL-ADD-005). The stored [MoneyTransaction.amount] is the non-negative
  /// magnitude; its sign is derived from the type.
  Future<bool> save() async {
    final draft = state;
    if (!draft.isValid) return false;
    final now = DateTime.now();
    final description = draft.description.trim();
    final memo = draft.memo.trim();

    if (draft.isRecurring) {
      // A recurring transaction is represented by a recurring rule; its due
      // occurrences (including the first, on the start date) are materialized
      // by the generator so no separate one-off transaction is created
      // (avoiding a duplicate of occurrence 1).
      final rule = draft.recurring.toRule(
        id: idGenerator(),
        type: draft.type,
        amount: draft.amount,
        categoryId: draft.category!.id,
        startDate: draft.date,
        description: description,
        memo: memo,
        createdAt: now,
        updatedAt: now,
      );
      if (rule != null) {
        await saveRecurringRule.call(rule);
        await generateDueRecurringTransactions.generateForRule(rule);
        return true;
      }
    }

    await addTransaction.call(
      MoneyTransaction(
        id: idGenerator(),
        type: draft.type,
        amount: draft.amount,
        date: draft.date,
        categoryId: draft.category!.id,
        description: description,
        memo: memo,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return true;
  }
}
