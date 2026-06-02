import 'package:drift/drift.dart';

import '../../../domain/entities/recurring_end_condition.dart';
import '../../../domain/entities/recurring_frequency.dart';
import '../../../domain/entities/recurring_repeat_position.dart';
import '../../../domain/entities/recurring_rule.dart';
import '../../../domain/entities/transaction_type.dart';
import '../database/app_database.dart';

/// Maps between [RecurringRuleRow] storage rows and the [RecurringRule] domain
/// entity. Enum fields are stored as their `index`.
extension RecurringRuleRowMapper on RecurringRuleRow {
  RecurringRule toDomain() => RecurringRule(
    id: id,
    type: TransactionType.values[type],
    amount: amount,
    categoryId: categoryId,
    frequency: RecurringFrequency.values[frequency],
    interval: interval,
    repeatPosition: repeatPosition == null
        ? null
        : RecurringRepeatPosition.values[repeatPosition!],
    endCondition: RecurringEndCondition.values[endCondition],
    endCount: endCount,
    endDate: endDate,
    description: description,
    memo: memo,
    startDate: startDate,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension RecurringRuleEntityMapper on RecurringRule {
  RecurringRulesCompanion toCompanion() => RecurringRulesCompanion(
    id: Value(id),
    type: Value(type.index),
    amount: Value(amount),
    categoryId: Value(categoryId),
    description: Value(description),
    memo: Value(memo),
    frequency: Value(frequency.index),
    interval: Value(interval),
    repeatPosition: Value(repeatPosition?.index),
    endCondition: Value(endCondition.index),
    endCount: Value(endCount),
    endDate: Value(endDate),
    startDate: Value(startDate),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
