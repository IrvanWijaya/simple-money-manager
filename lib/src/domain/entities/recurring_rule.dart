import 'recurring_end_condition.dart';
import 'recurring_frequency.dart';
import 'recurring_repeat_position.dart';
import 'transaction_type.dart';

/// A rule describing a recurring money transaction template.
///
/// A rule carries the same financial details as a [MoneyTransaction]
/// (type, amount, category, description, memo) plus the scheduling parameters
/// that the [RecurringSchedule] engine uses to compute occurrence dates.
///
/// [amount] follows the same non-negative-magnitude invariant as
/// [MoneyTransaction]: the sign is derived from [type], never stored negative.
class RecurringRule {
  RecurringRule({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.frequency,
    required this.startDate,
    this.interval = 1,
    this.repeatPosition,
    this.endCondition = RecurringEndCondition.forever,
    this.endCount,
    this.endDate,
    this.description = '',
    this.memo = '',
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
    if (interval < 1) {
      throw ArgumentError.value(interval, 'interval', 'must be at least 1');
    }
    if (endCondition == RecurringEndCondition.count &&
        (endCount == null || endCount! < 1)) {
      throw ArgumentError.value(
        endCount,
        'endCount',
        'must be at least 1 when endCondition is count',
      );
    }
    if (endCondition == RecurringEndCondition.endDate && endDate == null) {
      throw ArgumentError.value(
        endDate,
        'endDate',
        'must be provided when endCondition is endDate',
      );
    }
  }

  /// Stable unique identifier.
  final String id;

  /// Income or expense; determines the sign of generated transactions.
  final TransactionType type;

  /// Non-negative magnitude in whole Rupiah.
  final int amount;

  /// Identifier of the associated category.
  final String categoryId;

  /// How often the rule repeats.
  final RecurringFrequency frequency;

  /// Repeats every [interval] units of [frequency] (every N days/weeks/etc.).
  final int interval;

  /// Where in each period the occurrence is placed; only used when
  /// [frequency] supports a repeat position.
  final RecurringRepeatPosition? repeatPosition;

  /// When the rule stops producing occurrences.
  final RecurringEndCondition endCondition;

  /// Total occurrence count (including the initial one) when
  /// [endCondition] is [RecurringEndCondition.count].
  final int? endCount;

  /// Inclusive last eligible date when [endCondition] is
  /// [RecurringEndCondition.endDate].
  final DateTime? endDate;

  /// Description copied onto generated transactions.
  final String description;

  /// Memo copied onto generated transactions.
  final String memo;

  /// The date (and time) of the first occurrence. Counts as occurrence 1.
  final DateTime startDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// The effective repeat position, defaulting to [RecurringRepeatPosition.sameDay]
  /// for frequencies that support a position but have none set.
  RecurringRepeatPosition get effectiveRepeatPosition =>
      repeatPosition ?? RecurringRepeatPosition.sameDay;

  RecurringRule copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? categoryId,
    RecurringFrequency? frequency,
    int? interval,
    RecurringRepeatPosition? repeatPosition,
    RecurringEndCondition? endCondition,
    int? endCount,
    DateTime? endDate,
    String? description,
    String? memo,
    DateTime? startDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      repeatPosition: repeatPosition ?? this.repeatPosition,
      endCondition: endCondition ?? this.endCondition,
      endCount: endCount ?? this.endCount,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecurringRule &&
      other.id == id &&
      other.type == type &&
      other.amount == amount &&
      other.categoryId == categoryId &&
      other.frequency == frequency &&
      other.interval == interval &&
      other.repeatPosition == repeatPosition &&
      other.endCondition == endCondition &&
      other.endCount == endCount &&
      other.endDate == endDate &&
      other.description == description &&
      other.memo == memo &&
      other.startDate == startDate &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    categoryId,
    frequency,
    interval,
    repeatPosition,
    endCondition,
    endCount,
    endDate,
    description,
    memo,
    startDate,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'RecurringRule($id, $type, $amount, $frequency x$interval, '
      'pos: $repeatPosition, end: $endCondition)';
}
