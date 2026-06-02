import 'transaction_type.dart';

/// A single recorded money movement.
///
/// [amount] is always a non-negative magnitude in whole Rupiah. The sign is
/// derived from [type] (income positive, expense negative) via [signedAmount];
/// user-entered punctuation never determines the sign.
class MoneyTransaction {
  /// Creates a transaction, enforcing the non-negative [amount] invariant.
  ///
  /// The invariant is guarded with a release-safe [ArgumentError] rather than a
  /// debug-only `assert`, because the persistence and use-case layers rely on
  /// [signedAmount] deriving the sign from [type]. A negative magnitude would
  /// silently invert that sign, so it is rejected in all build modes.
  MoneyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.description = '',
    this.memo = '',
    this.recurringRuleId,
    this.occurrenceKey,
    this.createdAt,
    this.updatedAt,
  }) {
    if (amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'must be a non-negative magnitude',
      );
    }
  }

  /// Stable unique identifier.
  final String id;

  /// Income or expense.
  final TransactionType type;

  /// Non-negative magnitude in whole Rupiah.
  final int amount;

  /// Transaction date and time (used for period filtering and grouping).
  final DateTime date;

  /// Identifier of the associated [Category].
  final String categoryId;

  /// Optional user-entered description shown in transaction rows.
  final String description;

  /// Optional memo. Does not affect summaries, statistics, or calendar totals.
  final String memo;

  /// Set when this transaction originated from a recurring rule.
  final String? recurringRuleId;

  /// Idempotency key for a generated recurring occurrence
  /// (typically `ruleId@occurrenceInstant`).
  final String? occurrenceKey;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Amount with sign applied: positive for income, negative for expense.
  int get signedAmount => type.isExpense ? -amount : amount;

  /// Whether this transaction was generated from a recurring rule.
  bool get isRecurring => recurringRuleId != null;

  MoneyTransaction copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    DateTime? date,
    String? categoryId,
    String? description,
    String? memo,
    String? recurringRuleId,
    String? occurrenceKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      occurrenceKey: occurrenceKey ?? this.occurrenceKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MoneyTransaction &&
      other.id == id &&
      other.type == type &&
      other.amount == amount &&
      other.date == date &&
      other.categoryId == categoryId &&
      other.description == description &&
      other.memo == memo &&
      other.recurringRuleId == recurringRuleId &&
      other.occurrenceKey == occurrenceKey &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    date,
    categoryId,
    description,
    memo,
    recurringRuleId,
    occurrenceKey,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'MoneyTransaction($id, $type, $amount, $date, cat: $categoryId)';
}
