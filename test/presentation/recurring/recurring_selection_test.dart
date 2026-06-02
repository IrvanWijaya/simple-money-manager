// Unit tests for the RecurringSelection presentation value object.
//
// Covers the None/recurring distinction, repeat-position applicability per
// frequency, and conversion to a domain RecurringRule with normalized
// end-condition fields (VAL-RECUI-004, -010, -011, -014).

import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/domain/entities/recurring_end_condition.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_repeat_position.dart';
import 'package:simple_money_manager/src/domain/entities/transaction_type.dart';
import 'package:simple_money_manager/src/presentation/recurring/recurring_selection.dart';

void main() {
  test('none is not recurring and yields no rule', () {
    expect(RecurringSelection.none.isRecurring, isFalse);
    final rule = RecurringSelection.none.toRule(
      id: 'r1',
      type: TransactionType.expense,
      amount: 1000,
      categoryId: 'expense_food',
      startDate: DateTime(2026, 6, 1),
    );
    expect(rule, isNull);
  });

  test('daily supports no repeat position, weekly/monthly/yearly do', () {
    expect(
      const RecurringSelection(
        frequency: RecurringFrequency.daily,
      ).supportsRepeatPosition,
      isFalse,
    );
    for (final f in [
      RecurringFrequency.weekly,
      RecurringFrequency.monthly,
      RecurringFrequency.yearly,
    ]) {
      expect(
        RecurringSelection(frequency: f).supportsRepeatPosition,
        isTrue,
        reason: '$f should support a repeat position',
      );
    }
  });

  test('daily rule carries no repeat position even if one is set', () {
    final rule =
        const RecurringSelection(
          frequency: RecurringFrequency.daily,
          interval: 3,
          repeatPosition: RecurringRepeatPosition.endOfPeriod,
        ).toRule(
          id: 'r1',
          type: TransactionType.expense,
          amount: 1000,
          categoryId: 'expense_food',
          startDate: DateTime(2026, 6, 1),
        );
    expect(rule, isNotNull);
    expect(rule!.frequency, RecurringFrequency.daily);
    expect(rule.interval, 3);
    expect(rule.repeatPosition, isNull);
  });

  test('weekly rule carries the repeat position', () {
    final rule =
        const RecurringSelection(
          frequency: RecurringFrequency.weekly,
          repeatPosition: RecurringRepeatPosition.startOfPeriod,
        ).toRule(
          id: 'r1',
          type: TransactionType.income,
          amount: 5000,
          categoryId: 'income_salary',
          startDate: DateTime(2026, 6, 1),
        );
    expect(rule!.repeatPosition, RecurringRepeatPosition.startOfPeriod);
  });

  test('count end condition normalizes a missing count to 1', () {
    final rule =
        const RecurringSelection(
          frequency: RecurringFrequency.daily,
          endCondition: RecurringEndCondition.count,
        ).toRule(
          id: 'r1',
          type: TransactionType.expense,
          amount: 1000,
          categoryId: 'expense_food',
          startDate: DateTime(2026, 6, 1),
        );
    expect(rule!.endCondition, RecurringEndCondition.count);
    expect(rule.endCount, 1);
  });

  test('end-date end condition defaults to the start date when unset', () {
    final start = DateTime(2026, 6, 1);
    final rule =
        const RecurringSelection(
          frequency: RecurringFrequency.monthly,
          endCondition: RecurringEndCondition.endDate,
        ).toRule(
          id: 'r1',
          type: TransactionType.expense,
          amount: 1000,
          categoryId: 'expense_food',
          startDate: start,
        );
    expect(rule!.endCondition, RecurringEndCondition.endDate);
    expect(rule.endDate, start);
  });

  test('copyWith can clear count and date', () {
    const base = RecurringSelection(
      frequency: RecurringFrequency.daily,
      endCondition: RecurringEndCondition.count,
      endCount: 4,
    );
    final cleared = base.copyWith(
      endCondition: RecurringEndCondition.forever,
      clearEndCount: true,
      clearEndDate: true,
    );
    expect(cleared.endCount, isNull);
    expect(cleared.endDate, isNull);
    expect(cleared.endCondition, RecurringEndCondition.forever);
  });
}
