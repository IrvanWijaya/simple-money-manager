import '../../domain/entities/recurring_end_condition.dart';
import '../../domain/entities/recurring_frequency.dart';
import '../../domain/entities/recurring_repeat_position.dart';
import '../../domain/entities/recurring_rule.dart';
import '../../domain/entities/transaction_type.dart';

/// In-progress recurring configuration chosen in the Recurring bottom sheet.
///
/// This is a pure presentation value object (no Flutter/Drift/Riverpod
/// dependency) describing the user's recurrence choices before they are
/// committed onto a draft transaction and, on save, turned into a domain
/// [RecurringRule].
///
/// [frequency] `none` means the transaction does not recur; [isRecurring] is
/// then false and the remaining fields are ignored. [repeatPosition] is only
/// meaningful for weekly/monthly/yearly frequencies
/// ([RecurringFrequency.supportsRepeatPosition]).
class RecurringSelection {
  const RecurringSelection({
    this.frequency = RecurringFrequency.none,
    this.interval = 1,
    this.repeatPosition = RecurringRepeatPosition.sameDay,
    this.endCondition = RecurringEndCondition.forever,
    this.endCount,
    this.endDate,
  });

  /// The "no recurrence" selection. Equivalent to choosing None.
  static const RecurringSelection none = RecurringSelection();

  /// How often the rule repeats. `none` means it does not recur.
  final RecurringFrequency frequency;

  /// Repeats every [interval] units of [frequency] (always at least 1).
  final int interval;

  /// Where in each period the occurrence lands (weekly/monthly/yearly only).
  final RecurringRepeatPosition repeatPosition;

  /// When the rule stops producing occurrences.
  final RecurringEndCondition endCondition;

  /// Total occurrence count (including the first) when [endCondition] is
  /// [RecurringEndCondition.count].
  final int? endCount;

  /// Inclusive last eligible date when [endCondition] is
  /// [RecurringEndCondition.endDate].
  final DateTime? endDate;

  /// Whether this selection actually recurs (any frequency other than none).
  bool get isRecurring => frequency.repeats;

  /// Whether the current frequency exposes a repeat-position choice.
  bool get supportsRepeatPosition => frequency.supportsRepeatPosition;

  RecurringSelection copyWith({
    RecurringFrequency? frequency,
    int? interval,
    RecurringRepeatPosition? repeatPosition,
    RecurringEndCondition? endCondition,
    int? endCount,
    DateTime? endDate,
    bool clearEndCount = false,
    bool clearEndDate = false,
  }) {
    return RecurringSelection(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      repeatPosition: repeatPosition ?? this.repeatPosition,
      endCondition: endCondition ?? this.endCondition,
      endCount: clearEndCount ? null : (endCount ?? this.endCount),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  /// Builds the domain [RecurringRule] this selection represents, using the
  /// supplied transaction details. Returns `null` when the selection does not
  /// recur ([isRecurring] is false).
  ///
  /// The repeat position is only attached for frequencies that support it; the
  /// end-condition fields are normalized so the resulting rule always satisfies
  /// the [RecurringRule] invariants (a count of at least 1, a non-null end
  /// date), defaulting from [startDate] when needed.
  RecurringRule? toRule({
    required String id,
    required TransactionType type,
    required int amount,
    required String categoryId,
    required DateTime startDate,
    String description = '',
    String memo = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (!isRecurring) return null;

    final int? ruleEndCount = endCondition == RecurringEndCondition.count
        ? (endCount != null && endCount! >= 1 ? endCount : 1)
        : null;
    final DateTime? ruleEndDate = endCondition == RecurringEndCondition.endDate
        ? (endDate ?? startDate)
        : null;

    return RecurringRule(
      id: id,
      type: type,
      amount: amount,
      categoryId: categoryId,
      frequency: frequency,
      interval: interval < 1 ? 1 : interval,
      repeatPosition: supportsRepeatPosition ? repeatPosition : null,
      endCondition: endCondition,
      endCount: ruleEndCount,
      endDate: ruleEndDate,
      description: description,
      memo: memo,
      startDate: startDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecurringSelection &&
      other.frequency == frequency &&
      other.interval == interval &&
      other.repeatPosition == repeatPosition &&
      other.endCondition == endCondition &&
      other.endCount == endCount &&
      other.endDate == endDate;

  @override
  int get hashCode => Object.hash(
    frequency,
    interval,
    repeatPosition,
    endCondition,
    endCount,
    endDate,
  );

  @override
  String toString() =>
      'RecurringSelection($frequency x$interval, pos: $repeatPosition, '
      'end: $endCondition, count: $endCount, date: $endDate)';
}
