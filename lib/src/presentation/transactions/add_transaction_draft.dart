import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import '../recurring/recurring_selection.dart';

/// In-progress Add Transaction form state.
///
/// Holds the user's draft entries before they press SAVE. The draft owns the
/// transaction [type], the non-negative [amount] magnitude (sign is derived
/// from [type] at save time, never from punctuation), the [date]/time, the
/// optional [description] and [memo], the selected [category], and the optional
/// [recurring] configuration chosen in the Recurring bottom sheet.
///
/// The draft is intentionally pure: it has no Flutter, Drift, or Riverpod
/// dependency so it can be unit-tested directly.
class AddTransactionDraft {
  const AddTransactionDraft({
    required this.type,
    required this.amount,
    required this.date,
    this.description = '',
    this.memo = '',
    this.category,
    this.recurring = RecurringSelection.none,
  });

  /// Income or expense; controls the saved sign and the compatible category set.
  final TransactionType type;

  /// Non-negative magnitude in whole Rupiah.
  final int amount;

  /// Selected transaction date and time.
  final DateTime date;

  /// Optional user-entered description.
  final String description;

  /// Optional memo. Never affects summaries, statistics, or calendar totals.
  final String memo;

  /// Selected category, or `null` when none has been chosen yet.
  final Category? category;

  /// The recurring configuration applied via the Recurring bottom sheet.
  /// Defaults to [RecurringSelection.none] (no recurrence).
  final RecurringSelection recurring;

  /// Whether the draft can be saved: a positive amount and a chosen category.
  bool get isValid => amount > 0 && category != null;

  /// Whether this draft will also create a recurring rule on save.
  bool get isRecurring => recurring.isRecurring;

  AddTransactionDraft copyWith({
    TransactionType? type,
    int? amount,
    DateTime? date,
    String? description,
    String? memo,
    Category? category,
    RecurringSelection? recurring,
    bool clearCategory = false,
  }) {
    return AddTransactionDraft(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      category: clearCategory ? null : (category ?? this.category),
      recurring: recurring ?? this.recurring,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AddTransactionDraft &&
      other.type == type &&
      other.amount == amount &&
      other.date == date &&
      other.description == description &&
      other.memo == memo &&
      other.category == category &&
      other.recurring == recurring;

  @override
  int get hashCode =>
      Object.hash(type, amount, date, description, memo, category, recurring);

  @override
  String toString() =>
      'AddTransactionDraft($type, $amount, $date, cat: ${category?.id}, '
      'recurring: $recurring)';
}
